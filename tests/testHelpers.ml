(** A suite of functions to aid and perform testing. *)

open Compiler

let errorString = "ERROR"

(** Parses a string using Menhir *)
let parseString s = (Parser.parseTreeTop Lexer.read) (Lexing.from_string s)

(** Turns a string into unoptimised IR *)
let stringToAST s = try stringFromAST @@ parseString s
		    with
		    | Parser.Error -> errorString
		    | Lexer.SyntaxError msg -> errorString

(** Turns string into optimised IR *)
let stringToOptimisedAST s = try stringFromAST (Optimiser.optimise (parseString s))
			     with
			     | Parser.Error -> errorString
			     | Lexer.SyntaxError msg -> errorString

(** Turns string into unoptimised assembly *)
let stringToAsm s = try AsmGen.programToAsm @@ parseString s
		    with
		    | Parser.Error -> errorString
		    | Lexer.SyntaxError msg -> errorString
		    | AsmGen.CompilationError msg -> errorString

(** Turns string into optimised assembly *)
let stringToOptimisedAsm s = try AsmGen.programToAsm (Optimiser.optimise (parseString s))
			     with
			     | Parser.Error -> errorString
			     | Lexer.SyntaxError msg -> errorString
			     | AsmGen.CompilationError msg -> errorString

(** Runs a list of tests *)
let runTests t = List.map (fun (a, b) -> a = b) t

(** Reads a file into a string *)
let stringOfFile file =
  let fd = open_in file in
  let channel = in_channel_length fd in
  let bytes = Bytes.create channel in
  really_input fd bytes 0 channel;
  close_in fd;
  Bytes.to_string bytes

(** Prints the output of an execution into a file called asmFile.s *)
let printToOutput asm = let output = open_out "asmFile.s" in
			Printf.fprintf output "%s" asm;
			close_out output

(** Runs the program using "cc asmFile.s" followed by "./a.out > outputFile".
 outputFile is checked later for the correct contents. *)
let runProg (u : unit) = ignore(Sys.command ("cc asmFile.s"));
			 ignore(Sys.command ("./a.out > outputFile"))

(** Removes the assembley file, the executable, the outputFile, and resets the environment of the assembly generator *)
let cleanUp (u : unit) = ignore(Sys.command ("rm -f asmFile.s"));
			 ignore(Sys.command ("rm -f outputFile"));
			 ignore(Sys.command ("rm -f a.out"));
			 AsmGen.purgeAllLists ()

(** Cleans the environment, then returns the result of f b *)
let cleanAndRun f b = cleanUp (); f b

(** Runs the runtime tests *)
let runRuntimeTests t =  List.map (fun (a, (b, b2)) -> let asm = cleanAndRun b b2 in
						       (if asm = errorString
							then (a = errorString)
							else
							  (printToOutput (cleanAndRun b b2);
							   runProg ();
							   let output = stringOfFile "outputFile" in
							   a = output))) t

(** Gets the indexes of all of the 'false's in a list so we know which tests failed *)
let indexesOfFalses =
  let rec helper i = function
    | [] -> []
    | hd::tl -> if hd
		then helper (i + 1) tl
		else i::helper (i + 1) tl
  in
  helper 0

(** Pretty prints failed syntax/parsing tests *)
let rec prettyStringTests t = function
  | [] -> []
  | hd::tl -> let (expected, actual) = List.nth t hd in
	      ("--- FAILED SYNTAX/PARSING TEST---\n" ^
		 "Expected: " ^ expected ^
		   "\nActual:   " ^ actual ^ "\n\n")
	      ::prettyStringTests t tl

(** Pretty prints failed runtime tests *)
let rec prettyStringRTTests t = function
  | [] -> []
  | hd::tl -> let (expected, (asm, prog)) = List.nth t hd in
	      ("--- FAILED RUNTIME TEST---\n" ^
		 "Expected: " ^ expected ^
		   "\nProgram that failed: " ^ prog ^ "\n\n")
	      ::prettyStringRTTests t tl

(** Prints a list of strings to stdout *)
let rec printList = function
  | [] -> ()
  | hd::tl -> print_string hd; printList tl

