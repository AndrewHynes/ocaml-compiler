open Compiler

let errorString = "ERROR"
       
let parseString s = (Parser.parseTreeTop Lexer.read) (Lexing.from_string s)
						     
let stringToAST s = try stringFromAST (parseString s) with
  | Parser.Error -> errorString
  | Lexer.SyntaxError msg -> errorString
			       
let stringToOptimisedAST s = try stringFromAST (List.map Optimiser.foldConstants (parseString s)) with
  | Parser.Error -> errorString
  | Lexer.SyntaxError msg -> errorString

			       
let runTests t = List.map (fun (a, b) -> a = b) t

let indexesOfFalses =
  let rec helper i = function
  | [] -> []
  | hd::tl -> if hd
	      then helper (i + 1) tl
	      else i::helper (i + 1) tl
  in
  helper 0

let rec prettyStringTests t = function
  | [] -> []
  | hd::tl -> let (expected, actual) = List.nth t hd in
	      ("--- FAILED TEST---\n" ^
		"Expected: " ^ expected ^
		  "\nActual: " ^ actual ^ "\n\n")
	      ::prettyStringTests t tl

let rec printList = function
  | [] -> ()
  | hd::tl -> print_string hd; printList tl

(*
In case I ever want to parse from files...

let stringOfFile file =
  let fd = open_in file in
  let channel = in_channel_length fd in
  let bytes = Bytes.create channel in
  really_input fd bytes 0 channel;
  close_in fd;
  Bytes.to_string bytes


let succeedDir = "shouldSucceed"
let failDir = "shouldFail"
 *)

