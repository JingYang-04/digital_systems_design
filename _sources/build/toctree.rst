.. Copyright (C) 2019 Bryan A. Jones.

*****
Tools
*****
This provides developer documentation of the tools used to create this interactive textbook.


Sphinx
======
These files configure Sphinx for this book.

.. toctree::
    :maxdepth: 1

    pavement.py
    conf.py
    codechat_config.yaml


waf
===
These files configure the `waf meta-build system <https://waf.io/>`_ to run unit tests on book source. The link below also provides instructions on running the simulation server required to build the source in this book.

.. toctree::
    :maxdepth: 1

    waf/toctree


Misc
====
.. toctree::
    :maxdepth: 1

    .gitignore
    publish.sh
