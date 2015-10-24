#FLAGS = -r -use-menhir -use-ocamlfind -package ollvm -I
FLAGS = -r -use-menhir -use-ocamlfind -I +llvm-3.7 -I
OCB = ocamlbuild $(FLAGS)

.PHONY: doc

all: mainParser test

mainParser:
	$(OCB) src mainParser.native

clean:
	$(OCB) src -clean
	rm -rf _/build/src/*

test:
	$(OCB) src -I tests -I tests/shouldSucceed -I tests/shouldFail test.native

doc:
	rm -f doc/htmlDocs/*
	ocamldoc -html src/*.ml -I _build/src/ -d doc/htmlDocs
