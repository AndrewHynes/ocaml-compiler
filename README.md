# ocaml-compiler

A compiler written in OCaml for my university Compiler Construction module.

A definition of the grammar is found in languageSpec.org.

To compile, simply type make. The executable will be called mainParser.native. To use, provide no arguments to use it as an interpreter (e.g. ./mainParser.native), or provide one argument (the file you want it to run) to run it for that file (e.g. ./mainParser.native myFile).

DEPENDENCIES: Menhir version >=20150921, OCaml >=4.02

The tests should be created with "make", but if you need to compile them specifically, you can type "make test". To run the tests, run the executable test.native (such as by typing ./test.native).

The docs should be provided in doc/htmlDocs, but if you need to remake them for any reason, run "make doc". To read them, open up index.html and go from there.

