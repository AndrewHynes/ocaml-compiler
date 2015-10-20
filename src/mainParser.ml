(** The main file, which is the one that is actually compiled from *)

open Compiler
open Lexing

(** Parses a file from a given file name *)
let parseFile fileName =
  let channel = open_in fileName in
  Lexing.from_channel channel
  |> parseWithError
  |> print_string;
  print_newline ();
  close_in channel

(** The 'main' function, checks if a file name is given, if it is, parses that, otherwise acts as an interpreter *)
let _ =
  if Array.length Sys.argv > 1
  then parseFile Sys.argv.(1)
  else (read_line ()
       |> Lexing.from_string
       |> parseWithError
       |> print_string;
       print_newline ())


