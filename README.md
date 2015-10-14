# ocaml-compiler

A compiler written in OCaml for my university Compiler Construction module.

A definition of the grammar is found in languageSpec.org.

To compile, simply type make. The executable will be called mainParser.native. To use, provide no arguments to use it as an interpreter, or provide one argument (the file you want it to run) to run it for that file.

To run the tests, simply type runtests.sh. This shell script assumes you have already compiled with make beforehand.

