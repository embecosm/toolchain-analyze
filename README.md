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
- `count-commits-gcc.sh`.  Count the number of commits by year in the GCC
  project.
- `count-commits-per-backend.sh`.  Count the number of commits by release and
  by year for different back ends in the LLVM project.
- `count-commits-per-frontend.sh`.  Count the number of commits by release and
  by year for different front ends in the LLVM project.
- `count-commits.sh`.  Count the number of commits by release and by year in
  the LLVM project.

### Analyzing git repository activity

- `analyze-prs.sh`.  Count the number of merged and unmerged closed pull
  requests and the average number of comments per merged PR in the LLVM GitHub
  repository
