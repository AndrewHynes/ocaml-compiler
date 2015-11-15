open Compiler

let errorString = "ERROR"
		    
let parseString s = (Parser.parseTreeTop Lexer.read) (Lexing.from_string s)
						     
let stringToAST s = try stringFromAST @@ parseString s
		    with
		    | Parser.Error -> errorString
		    | Lexer.SyntaxError msg -> errorString
						 
let stringToOptimisedAST s = try stringFromAST (Optimiser.optimise (parseString s))
			     with
			     | Parser.Error -> errorString
			     | Lexer.SyntaxError msg -> errorString

let stringToOptimisedAsm s = try AsmGen.programToAsm (Optimiser.optimise (parseString s))
			     with
			     | Parser.Error -> errorString
			     | Lexer.SyntaxError msg -> errorString
			     | AsmGen.CompilationError msg -> errorString

let stringToAsm s = try AsmGen.programToAsm @@ parseString s
		    with
		    | Parser.Error -> errorString
		    | Lexer.SyntaxError msg -> errorString
		    | AsmGen.CompilationError msg -> errorString
						 
						 
let runTests t = List.map (fun (a, b) -> a = b) t

let stringOfFile file =
  let fd = open_in file in
  let channel = in_channel_length fd in
  let bytes = Bytes.create channel in
  really_input fd bytes 0 channel;
  close_in fd;
  Bytes.to_string bytes

let printToOutput asm = let output = open_out "asmFile.s" in
			Printf.fprintf output "%s" asm;
			close_out output

let runProg (u : unit) = ignore(Sys.command ("cc asmFile.s"));
			 ignore(Sys.command ("./a.out > outputFile"))

let cleanUp (u : unit) = ignore(Sys.command ("rm -f asmFile.s"));
			 ignore(Sys.command ("rm -f outputFile"));
			 ignore(Sys.command ("rm -f a.out"));
			 AsmGen.purgeAllLists ()

let cleanAndRun f b = cleanUp (); f b
			       
let runRuntimeTests t =  List.map (fun (a, (b, b2)) -> let asm = cleanAndRun b b2 in
						       (if asm = errorString
							then (a = errorString)
							else
							  (printToOutput (cleanAndRun b b2);
							   runProg ();
							   let output = stringOfFile "outputFile" in
							   a = output)))
				  t

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
	      ("--- FAILED SYNTAX/PARSING TEST---\n" ^
		 "Expected: " ^ expected ^
		   "\nActual:   " ^ actual ^ "\n\n")
	      ::prettyStringTests t tl

let rec prettyStringRTTests t = function
  | [] -> []
  | hd::tl -> let (expected, (asm, prog)) = List.nth t hd in
	      ("--- FAILED RUNTIME TEST---\n" ^
		 "Expected: " ^ expected ^
		   "\nProgram that failed: " ^ prog ^ "\n\n")
	      ::prettyStringRTTests t tl

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

