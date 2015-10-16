open Parser
open Printf
open Lexing

(* following two functions adapted from https://realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html *)
let prettyPrintPosition outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  fprintf outx "Line number: %d, Position: %d"
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parseWithError lexbuf =
  try Parser.stringTop Lexer.read lexbuf with
  | Lexer.SyntaxError msg ->
     prerr_string msg;
     eprintf "\n%a: \n" prettyPrintPosition lexbuf;
     exit (-1)
  | Parser.Error ->
     eprintf "%a: syntax error at " prettyPrintPosition lexbuf;
     prerr_string ((Lexing.lexeme lexbuf) ^ "\n");
    exit (-1)

let parseFile fileName =
  let channel = open_in fileName in
  Lexing.from_channel channel
  |> parseWithError
  |> print_string;
  print_newline ();
  close_in channel
	   
let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
       |> Lexing.from_string
       |> parseWithError
       |> print_string;
       print_newline ())




