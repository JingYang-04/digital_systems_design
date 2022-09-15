.. Copyright (C) 2019 Bryan A. Jones

*******************
Exam 1, Fall 2022
*******************

-   You may use only the provided reference materials and one sheet of notes.
-   Absolutely NO cheating is allowed.  If you are caught in the attempt of, the act of, or the past action of academic dishonesty, you will receive the maximum punishment allowed by University policy.
-   "Signed" representation means 2's complement encoding.
-   When writing Verilog code fragments to represent hardware, you cannot minimize or change the hardware in anyway -- your Verilog code must be an accurate representation of the hardware that is shown. A fragment means that it is not a full Verilog module -- use ``wire`` and ``reg`` statements as necessary to declare necessary signals. Verilog is case sensitive for signal names, so you need to be careful in writing signal names.
-   The fill-in-the-blank questions below with numeric answers accept values in decimal (for example, 10), binary (use a leading ``0b`` -- 0b1010), or hexadecimal (use a leading ``0x`` -- 0xA). **DO NOT** use Verilog notation; answering 4'hA or 4'b1010 will be counted an an *incorrect* answer.

As a Mississippi State University student, I will conduct myself with honor and integrity at all times. I will not lie, cheat, or steal, nor will I accept the actions of those who do.

.. fillintheblank:: kpyGI5bwpB

    (1 point)

    Signature: |blank|

    Date: |blank|

    -   :.*: Your signature was recorded.
        :x: An error occurred.
    -   :.*: The date was recorded.
        :x: An error occurred.


.. fillintheblank:: NGQkGkgP70

    (5 points) What is the binary value 10.1101 as a decimal value?

    -   :2.8125: Correct.
        :x: Removing the decimal point gives 6'b101101 = 45. Since there are 4 digits behind the decimal point, divide this by :math:`2^4` -- 45/16 = 2.8125.


.. fillintheblank:: nMBL2rA6ke

    (4 points) What is 0x8A + 0x80 when using standard (unsaturating) 8-bit addition?

    -   :0x0A: Correct.
        :x: This sums to 0x10A, which becomes 0x0A as an 8-bit value.


.. fillintheblank:: FhlFiyofqG

    (4 points) What is 0x8A + 0x80 when using unsigned saturating 8-bit addition?

    -   :0xFF: Correct.
        :x: This produces a carry, so the value saturates to 0xFF.


.. fillintheblank:: Pt0cazBfEr

    (4 points) What is 0x8A + 0x80 when using signed saturating 8-bit addition?

    -   :0x80: Correct.
        :x: This sums to 0x10A, which indicates overflow:

            -   The signs of the addends are both negative.
            -   The sign of the sum is not negative.

            Therefore, the value saturates to the most negative value of 0x80.


.. fillintheblank:: jZB84lZPvg

    (4 points) What is 0x7A + 0x70 when using standard (unsaturating) 8-bit addition?

    -   :0xEA: Correct.
        :x: This sums to 0xEA.


.. fillintheblank:: ygXWE9fvp1

    (4 points) What is 0x7A + 0x70 when using unsigned saturating 8-bit addition?

    -   :0xEA: Correct.
        :x: This produces no carry, so the value is 0xEA.


.. fillintheblank:: NsTki4DT20

    (4 points) What is 0x7A + 0x70 when using signed saturating 8-bit addition?

    -   :0x7F: Correct.
        :x: This sums to 0xEA, which indicates overflow:

            -   The signs of the addends are both not negative.
            -   The sign of the sum is positive.

            Therefore, the value saturates to the most positive value of 0x7F.


Coding problems
===============
.. toctree::
    :glob:
    :maxdepth: 1

    fall_exam_1_problem_??.v