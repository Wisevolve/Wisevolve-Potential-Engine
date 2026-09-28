# qNEP benchmarks

qNEP benchmark inputs are provided for two systems:

- water
- BaTiO3

Two qNEP charge modes are included:

- `c1`
- `c2`

For each charge mode, cases with and without BEC coupling are provided:

- `becoff`
- `becon`

Each case contains `NVT300/` and `NPT300/` inputs.

The simulations use PPPM electrostatics, a 20-step warm-up, and a
5000-step production run.

BEC-enabled cases use an electric field through:

~~~text
add_efield 0 0 0.001 0 0 bec
~~~

Example:

~~~bash
cd cases/water_c1_becon/NVT300
gpumd
~~~
