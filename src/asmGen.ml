(** Generates assembly code from a syntax tree *)

open Syntax
open AsmSnippets
open Helpers

exception CompilationError of string

(* Note: will probably want to be an integer in the future. *)
(** Keeps a list of all of the labels used (for use with branch instructions) *)
let labels = ref []

(** Keeps position of global variables (may be obsolete soon) *)
let gVarPositions = ref []

(** Keeps the position of local variables *)
let lVarPositions = ref []

(** Contains information about user-defined functions *)
let functions = ref []

(** Resets all of the lists (mainly for purpose of testing) *)
let purgeAllLists (u : unit) = labels := [];
			       gVarPositions := [];
			       lVarPositions := [];
			       functions := [];
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
let addLocalVar v = let len = List.length (List.filter (fun (_, n) -> n < 0) !lVarPositions) + 1 in
	       lVarPositions := (v, -(len * 8)) :: !lVarPositions;
               -(len * 8)

(** Finds the name of a variable as written in the output assembly *)
let rec findVarName x = function
  | [] -> raise $ CompilationError ("Variable " ^ x ^ " never initialised.\n")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVarName x tl

(** Adds to the data segment of the output for each variable we need space for *)
let makeDataSegment (e : expression) = match e with
  | AssignExp (s, _) -> let name = "v" ^ (string_of_int $ List.length !gVarPositions) in
			gVarPositions := (s, name) :: !gVarPositions;
			name ^ ":\t.space 8\n"
  | _ -> ""
	   
(** Converts one expression to assembly *)
let rec expToAsm (e : expression) = match e with
  | Value l -> (match l with
		| Int i -> "\tpushq $" ^ (string_of_int i) ^ "\n"
		| Bool b -> (match b with
			     | true ->" \tpushq $1\n"
			     | false -> "\tpushq $0\n")
		(* Temporarily just rounds floats down! *)
		| Float f -> "\tpushq $" ^  (string_of_int (int_of_float (floor f))) ^ "\n"
		(*| Var v -> "\tpush " ^ (findVarName v (!gVarPositions)) ^ "(%rip)\n"*)
		| Var v -> "\tpushq " ^ (string_of_int $ findVarPos v (!lVarPositions)) ^ "(%rbp)\n"
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

  | AssignExp (s, e) -> let pos = addLocalVar s in
			(expToAsm e) ^ (if ((List.length !lVarPositions) mod 2) = 1
					then (asm_asnVarAndMakeRoom pos)
					else (asm_asnVar pos))

  | IfThenElse (b, e1, e2) -> let labelName = "l" ^ (string_of_int $ List.length !labels) in
			      let endLabel = labelName ^ "_e" in
			      let jmp = "\tjmp " ^ endLabel ^ "\n" in
			      labels := labelName :: !labels;
			      (* Note: It jumps if true, so false first, true second *)
			      (expToAsm b) ^ (asm_ite labelName) ^
				((expToAsm e2) ^ jmp) ^
				  ((labelName ^ ":\n") ^ (expToAsm e1)) ^
				    (endLabel ^ ":\n")

  (* Assumes that the variables given in xs will be pushed to the stack *)
  | Function (s, xs, p) -> (* Ensure no conflicts here? *)
     let labelName = s in
     let args = List.length xs in
     let rec addArgs n l = match n, l with
       | _, [] -> ()
       | n, _ when n = (args + 2) -> ()
       | n, (hd::tl) ->
	  (lVarPositions := (hd, (n * 8)) :: !lVarPositions); addArgs (n + 1) tl in
     let endLabel = labelName ^ "_e" in
     addArgs 2 xs; (* note: need to remove these from list afterwards *)
     functions := (s, xs) :: !functions;
     labels := labelName :: !labels;
     (* Note: OCaml folds from the right, so the following is evaluated last *)
     (lVarPositions := drop args !lVarPositions; "\tjmp ")
     ^ endLabel ^ "\n"
     ^ (labelName ^ ":\n")
     ^ "\tpushq %rbp\n"
     ^ "\tmovq %rsp, %rbp\n"
     ^ (listExpToAsm p "")
     ^ "\tpopq %rax\n"
     ^ "\tpopq %rbp\n"
     ^ "\tretq\n"
     ^ endLabel ^ ":\n"

  | FunCall (n, l) ->
     let args = List.length l in
     (List.fold_right (fun e -> (^) (expToAsm e)) l "") ^
       (asm_callFunction n) ^
	 ("\taddq $" ^ (string_of_int $ 8 * args) ^ ", %rsp\n") ^
	   ("\tpushq %rax\n")

  | _ -> raise $ CompilationError "Currently unsupported expression.\n"
	      
(** Turns a list of expressions to assembly *)
and listExpToAsm (p : program) acc = match p with
  | [] -> acc
  | hd::tl -> listExpToAsm tl (acc ^ (expToAsm hd))

and correctVarAmount i = string_of_int $ (16 * (int_of_float (((float_of_int (i + 1)) /. 2.))))

(** Returns a string that deallocates the memory allocated to variables currently on the stack amounting to int i *)
and deallocStackString i = "\taddq $" ^ (correctVarAmount i) ^ ", %rsp\n"
											
(** Converts a program to assembly *)
(*let programToAsm (p : program) =
  let dataSeg = asm_dataSegment ^ (List.fold_right (fun e -> (^) (makeDataSegment e)) p "") in
  dataSeg ^ asm_prefix ^ (List.fold_right (fun e -> (^) (expToAsm e)) p "") ^ asm_suffix*)
(* Note: does not currently ignore nonesense programs such as 3 + 3 3 + 3 *)
let programToAsm (p : program) =
  asm_prefix ^ (listExpToAsm p "") ^ asm_suffix
										
		
(*
  | FunCall (n, l) -> (* TODO: ensure the function n exists *)
     let args = List.length l in
     ("\tsubq $" ^ (correctVarAmount args) ^ ", %rsp\n") ^
       ((List.fold_right (fun e -> (^) ((expToAsm e) ^ "\n\tpopq 0(%rsp)\n")) l "") ) ^
	 ("\taddq $" ^ (correctVarAmount args) ^ ", %rsp\n")
	 ^ callFunction n

  | FunCall (n, l) ->
     let args = List.length l in
     (*let rec pushArgs n l = match n, l with
       | _, [] -> ""
       | n, _ when n = (args + 1) -> ""
       | n, (hd::tl) -> "\tpopq " ^ (string_of_int (n * 8)) ^ "(%rsp)\n" ^ pushArgs (n + 1) tl in*)
     (try
	 (let argNames = snd $ List.find (fun (a, _) -> a = n) !functions in
	  ((*("\tsubq $" ^ (correctVarAmount args) ^ ", %rsp\n") ^*)
	   (List.fold_right (fun e -> (^) (expToAsm e)) l "") ^
	     (*(pushArgs 1 argNames) ^*)
	       (asm_callFunction n) ^
		 ("\taddq $" ^ (string_of_int $ 8 * args) ^ ", %rsp\n")) ^
	           ("\tpushq %rax\n"))
	  with
	    Not_found -> raise $ CompilationError ("Function " ^ n ^ " never defined.\n"))


	   
 *)


				       (*let rec countLets = function
			     | [] -> 0
			     | (AssignExp _)::tl -> 1 + countLets tl
			     | hd::tl -> countLets tl in*)
     					 (*(if ((List.length !lVarPositions) mod 2) = 1
					  then (asm_asnVarAndMakeRoom pos)
					  else (asm_asnVar pos))*)
			   (*let rec popVars n = function
			     | [] -> ""
			     | hd::tl -> asm_getVarFromPos n
					 ^ popVars (n + 8) tl in*)
			   (*let rec getVar n = function
			     | [] -> ""
			     | hd::tl -> if (List.mem hd xs)
					 asm_getVarFromPos n
					    ^ popVars (n + 8) tl in*)
			   (*let letsAndVars = (countLets p) + (List.length xs) in*)
