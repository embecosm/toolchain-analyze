# LLVM community  analysis tools

A set of demonstration scripts to explore LLVM tools to understand how the
community is evolving.

These scripts are simple proofs of concept to show what is possible for others
to take forward. They are not intended as a finished product.

## The scripts

In general the output of the scripts is a CSV file that can be used within a
spreadsheet to generate relevant graphs.

- `analyze-prs.sh`.  Count the number of merged and unmerged closed pull
  requests and the average number of comments per merged PR in the LLVM GitHub
  repository
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

