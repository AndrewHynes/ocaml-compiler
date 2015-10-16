FLAGS = -use-menhir -use-ocamlfind -I
OCB = ocamlbuild $(FLAGS)

all: mainParser

mainParser:
	$(OCB) src mainParser.native

clean:
	$(OCB) -clean
	rm -rf _/build/*
