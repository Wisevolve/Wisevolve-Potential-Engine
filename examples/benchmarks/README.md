# WPE benchmark inputs

This directory contains runnable benchmark inputs for the main WPE execution
paths.

- `nep/` — ordinary NEP
- `classical/lj/` — Lennard-Jones
- `classical/eam/` — EAM
- `classical/tersoff/` — Tersoff
- `qnep/` — qNEP
- `pimd/` — path-integral molecular dynamics with NEP

Each case directory contains the GPUMD input files required for that case.

After installing WPE and building the WPE-enabled GPUMD executable, enter a
case directory and run:

~~~bash
gpumd
~~~

See the README in each benchmark family for its systems and run protocol.
