# LLVM community  analysis tools

A set of demonstration scripts to explore the LLVM project to understand how
the community is evolving.

These scripts are simple proofs of concept to show what is possible for others
to take forward. They are not intended as a finished product.

## The scripts

In general the output of the scripts is a CSV file that can be used within a
spreadsheet to generate relevant graphs.

### Analyzing the git repository

These are the main scripts:
- `count-commits-per-release.sh`. Count the number of commits per release,
  possibly broken down to just part of a repository (e.g. for one front end or
  back end). Arguments allow this to be parameterized for GCC or LLVM.
- `count-commits-per-year.sh`. Count the number of commits per year, again
  possibly broken down to just part of a repository.Arguments also allow this
  to be parameterized for GCC or LLVM.

Parameterization scripts:
- `gen-rels-gcc.sh`.  Generate the list of releases in GCC and associated
  parameters.
- `gen-rels-llvm.sh`.  Generate the list of releases in LLVM and associated
  parameters.
- `get-gcc-backend.sh`. Generate the list of back ends to measure.
- `get-gcc-frontend.sh`. Generate the list of front ends to measure.

Supporting scripts:
- `count-commits-all-releases.sh`.  Count the commits by release in a
  repository or part of a repository.
- `count-commits-all-years.sh`.  Count the commits by year in a repository or
  part of a repository.
- `count-commits-one-release.sh`.  Count the commits for one release in a
  repository or part of a repository.
- `count-commits-one-year.sh`.  Count the commits for one year in a repository
  or part of a repository.

Supporting Gnuplot scripts:
- `plot-one-line.gnuplot`.  Plot a single line graph against categories.

Wrapper scripts (currently under revision, do not use):
- `count-authors-gcc.sh`.  Count the number of individual authors and
  multi-user domains by year in the GCC project.
- `count-authors-per-backend-gcc.sh`.  Count the number of individual authors
  and multi-user domains by year in different back ends of the GCC project.
- `count-authors-per-backend.sh`.  Count the number of individual authors and
  multi-user domains by release and by year in different back ends of the
  LLVM project.
- `count-authors.sh`.  Count the number of individual authors and
  multi-user domains by release and by year in the LLVM project.

### Analyzing git repository activity

- `analyze-prs.sh`.  Count the number of merged and unmerged closed pull
  requests and the average number of comments per merged PR in the LLVM GitHub
  repository

## Examples

All run from the top of this repository.  Locations of the repositories being
examined will vary in your own situation!

GCC commits per release
```bash
./count-commits-per-release.sh -r ../../gnu/gcc -n "gcc" -g origin \
    -t "GCC commits per release"
```

GCC commits per year
```bash
./count-commits-per-year.sh -r ../../gnu/gcc -n gcc \
    -t "GCC commits per year" --year-start 1988
```

GCC commits per release for various front ends
```bash
./count-commits-per-release-split.sh -r ../../gnu/gcc -n "gcc" -s "frontend" \
    -g origin -t "GCC commits per release by front end"
```

GCC commits per release for various back ends
```bash
./count-commits-per-release-split.sh -r ../../gnu/gcc -n "gcc" -s "backend" \
    -g origin -t "GCC commits per release by back end"

```
