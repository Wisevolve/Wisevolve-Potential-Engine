# Tersoff benchmarks

Two Tersoff-1989 benchmark systems are provided:

- Si diamond
- SiGe zincblende

Each case provides `NVT300/` and `NPT300/` inputs.

The performance protocol uses a 20-step warm-up and a 5000-step production run.

Example:

~~~bash
cd cases/t89_si_diamond/NVT300
gpumd
~~~
