(** The main file, which is the one that is actually compiled from *)

open Compiler
open Lexing

let optimised = ref false		    
let file = ref ""

(** Reads a lexbuf and turns it into a parse tree *)
let toParseTree (l : Lexing.lexbuf) = (Parser.parseTreeTop Lexer.read l)
	       
(** Parses a given Lexer.lexbuf *)
let parse lexbuf = AsmGen.programToAsm @@
		     (if !optimised
		      then (List.map Optimiser.foldConstants @@ toParseTree lexbuf)
		      else toParseTree lexbuf)
	       
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

(** The 'main' function, checks if a file name is given, if it is, parses that, otherwise acts as an interpreter *)
let _ =
  begin
    let speclist = [("-O", Arg.Set optimised, "Turns optimisation on");
		    ("-f", Arg.Set_string file, "Parses a file (e.g. -f myFile)")]
    in Arg.parse speclist print_endline "";
       if !file <> ""
       then parseFile !file
       else parseLine ()
  end



	 (*
let parseFile fileName =
  let channel = open_in fileName in
  Lexing.from_channel channel
  |> toParseTree
  |> AsmGen.programToAsm
  |> print_string;
  close_in channel

let _ = 
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
	|> Lexing.from_string
        |> toParseTree
	|> AsmGen.programToAsm
	|> print_string)


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
        |> toParseTree
	|> AsmGen.programToAsm
	|> print_string)

let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
       |> Lexing.from_string
       |> toParseTree
       |> LlvmData.pToL; dump_module LlvmData.theModule)

let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
       |> Lexing.from_string
       |> parseWithError
       |> print_string;
	print_newline ())


let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
	|> Lexing.from_string
        |> toParseTree
	|> toLLVMNoOptimisations)
	  *)
	 


