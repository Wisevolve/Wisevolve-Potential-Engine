# Lennard-Jones benchmarks

Three noble-gas FCC systems are provided:

| case | temperature | cutoff |
|---|---:|---:|
| `Ar_10A` | 70 K | 10 Å |
| `Kr_11A` | 95 K | 11 Å |
| `Xe_12A` | 130 K | 12 Å |

Each system provides `NVT/` and `NPT/` inputs.

The performance protocol uses 442,368 atoms, a 20-step warm-up, and a
5000-step production run.

Example:

~~~bash
cd cases/Ar_10A/NVT
gpumd
~~~
