(** The main file, which is the one that is actually compiled from *)

open Compiler
open Lexing
open Printf

let optimised = ref false		    
let file = ref ""

(** Reads a lexbuf and turns it into a parse tree *)
let toParseTree (l : Lexing.lexbuf) = (Parser.parseTreeTop Lexer.read l)
	       
(** Parses a given Lexer.lexbuf *)
let parse lexbuf = try AsmGen.programToAsm @@
		     (if !optimised
		      then (Optimiser.optimise @@ toParseTree lexbuf)
		      else toParseTree lexbuf)
		   with
		   | Lexer.SyntaxError msg ->
		      eprintf "LEXICAL ERROR --- %a: " prettyPrintPosition lexbuf;
		      prerr_string msg;
		      exit (-1)
		   | Parser.Error ->
		      eprintf "SYNTAX ERROR --- %a: " prettyPrintPosition lexbuf;
		      (if (lexbuf.lex_buffer_len = lexbuf.lex_curr_pos)
		       then prerr_string "Expected tokens, found end of input.\n"
		       else prerr_string ("Unexpected character: " ^ (Lexing.lexeme lexbuf) ^ "\n"));
		      exit (-1)
		   | AsmGen.CompilationError msg -> prerr_string ("Compilation error: " ^ msg);
						    exit (-1)
	       
(** Parses a file from a given file name *)
let parseFile fileName =
  let channel = open_in fileName in
  let lexed = Lexing.from_channel channel in
  parse lexed |> print_string;
  close_in channel


(** Parses the command line *)
let parseLine u = (let line = read_line () in
		   let lexLine = Lexing.from_string line in
		   print_string @@ parse lexLine)

(** The 'main' function, checks if a file name is given with -f, if it is, parses that, otherwise acts as an interpreter. *)
let _ =
  begin
    let speclist = [("-O", Arg.Set optimised, "Turns optimisation on");
		    ("-f", Arg.Set_string file, "Parses a file (e.g. -f myFile)")]
    in Arg.parse speclist print_endline "";
       if !file <> ""
       then parseFile !file
       else parseLine ()
  end


