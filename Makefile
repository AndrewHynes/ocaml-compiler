FLAGS = -r -use-menhir -use-ocamlfind -I
OCB = ocamlbuild $(FLAGS)

all: mainParser test

mainParser:
	$(OCB) src mainParser.native

clean:
	$(OCB) src -clean
	rm -rf _/build/src/*

test:
	$(OCB) src -I tests -I tests/shouldSucceed -I tests/shouldFail test.native
