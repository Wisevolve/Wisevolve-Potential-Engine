# EAM benchmarks

Nine elemental benchmark cases are provided:

- Dai Cu FCC
- Zhou Cu FCC, 5 Å cutoff
- Zhou Cu FCC, 6.5 Å cutoff
- Zhou Ni FCC
- Zhou Al FCC
- Zhou Fe BCC
- Zhou W BCC
- Zhou Mg HCP
- Zhou Ti HCP

Each case provides `NVT300/` and `NPT300/` inputs.

The performance protocol uses a 20-step warm-up and a 5000-step production run.

Example:

~~~bash
cd cases/zhou_fe_bcc/NVT300
gpumd
~~~
