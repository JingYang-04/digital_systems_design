# .. Copyright (C) 2019 Bryan A. Jones.
#
#    This file is part of E-Book Binder.
#
#    E-Book Binder is free software: you can redistribute it and/or modify it
#    under the terms of the GNU General Public License as published by the Free
#    Software Foundation, either version 3 of the License, or (at your option)
#    any later version.
#
#    E-Book Binder is distributed in the hope that it will be useful, but WITHOUT
#    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#    FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
#    details.
#
#    You should have received a copy of the GNU General Public License along
#    with E-Book Binder.  If not, see <http://www.gnu.org/licenses/>.
#
# **************************************************
# |docname| - Waf build script for in-class examples
# **************************************************
# This is invoked by ``wscript``.
#
# Imports
# =======
# These are listed in the order prescribed by `PEP 8
# <http://www.python.org/dev/peps/pep-0008/#imports>`_.
#
# Standard library
# ----------------
import os.path
from os import makedirs
from pathlib import Path
import subprocess
import sys
import zipfile

# Third-party imports
# -------------------
from runestone.lp.lp_common_lib import (
    read_sphinx_config,
    STUDENT_SOURCE_PATH,
    BUILD_SYSTEM_PATH,
)
from waflib import Logs, TaskGen, Task, Utils
from waflib.Errors import WafError
from waflib.TaskGen import after_method, feature

from bookserver.internal.common_builder import get_sim_str_sim30, check_sim_out  # noqa
from bookserver.internal.scheduled_builder import celery_sim_run_mdb  # noqa

# Local imports
# -------------
# None.
#
#
# Project definition
# ==================
# A ``runestone build`` must complete for this (required) data to be available.
sphinx_config = read_sphinx_config()
SPHINX_OUT_PATH = sphinx_config["SPHINX_OUT_PATH"]
SPHINX_SOURCE_PATH = sphinx_config["SPHINX_SOURCE_PATH"]
# Set the build directory; see https://waf.io/book/#_fundamental_waf_commands.
out = str(Path(SPHINX_OUT_PATH) / BUILD_SYSTEM_PATH)

# This follows the `Python recommendations <https://docs.python.org/3/library/sys.html#sys.platform>`_.
is_win = sys.platform == "win32"


# Options
# =======
# Load a build visualizer if it's available.
def load_build_visualizer(ctx):
    # Download ``parallel_debug.py`` from https://github.com/waf-project/waf/tree/master/waflib/extras and place it in ``build\waf`` to produce a `build visualization <https://waf.io/book/#_execution_traces>`_.
    try:
        import parallel_debug  # noqa

        ctx.load("parallel_debug", tooldir=".")
    except ModuleNotFoundError:
        pass


# Define additional command-line options (see the end of `this section <https://waf.io/book/#_waf_project_definition>`_.
def options(opt):
    load_build_visualizer(opt)
    # Define `command-line options (see 3.2.4) <https://waf.io/book/#_fundamental_waf_commands>`_ to build all tests, or just student tests. See also `optparse <https://docs.python.org/3/library/optparse.html>`_.
    opt.add_option(
        "--check-wrong",
        action="store_true",
        default=False,
        # Do not enable this for code built on the web server, since student solutions will not contain the necessary "wrong" functions. See WAF_CHECK_WRONG_, `/signed_8-_and_16-bit_ops/signed_differences_ex_1-test.c` and `FUNC_COMPARE_WRONG`.
        help="Run additional tests which verify that incorrect solutions do produce test failures.",
    )
    opt.add_option(
        "--no-pic24",
        action="store_false",
        default=True,
        dest="pic24_enabled",
        help="Disable building PIC24 sources; enabled by default. Only applies to configure (not build/gdist/etc.).",
    )
    opt.add_option(
        "--no-arm",
        action="store_false",
        default=True,
        dest="arm_enabled",
        help="Disable building ARM sources; enabled by default. Only applies to configure (not build/gdist/etc.).",
    )
    opt.add_option(
        "--no-verilog",
        action="store_false",
        default=True,
        dest="verilog_enabled",
        help="Disable building Verilog sources; enabled by default. Only applies to configure (not build/gdist/etc.).",
    )


# Configure
# =========
# `Configure <https://waf.io/book/#_waf_project_definition>`_ the build.
def configure(ctx):
    # Save the current (unconfigured) environment before modifying it for the PIC24.
    env = ctx.env

    if ctx.options.pic24_enabled:
        # Create one configuration for the PIC24 build -- see the `waf docs <https://waf.io/book/#_configuration_utilities>`_, section 4.2.3.
        ctx.setenv("pic24")
        # Tell the tools our "OS" is the PIC24 platform.
        ctx.env.DEST_OS = "PIC24"
        # Select a specific processor to compile for.
        ctx.env.MCU = "33EP128GP502"
        # Infer the full MCU name.
        ctx.env.MCU_FULL = "pic" + ctx.env.MCU
        if ctx.env.MCU.startswith("33") or ctx.env.MCU.startswith("30"):
            ctx.env.MCU_FULL = "ds" + ctx.env.MCU_FULL
        # Define the processor family for the old simulator.
        ctx.env.SIM_MCU = "dspic33epsuper"
        # Load in the xc16 tools -- see `xc16_gcc.py`, `xc16_as.py`, and `xc16_ar.py`.
        ctx.load("xc16_gcc xc16_as xc16_ar")
        # Locate the simulators.
        ctx.find_program(["sim30"], var="SIM30")
        ctx.find_program(["mdb"], var="MDB")
        load_build_visualizer(ctx)

    # On Windows, a batch file wraps calls to the ARM tools and Verilog compiler. Add that to the path.
    ctx.environ["PATH"] += os.pathsep + str(Path(__file__).parent.resolve())

    if ctx.options.arm_enabled:
        # Create a second configuration for the ARM build, based on the initial configuration.
        ctx.setenv("armv7", env)
        ctx.env.DEST_OS = "ARMv7"
        ctx.load("armv7_gcc armv7_as armv7_ar")
        ctx.find_program(["arm-none-eabi-objcopy"], var="OBJCOPY")
        ctx.find_program(["qemu-system-arm"], var="QEMU")

    if ctx.options.verilog_enabled:
        ctx.setenv("verilog", env)
        ctx.find_program(["iverilog"], var="IVERILOG")
        ctx.env.IVERILOG_DEFINES_ST = ["-D"]


# Source
# ======
# All source files are in ``SPHINX_SOURCE_PATH``. I don't see a nice way of invoking the build from the project root directory, but specifying files relative to ``SPHINX_SOURCE_PATH``. Ideas:
#
# - Define ``out = SPHINX_SOURCE_PATH``. This produces confusing errors.
# - Use a subproject -- have one wscript invoke ``cts.recurse(SPHINX_SOURCE_PATH)``. I haven't tried this, but it seems a bit messy.
# - Prepend ``SPHINX_SOURCE_PATH`` to all files. The function below makes this easy.
def _source(src):
    if isinstance(src, str):
        # If given a string, prepend.
        return str(Path(SPHINX_SOURCE_PATH) / src)
    else:
        # Assume it's a list, so return a list of prepended strings.
        return [_source(_) for _ in src]


# Define the source files which are a part of the PIC24 library collection.
PIC24SupportLibSources = _source(
    [
        "lib/src/pic24_clockfreq.c",
        "lib/src/pic24_configbits.c",
        "lib/src/pic24_serial.c",
        "lib/src/pic24_timer.c",
        "lib/src/pic24_uart.c",
        "lib/src/pic24_util.c",
        # Replaced by mocks.
        #'lib/src/pic24_i2c.c',
        #'lib/src/pic24_adc.c',
        #'lib/src/pic24_spi.c',
        # Not needed by the code used.
        #'lib/src/pic24_stdio_uart.c',
        #'lib/src/dataXfer.c',
        #'lib/src/dataXferImpl.c',
        #'lib/src/pic24_ecan.c',
        #'lib/src/pic24_flash.c',
        # Include the tester.
        "tests/platform/Microchip_PIC24/platform.c",
        "tests/test_utils.c",
        "tests/test_assert.c",
        "tests/coroutines.c",
    ]
)


# The ARM support library mostly comes from newlib; this adds a few basics plus coroutines.
ARMv7SupportLibSources = _source(
    [
        "tests/platform/ARMv7-A_ARMv7-R/platform.c",
        "tests/test_utils.c",
        "tests/test_assert.c",
        "tests/coroutines.c",
    ]
)


# Defines used for compiling all source.
common_c_defines = ["SIM="]


# Provide a list of include directories necessary to compile the PIC24 support library and the tester.
BOOK_INCLUDES = _source(["lib/include", "tests"])
PIC24_BOOK_INCLUDES = BOOK_INCLUDES + _source(["tests/platform/Microchip_PIC24"])
ARMV7_BOOK_INCLUDES = BOOK_INCLUDES + _source(["tests/platform/ARMv7-A_ARMv7-R"])


# Simulators
# ==========
# A verification code -- an ever-changing 32-bit value when building student source, but a constant here for simplicity.
verification_code = 0x8AA35948


# This function runs a simulation, verifying that the simulation results
# are correct, using the older SIM30 simulator.
#
# Inputs: path_to_elf_binary
#
# Outputs: sim_output_file
def sim_run_sim30(task):
    Logs.pprint("BLUE", "Simulating (sim30)", task.inputs[0].relpath())
    sim_ret = 0
    out = ""
    s = get_sim_str_sim30(
        task.env.SIM_MCU, task.inputs[0].abspath(), task.outputs[0].abspath()
    )
    try:
        sim_ret = task.exec_command(
            [task.env.SIM30[0]],
            timeout=6,
            input=s,
            universal_newlines=True,
            stdout=subprocess.DEVNULL,
        )
    except (WafError) as e:
        sim_ret = 1
        # Report the exception (such as a timeout) in addition to the simulator output.
        out = str(e) + "\n" + "*" * 80 + "\n"

    # Check the output.
    out += task.outputs[0].read()
    # I can't get the sim30 simulator to set the verification code. Sigh.
    if not sim_ret and check_sim_out([out], verification_code):
        return 0
    else:
        # Display what output we saw if there's a failure.
        print(out)
        return 1


# This function runs a simulation, verifying that the simulation results
# are correct, using the newer MDB simulator.
#
# Inputs: path_to_elf_binary
#
# Outputs: sim_output_file
def sim_run_mdb(task):
    Logs.pprint("BLUE", "Simulating (MDB)", task.inputs[0].relpath())

    # Run the simulation.
    res = celery_sim_run_mdb.delay(
        task.env.MDB[0], task.env.MCU_FULL, task.inputs[0].abspath()
    )
    output = res.get(timeout=60)

    # Check the output. The last two lines contain FAIL or Correct, then Done and a code.
    if check_sim_out([output], verification_code):
        return 0
    else:
        # Display what output we saw if there's a failure.
        print(output if output else "Error: simulation task returned no output.")
        return 1


# This function runs the iVerilog simulator.
#
# Inputs: path_to_elf_binary
#
# Outputs: sim_output_file
def sim_run_iverilog(task):
    Logs.pprint("BLUE", "Simulating (iVerilog)", task.inputs[0].relpath())

    # Run the compiler.
    sim_ret = 0
    out = ""
    # On Windows, we have to run this in WSL. Taken from `arm-none-eabi-ar.bat`.
    tmp = (
        "wsl "
        + task.inputs[0]
        .abspath()
        .replace("\\", "/")
        .replace("C:", "/mnt/c")
        .replace("(", "\\(")
        .replace(")", "\\)")
        if is_win
        else task.inputs[0].abspath()
    )
    # Only specify the cwd when there are test vectors (task.inputs[1]) to read.
    kwargs = {}
    if len(task.inputs) >= 2:
        kwargs["cwd"] = task.inputs[1].parent.abspath()
    try:
        sim_ret = task.exec_command(
            f"{tmp} > {task.outputs[0].abspath()}",
            **kwargs,
            timeout=6,
        )
    except (WafError) as e:
        sim_ret = 1
        # Report the exception (such as a timeout) in addition to the simulator output.
        out = str(e) + "\n" + "*" * 80 + "\n"

    # Check the output.
    out += task.outputs[0].read()
    if not sim_ret and check_sim_out([out], verification_code):
        return 0
    else:
        # Display what output we saw if there's a failure.
        print(out)
        return 1


# This function runs a simulation, verifying that the simulation results
# are correct, using the QEMU ARMv7 simulator.
#
# Inputs: path_to_elf_binary
#
# Outputs: sim_output_file
def sim_run_qemu(task):
    Logs.pprint("BLUE", "Simulating (qemu)", task.inputs[0].relpath())
    sim_ret = 0
    out = ""
    # Remove the output file, so we don't get results from old builds.
    task.outputs[0].delete(False)
    try:
        sim_ret = task.exec_command(
            f"{task.env.QEMU[0]} -M vexpress-a9 -m 32M -no-reboot -nographic "
            "-audiodev id=none,driver=none -monitor none -kernel "
            f"{task.inputs[0].abspath()} -serial stdio -semihosting > "
            f"{task.outputs[0].abspath()}",
            timeout=6,
            shell=True,
        )
    except (WafError) as e:
        sim_ret = 1
        # Report the exception (such as a timeout) in addition to the simulator output.
        out = str(e) + "\n" + "*" * 80 + "\n"

    try:
        # Check the output.
        out += task.outputs[0].read()
    except FileNotFoundError:
        out += "Error: No output produced."

    if not sim_ret and check_sim_out([out], verification_code):
        return 0
    else:
        # Display what output we saw if there's a failure.
        print(out)
        return 1


# Special link flags
# ==================
# This adds the path to the linker script in the link step. It was inspired by https://github.com/waf-project/waf/blob/master/playground/ldscript/wscript.
@after_method("apply_link")
@feature("cprogram")
def process_ldscript(self):
    if self.env.CC_NAME == "armv7-gcc":
        node = self.path.find_resource(
            _source("tests/platform/ARMv7-A_ARMv7-R/redboot.ld")
        )
        if not node:
            raise Utils.WafError("could not find %r" % self.ldscript)
        self.link_task.env.append_value("LINKFLAGS", "-T")
        self.link_task.env.append_value("LINKFLAGS", node.abspath())
        self.link_task.dep_nodes.append(node)
    else:
        # This is a PIC24 link.
        mcu = getattr(self.env, "MCU", None)
        if not mcu or self.env.CC_NAME != "xc16-gcc":
            return

        # This refers to the preprocessed version of the required linker script.
        node = self.path.find_resource(
            _source("lib/lkr/p{MCU}_bootldr.gld.00".format(**self.env))
        )
        if not node:
            raise Utils.WafError("could not find %r" % self.ldscript)
        self.link_task.env.append_value("LINKFLAGS", "-Wl,--script=" + node.abspath())
        self.link_task.dep_nodes.append(node)


# PIC24 builds
# ============
# The typical way to compile/assemble.
def c_or_asm_objects(ctx, source, includes, is_asm, name, idx, base_defines=False):
    base_defines = base_defines or []
    return ctx.objects(
        source=source,
        defines=base_defines + ([] if is_asm else common_c_defines),
        features="c asm",
        name=name,
        includes=includes,
        # Keep the index consistent, so that adding a source file doesn't change the index of every file after it, causing as long, painful _`mass recompile`.
        idx=idx,
    )


# Given an assembly or C source file, build it and run a simulation.
def build_pic24_src(
    # _`ctx`: The build context.
    ctx,
    # _`src`: A string defining the assembly or C source file to build.
    src,
):

    # Derive file names from src_.
    base_name = os.path.splitext(src)[0]
    extension = os.path.splitext(src)[1]
    is_asm = extension == ".s"
    obj_name = base_name + ".o"
    # Include the WAF_CHECK_WRONG_ option if present. The assembler command line requires each option to have a value specified.
    base_defines = ["WAF_CHECK_WRONG=1"] if ctx.options.check_wrong else []
    use = ["pic24_stdlib"]
    # Assemble/compile src_, unless this file is already included in the support libraries. In that case, skip the compile since the linker will pull it from the library.
    if src not in PIC24SupportLibSources:
        c_or_asm_objects(
            ctx, [src], PIC24_BOOK_INCLUDES, is_asm, obj_name, 1, base_defines
        )
        use.append(obj_name)

    # Use that plus the C library and test code to build the program.
    c_test_src = base_name + "-test.c"
    p = ctx.program(
        source=[c_test_src],
        # _`WAF_CHECK_WRONG`: Include a define to tell the code it's being built for all tests, not for testing student code.
        defines=base_defines
        + common_c_defines
        + [f"VERIFICATION_CODE=({verification_code}u)"],
        use=use,
        target=base_name,
        includes=PIC24_BOOK_INCLUDES,
        features="c cprogram",
        # Avoid a `mass recompile`_.
        idx=1,
    )

    # Run the simulation. Use the slower, more accurate simulator for C code which (we assume) operates on the hardware. Otherwise, use the faster simulator.
    source = ctx.env.cprogram_PATTERN % p.target
    if is_asm:
        ctx(
            rule=sim_run_sim30,
            source=source,
            target=[ctx.path.find_or_declare(p.target + ".sim_out")],
        )
    else:
        ctx(rule=sim_run_mdb, source=source)

    # Create MPLAB X project files. See https://waf.io/apidocs/TaskGen.html#waflib.TaskGen.process_subst.
    #
    # First, create the project directory.
    project_dir = str(
        Path(SPHINX_OUT_PATH)
        / STUDENT_SOURCE_PATH
        / Path(base_name + ".X").relative_to(SPHINX_SOURCE_PATH)
    )
    try:
        # Also create the nbproject directory, since make_node expects the
        # containing directory to exist.
        os.makedirs(os.path.join(ctx.path.abspath(), project_dir, "nbproject"))
    except FileExistsError:
        pass
    # Copy and template replace the project files.
    for _ in ("Makefile", "nbproject/configurations.xml", "nbproject/project.xml"):
        ctx(
            features="subst",
            source=_source("build/waf/mplab_X_project_template/{}.in".format(_)),
            target=ctx.path.make_node(os.path.join(project_dir, _)),
            # Include the source unless it's already in the libraries.
            SRC="" if src in PIC24SupportLibSources else os.path.basename(src),
            TEST_SRC=os.path.basename(c_test_src),
            PROJECT_NAME=os.path.basename(base_name),
        )


# ARMv7 builds
# ============
# Given an ARMv7 assembly or C source file, build it and run a simulation.
def build_armv7_src(
    # See ctx_.
    ctx,
    # See src_.
    src,
):

    # Derive file names from src_.
    base_name = os.path.splitext(src)[0]
    extension = os.path.splitext(src)[1]
    is_asm = extension.lower() == ".s"
    obj_name = base_name + ".o"
    # Include the WAF_CHECK_WRONG_ option if present. The assembler command line requires each option to have a value specified.
    base_defines = ["WAF_CHECK_WRONG=1"] if ctx.options.check_wrong else []
    use = ["armv7_stdlib"]
    # Assemble/compile src_, unless this file is already included in the support libraries. In that case, skip the compile since the linker will pull it from the library.
    if src not in ARMv7SupportLibSources:
        c_or_asm_objects(
            ctx, [src], ARMV7_BOOK_INCLUDES, is_asm, obj_name, 2, base_defines
        )
        use.append(obj_name)

    # Use that plus the C library and test code to build the program.
    c_test_src = base_name + "-test.c"
    p = ctx.program(
        # TODO: leaving out interrupts.S here make the sim fail. I'm guessing the archive utility doesn't store the section the interrupts are placed in.
        source=[_source("tests/platform/ARMv7-A_ARMv7-R/interrupts.S"), c_test_src],
        # See WAF_CHECK_WRONG_.
        defines=base_defines
        + common_c_defines
        + [f"VERIFICATION_CODE=({verification_code}u)"],
        use=use,
        target=base_name,
        includes=ARMV7_BOOK_INCLUDES,
        features="c cprogram",
        # Avoid a `mass recompile`_.
        idx=2,
    )

    # Run objcopy to turn the elf into a bin.
    bin_file = ctx(
        rule="${OBJCOPY} -O binary ${SRC} ${TGT}",
        source=ctx.path.find_or_declare(p.target + ".elf"),
        target=ctx.path.find_or_declare(p.target + ".bin"),
    )
    # Run the simulator (see below for fixes).
    ctx(
        # sim_run_qemu,
        source=bin_file.target,
        # target=ctx.path.find_or_declare(p.target + ".sim_out")
    )


# This is needed to make the ARM simulator work. Without this, waf doesn't know what do with a ``.bin`` file (even though the "run the simulator" above seems to tell it.) Otherwise, waf produces the error ``File /long/path/to/blah.bin has no mapping in ['.c', '.SPP', '.spp', '.ASM', '.asm', '.S', '.s', '.obj', '.o', '.elf', '.pc.in'] (load a waf tool?)``
@TaskGen.extension(".bin")
def bin_hook(self, node):
    return self.create_task(
        "Qemu", node, node.find_or_declare(node.abspath()).change_ext(".sim_out")
    )


class Qemu(Task.Task):
    run = sim_run_qemu
    ext_in = ".bin"
    ext_out = ".sim_out"


# Verilog build
# =============
def build_verilog_src(
    # See ctx_.
    ctx,
    # See src_.
    src,
):
    # Derive file names from src_.
    base_name = os.path.splitext(src)[0]
    exe_name = base_name + ".exe"
    test_vectors_name = base_name + "-test.txt"
    simout_name = base_name + ".iverlog_sim_out"
    # Use the simulation file plus the test bench to simulate the program.
    test_src = base_name + "-test.v"
    p = ctx(
        # Hack: including ``${IVERILOG_DEFINES_ST:DEFINES}`` doesn't work -- waf adds a space between ``-D`` and the define. To even get this to work, add ``ctx.env.DEFINES = [f"VERIFICATION_CODE={verification_code}"]``, since defining it below doesn't work.
        rule="${IVERILOG} ${SRC} -o ${TGT} ${IVERILOG_DEFINES_ST}"
        + f"VERIFICATION_CODE={verification_code}",  # ",
        source=[ctx.path.find_resource(src), ctx.path.find_resource(test_src)],
        target=ctx.path.find_or_declare(exe_name),
        idx=2,
        # Defining it here has no effect.
        ##defines=[f"VERIFICATION_CODE={verification_code}"]
    )
    # Test vectors are optional; include them if they exist.
    test_vectors_node = ctx.path.find_resource(test_vectors_name)
    source = [p.target]
    if test_vectors_node:
        source.append(test_vectors_node)
    ctx(
        rule=sim_run_iverilog,
        source=source,
        target=ctx.path.find_or_declare(simout_name),
    )


# Overall build
# =============
def build(ctx):
    check_no_config_only_flags(ctx)
    if env := ctx.all_envs.get("pic24"):
        # Switch to the PIC24 environment.
        ctx.env = env
        # Compile the PIC24 library source.
        c_or_asm_objects(
            ctx, PIC24SupportLibSources, PIC24_BOOK_INCLUDES, False, "pic24_stdobj", 1
        )
        ctx.stlib(target="pic24_stdlib", use="pic24_stdobj", features="c cstlib")

        # Build all source files.
        for node in ctx.path.ant_glob(
            _source(["**/*.s", "**/*.c"]),
            excl=_source(
                [
                    "lib/**/*",
                    "**/*-test.c",
                    "2016-summer/**/*",
                    "misc/**/*",
                    "tests/platform/**/*",
                ]
            ),
        ):
            build_pic24_src(ctx, node.relpath())

    # Build for ARM7 if it was configured.
    if env := ctx.all_envs.get("armv7"):
        # Switch to the ARM environment.
        ctx.env = env
        # Compile the ARM library source.
        c_or_asm_objects(
            ctx, ARMv7SupportLibSources, ARMV7_BOOK_INCLUDES, False, "armv7_stdobj", 2
        )
        ctx.stlib(target="armv7_stdlib", use="armv7_stdobj", features="c cstlib")

        # Build all source files.
        for node in ctx.path.ant_glob(
            _source(["misc/**/*.S", "misc/**/*.c"]),
            excl=_source(
                [
                    "**/*-test.c",
                ]
            ),
        ):
            build_armv7_src(ctx, node.relpath())

    # Build Verilog if it was configured.
    if env := ctx.all_envs.get("verilog"):
        # Switch to the Verilog environment.
        ctx.env = env
        # Build all source files.
        for node in ctx.path.ant_glob(
            _source(["**/*.v"]),
            excl=_source(
                [
                    "**/*-test.v",
                ]
            ),
        ):
            build_verilog_src(ctx, node.relpath())


# Check that configure-only flags weren't passed to this waf invocation.
def check_no_config_only_flags(ctx):
    if not ctx.options.pic24_enabled:
        sys.exit("Error: the --no-pic24 flag may only be passed to waf configure.")
    if not ctx.options.arm_enabled:
        sys.exit("Error: the --no-arm flag may only be passed to waf configure.")
    if not ctx.options.verilog_enabled:
        sys.exit("Error: the --no-verilog flag may only be passed to waf configure.")


# Distribute
# ==========
# Create an archive of student source files produced by Sphinx.
def gdist(ctx):
    check_no_config_only_flags(ctx)
    book_path = Path(ctx.path.abspath()) / SPHINX_OUT_PATH / "_static"
    makedirs(str(book_path), exist_ok=True)
    zip_name = str(book_path / "pic24-book.zip")

    # Add student source files to the ZIP file. This was copied and modified from
    # waflib.Scripting.Dist.archive.
    with zipfile.ZipFile(zip_name, "w", compression=zipfile.ZIP_DEFLATED) as zip_:
        # Get a list of student source files.
        base_source_path = ctx.path.find_node(
            str(Path(SPHINX_OUT_PATH) / STUDENT_SOURCE_PATH)
        )
        generated_files = base_source_path.ant_glob("**")

        # Add them to the archive.
        for x in generated_files:
            archive_name = x.path_from(base_source_path)
            zip_.write(x.abspath(), archive_name, zipfile.ZIP_DEFLATED)

        # Repeat for PIC24 library files.
        base_project_path = ctx.path.find_node(_source("."))
        generated_files = base_project_path.ant_glob("lib/**/*")

        # Add them to the archive.
        for x in generated_files:
            archive_name = x.path_from(base_project_path)
            zip_.write(x.abspath(), archive_name, zipfile.ZIP_DEFLATED)
