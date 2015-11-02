(** Generates assembly code from a syntax tree *)

open Syntax
open AsmSnippets
open Helpers

exception CompilationError of string

(* Note: will probably want to be an integer in the future. *)
(** Keeps a list of all of the labels used (for use with branch instructions) *)
let labels = ref []

(** Keeps position of global variables (may be obsolete soon) *)
let varPositions = ref []

(** Keeps the position of local variables *)
let varPositions2 = ref []

(** Resets all of the lists (mainly for purpose of testing) *)
let purgeAllLists (u : unit) = labels := [];
			       varPositions := [];
			       varPositions2 := [];
			       u

(** Finds the position in the stack of a variable as written in the output assembly *)
let rec findVarPos x = function
  | [] -> raise $ CompilationError ("Variable " ^ x ^ " never initialised.\n")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVarPos x tl

(** Removes a variable from the list *)
let rec rmVar x = function
  | [] -> []
  | (a, b)::tl when x = a -> tl
  | hd::tl -> hd::(rmVar x tl)

(** Adds a variable to the list of local variables *)
let addVar v = let len = List.length !varPositions2 + 1 in
	       (*varPositions2 := rmVar v !varPositions2;*)
	       (*(if (exists v varPositions2)
	       then rmVar v
	       else ());*)
	       varPositions2 := (v, (len * 8)) :: !varPositions2;
               (len * 8)

(** Finds the name of a variable as written in the output assembly *)
let rec findVarName x = function
  | [] -> raise $ CompilationError ("Variable " ^ x ^ " never initialised.\n")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVarName x tl

(** Adds to the data segment of the output for each variable we need space for *)
let makeDataSegment (e : expression) = match e with
  | AssignExp (s, _) -> let name = "v" ^ (string_of_int $ List.length !varPositions) in
			varPositions := (s, name) :: !varPositions;
			name ^ ":\t.space 8\n"
  | _ -> ""
	   
(** Converts one expression to assembly *)
let rec expToAsm (e : expression) = match e with
  | Value l -> (match l with
		| Int i -> "\tpush $" ^ (string_of_int i) ^ "\n"
		| Bool b -> (match b with
			     | true ->" \tpush $1\n"
			     | false -> "\tpush $0\n")
		(* Temporarily just rounds floats down! *)
		| Float f -> "\tpush $" ^  (string_of_int (int_of_float (floor f))) ^ "\n"
		(*| Var v -> "\tpush " ^ (findVarName v (!varPositions)) ^ "(%rip)\n"*)
		| Var v -> "\tpush -" ^ (string_of_int $ findVarPos v (!varPositions2)) ^ "(%rbp)\n"
		| _ -> exit 1)

  | Plus (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_add
  | Minus (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_sub
  | Times (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_mul
  | Div (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_div						  
  | Mod (n, m) -> (expToAsm n) ^ (expToAsm m) ^ asm_mod

  | EQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_eq
  | LT (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_lt
  | GT (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_gt
  | GTEQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_gteq
  | LTEQ (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_lteq

  | Not b -> (expToAsm b) ^ asm_negate
  | And (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_and
  | Or (p, q) -> (expToAsm p) ^ (expToAsm q) ^ asm_or

  (*| AssignExp (s, e) -> (expToAsm e) ^ "\tpop " ^ (findVarName s (!varPositions)) ^ "(%rip)\n"*)
  (*| AssignExp (s, e) -> let len = (List.length !varPositions2) + 1 in
			let () = print_string "first\n" in
			let () = varPositions2 := ((s, (len * 4)) :: !varPositions2) in
			let () = print_string "second\n" in
			(expToAsm e) ^ (asm_asnVar (len * 4)) *)
  | AssignExp (s, e) -> let pos = addVar s in
			(expToAsm e) ^ (if ((List.length !varPositions2) mod 2) = 1
					then (asm_asnVarAndMakeRoom pos)
					else (asm_asnVar pos))

  | IfThenElse (b, e1, e2) -> let labelName = "l" ^ (string_of_int $ List.length !labels) in
			      let endLabel = labelName ^ "e" in
			      let jmp = "\tjmp " ^ endLabel ^ "\n" in
			      (* Note: It jumps if true, so false first, true second *)
			      (expToAsm b) ^ (asm_ite labelName) ^
				((expToAsm e2) ^ jmp) ^
				  ((labelName ^ ":\n") ^ (expToAsm e1)) ^
				    (endLabel ^ ":\n")

  (* Assumes that the variables given in xs will be pushed to the stack *)
  | Function (s, xs, p) -> let rec countLets = function
			     | [] -> 0
			     | (AssignExp _)::tl -> 1 + countLets tl
			     | hd::tl -> countLets tl in
			   let rec popVars = function
			     | [] -> ""
			     | hd::tl -> let pos = addVar hd in
					 (if ((List.length !varPositions2) mod 2) = 1
					  then (asm_asnVarAndMakeRoom pos)
					  else (asm_asnVar pos))
					 ^ popVars tl in
			   let letsAndVars = (countLets p) + (List.length xs) in 
			   let labelName = s ^ (string_of_int $ List.length !labels) in
			   let endLabel = labelName ^ "e" in
			   labels := labelName :: !labels;
                           (varPositions2 := (drop letsAndVars !varPositions2); "\tjmp ")
			   ^ endLabel ^ "\n"
			   ^ (labelName ^ ":\n")
			   ^ (popVars xs)
			   ^ "\tpush %rbp\n"
			   ^ "\tmovq %rsp, %rbp\n"
			   ^ (listExpToAsm p "")
			   ^ (deallocStackString letsAndVars) 			       
			   ^ "\tpop %rbp\n"
			   ^ "\tret\n"
			   ^ endLabel ^ ":\n"
				      
  | _ -> raise $ CompilationError "Currently unsupported expression.\n"
	      
(** Turns a list of expressions to assembly *)
and listExpToAsm (p : program) acc = match p with
  | [] -> acc
  | hd::tl -> listExpToAsm tl (acc ^ (expToAsm hd))

(** Returns a string that deallocates the memory allocated to variables currently on the stack amounting to int i *)
and deallocStackString i = "\taddq $" ^ (string_of_int
					   (16 + (16 *
						    (int_of_float
						       (((float_of_int i) /. 2.)) - 1)))) ^ ", %rsp\n"
											
(** Converts a program to assembly *)
(*let programToAsm (p : program) =
  let dataSeg = asm_dataSegment ^ (List.fold_right (fun e -> (^) (makeDataSegment e)) p "") in
  dataSeg ^ asm_prefix ^ (List.fold_right (fun e -> (^) (expToAsm e)) p "") ^ asm_suffix*)
(* Note: does not currently ignore nonesense programs such as 3 + 3 3 + 3 *)
let programToAsm (p : program) =
  asm_prefix ^ (listExpToAsm p "") ^ asm_suffix
										
		
