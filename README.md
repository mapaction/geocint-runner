# geocint-runner

## geocint processing pipeline

Geocint is Kontur's open source geodata ETL/CI/CD pipeline designed for ease of maintenance and high single-node throughput. Writing
the code as Geocint target makes sure that it is fully recorded, can be run autonomously, can be inspected, reviewed and
tested by other team members, and will automatically produce new artifacts once new input data comes in.

### Geocint structure:

Geocint consists of 3 different parts:
- [geocint-runner](https://github.com/konturio/geocint-runner) - a core part of the pipeline, includes utilities and initial Makefile
- [geocint-mapaction-osm](https://github.com/mapaction/geocint-mapaction-osm) - an ETL Python-based solution for downloading, processing, and analyzing OpenStreetMap (OSM) data across multiple geographic entities
- [geocint-mapaction](https://github.com/mapaction/geocint-mapaction) - This repository contains opensource geodata ETL/CI/CD.  It is based on Kontur Geocint technology.

### Technology stack:

- A high-performance computer. OS: the latest Ubuntu version (not necessarily LTS).
- Bash (Linux shell) is used for scripting.
https://tldp.org/LDP/abs/html/
- GNU Make is used as job server. We do not use advanced features like variables and wildcards, using simple explicit
  "file-depends-on-file" mode. Make takes care of running different jobs concurrently whenever possible.
  https://makefiletutorial.com/
- make-profiler is used as linter and preprocessor for Make that outputs a network diagram of what is getting built when
  and why. The output chart allows to see what went wrong and quickly get to logs.
  https://github.com/konturio/make-profiler
- GNU Parallel is used for paralleling tasks that cannot be effectively paralleled by Postgres, essentially parallel-enabled
  Bash. https://www.gnu.org/software/parallel/parallel.html
- python is used for small tasks like unpivoting source data.
- GDAL, OGR, osm-c-tools, osmium, and other tools are utilized in Bash CLI as needed.


[Install, first run guides and best practices](DOCUMENTATION.md)