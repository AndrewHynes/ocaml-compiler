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

(** Contains the status of the data segment *)
let dataSeg = ref asm_dataSegment

(** Resets all of the lists (mainly for purpose of testing) *)
let purgeAllLists (u : unit) = labels := [];
			       gVarPositions := [];
			       lVarPositions := [];
			       functions := [];
			       dataSeg := asm_dataSegment;
			       u

(** Finds the position on the stack of a variable as written in the output assembly *)
let rec findVar x = function
  | [] -> raise $ CompilationError ("Variable " ^ x ^ " never initialised.\n")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVar x tl
			
(** Removes a variable from the list *)
(*let rec rmVar x = function
  | [] -> []
  | (a, b)::tl when x = a -> tl
  | hd::tl -> hd::(rmVar x tl)*)
		     

(** Gets the amount of local variables currently on the stack *)
let localVarLength l = List.length (List.filter (fun (_, n) -> n < 0) l)

(** Adds a variable to the list of local variables *)
let addLocalVar v = let len = (localVarLength !lVarPositions) + 1 in
	       lVarPositions := (v, -(len * 8)) :: !lVarPositions;
               -(len * 8)

(** Adds to the data segment of the output for each variable we need space for *)
let makeDataSegment (e : expression) = match e with
  | AssignExp (s, _) -> let name = "v" ^ (string_of_int $ List.length !gVarPositions) in
			gVarPositions := (s, name) :: !gVarPositions;
			name ^ ":\t.space 8\n"
  | _ -> ""
	   
(** Converts one expression to assembly *)
let rec expToAsm (e : expression) (b : bool) = match e with
  | Value l -> (match l with
		| Int i -> "\tpushq $" ^ (string_of_int i) ^ "\n"
		| Bool b -> (match b with
			     | true ->" \tpushq $1\n"
			     | false -> "\tpushq $0\n")
		(* Temporarily just rounds floats down! *)
		| Float f -> "\tpushq $" ^  (string_of_int (int_of_float (floor f))) ^ "\n"
		(*| Var v -> "\tpush " ^ (findVar v (!gVarPositions)) ^ "(%rip)\n"*)
		| Var v ->
		   (try
		       (let pos = findVar v (!lVarPositions) in
			("\tpushq " ^ (string_of_int $ pos) ^ "(%rbp)\n"))
		     with
		       CompilationError _ -> "\tpushq " ^ (findVar v (!gVarPositions)) ^ "(%rip)\n")
		| _ -> raise $ CompilationError "Currently unsupported expression.\n")
 
  | Plus (n, m) -> (expToAsm n b) ^ (expToAsm m b) ^ asm_add
  | Minus (n, m) -> (expToAsm n b) ^ (expToAsm m b) ^ asm_sub
  | Times (n, m) -> (expToAsm n b) ^ (expToAsm m b) ^ asm_mul
  | Div (n, m) -> (expToAsm n b) ^ (expToAsm m b) ^ asm_div	  
  | Mod (n, m) -> (expToAsm n b) ^ (expToAsm m b) ^ asm_mod

  | EQ (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_eq
  | LT (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_lt
  | GT (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_gt
  | GTEQ (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_gteq
  | LTEQ (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_lteq

  | Not p -> (expToAsm p b) ^ asm_negate
  | And (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_and
  | Or (p, q) -> (expToAsm p b) ^ (expToAsm q b) ^ asm_or

  | AssignExp (s, e) -> if b
			then
			  (try
			      ((expToAsm e b) ^ "\tpop " ^ (findVar s (!gVarPositions)) ^ "(%rip)\n")
			    with (* If it's not already in the data segment, add it *)
			      CompilationError _ ->
			      (let name = "v" ^ (string_of_int $ List.length !gVarPositions) in
			       gVarPositions := (s, name) :: !gVarPositions;
			       (dataSeg := !dataSeg ^ (name ^ ":\t.space 8\n"));
			       ((expToAsm e b) ^ "\tpop " ^ (findVar s (!gVarPositions)) ^ "(%rip)\n")))
			else (* It's a local variable *)
			  (let pos = addLocalVar s in
			   (expToAsm e b) ^ (if (((localVarLength !lVarPositions) mod 2) = 1)
					     then (asm_asnVarAndMakeRoom pos)
					     else (asm_asnVar pos)))

  | IfThenElse (p, e1, e2) -> let labelName = "l" ^ (string_of_int $ List.length !labels) in
			      let endLabel = labelName ^ "_e" in
			      let jmp = "\tjmp " ^ endLabel ^ "\n" in
			      labels := labelName :: !labels;
			      (* Note: It jumps if true, so false first, true second *)
			      (expToAsm p b) ^ (asm_ite labelName) ^
				((expToAsm e2 b) ^ jmp) ^
				  ((labelName ^ ":\n") ^ (expToAsm e1 b)) ^
				    (endLabel ^ ":\n")

  (* Assumes that the variables given in xs will be pushed to the stack *)
  | Function (s, xs, p) -> (* Ensure no conflicts in function name? *)
     let labelName = s in
     let rec countLets = function
			     | [] -> 0
			     | (AssignExp _)::tl -> 1 + countLets tl
			     | hd::tl -> countLets tl in
     let args = List.length xs in
     let rec addArgs n l = match n, l with
       | _, [] -> ()
       | n, _ when n = (args + 2) -> ()
       | n, (hd::tl) -> (* positions are reversed because stack *)
	  (lVarPositions := (hd, (((args + 3) * 8) - (n * 8))) :: !lVarPositions); addArgs (n + 1) tl in
     let endLabel = labelName ^ "_e" in
     addArgs 2 xs; 
     functions := (s, xs) :: !functions;
     labels := labelName :: !labels;
     (* Note: OCaml folds from the right, so the following is evaluated last *)
     (lVarPositions := drop args !lVarPositions; "\tjmp ")
     ^ endLabel ^ "\n"
     ^ (labelName ^ ":\n")
     ^ "\tpushq %rbp\n"
     ^ "\tmovq %rsp, %rbp\n"
     ^ (listExpToAsm p false "")
     ^ "\tpopq %rax\n"
     ^ "\tpopq %rbp\n"
     (* Variables leave scope *)
     ^ (if ((countLets p) = 0) then "" else ("\taddq $" ^ (correctVarAmount $ countLets p) ^ ", %rsp\n"))
     ^ "\tretq\n"
     ^ endLabel ^ ":\n"

  | FunCall (n, l) ->
     if (not $ exists n (List.map fst !functions))
     then (raise $ CompilationError ("Function " ^ n ^ " has not been defined.\n"))
     else (
     let args = List.length l in
     (List.fold_right (fun e -> (^) (expToAsm e b)) l "") ^
       (asm_callFunction n) ^
	 ("\taddq $" ^ (string_of_int $ 8 * args) ^ ", %rsp\n") ^
	   ("\tpushq %rax\n"))

  | _ -> raise $ CompilationError "Currently unsupported expression.\n"
	      
(** Turns a list of expressions to assembly *)
and listExpToAsm (p : program) b acc = match p with
  | [] -> acc
  | hd::tl -> listExpToAsm tl b (acc ^ (expToAsm hd b))

and correctVarAmount i = string_of_int $ (16 * (int_of_float (((float_of_int (i + 1)) /. 2.))))

(** Returns a string that deallocates the memory allocated to variables currently on the stack amounting to int i *)
and deallocStackString i = "\taddq $" ^ (correctVarAmount i) ^ ", %rsp\n"
											
(** Converts a program p to assembly. b is whether or not this is being called in global scope *)
(* Still accepts some nonsense programs such as 3 + 3 3 + 3 *)
let programToAsm (p : program) =
  let prog = (listExpToAsm p true "") in
  !dataSeg ^ asm_prefix ^ prog  ^ asm_suffix

