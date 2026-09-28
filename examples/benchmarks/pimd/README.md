# PIMD example

A 1,536-atom water system with 32 beads is provided at 300 K.

Two inputs are included:

- `NVT300/` — NVT-PIMD
- `NPT300/` — NPT-PIMD with stochastic cell rescaling at 0 GPa

The inputs use a 0.5 fs time step, a 100-step warm-up, and a 1000-step
production run.

NVT-PIMD uses:

~~~text
ensemble pimd 32 300 300 4000
~~~

NPT-PIMD uses:

~~~text
ensemble pimd_scr 32 300 300 4000 0 100 1000
~~~

Example:

~~~bash
cd cases/water-N1536-P32/NVT300
gpumd
~~~
