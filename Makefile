FLAGS = -use-menhir -use-ocamlfind
OCB = ocamlbuild $(FLAGS)

all: mainParser

mainParser:
	$(OCB) mainParser.native

clean:
	$(OCB) -clean
	rm -rf _/build/*
