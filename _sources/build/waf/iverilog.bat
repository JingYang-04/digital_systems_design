REM *********************************************************
REM |docname| - Run iVerilog as installed in WSL from Windows
REM *********************************************************
REM See `arm-none-eabi-as.bat`.
python -c "import sys, subprocess; subprocess.run(['wsl', 'iverilog'] + [x.replace('\\', '/').replace('C:', '/mnt/c').replace('(', '\\(').replace(')', '\\)') for x in sys.argv[1:]], check=True)" %*