(** Generates assembly code from a syntax tree *)

open Syntax
open AsmSnippets

exception CompilationError of string

(* Note: will probably want to be an integer in the future. *)
let labels = ref []

let varPositions = ref []
		       
let (varPositions2 : ((string * int) list) ref) = ref []

(** Finds the position in the stack of a variable as written in the output assembly *)
let rec findVarPos x = function
  | [] -> raise @@ CompilationError ("Variable " ^ x ^ " never initialised.")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVarPos x tl

(** Removes a variable from the list *)
let rec rmVar x = function
  | [] -> []
  | (a, b)::tl when x = a -> tl
  | hd::tl -> hd::(rmVar x tl)

let addVar v = let len = List.length !varPositions2 + 1 in
	       varPositions2 := (v, (len * 4)) :: !varPositions2;
               (len * 4)


(** Finds the name of a variable as written in the output assembly *)
let rec findVarName x = function
  | [] -> raise @@ CompilationError ("Variable " ^ x ^ " never initialised.")
  | (a, b)::_ when x = a -> b
  | _::tl -> findVarName x tl

(** Adds to the data segment of the output for each variable we need space for *)
let makeDataSegment (e : expression) = match e with
  | AssignExp (s, _) -> let name = "v" ^ (string_of_int @@ List.length !varPositions) in
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
		| Var v -> "\tpush " ^ (findVarName v (!varPositions)) ^ "(%rip)\n"
		(*| Var v -> print_string "Var v\n";
		   "\tpush -" ^ (string_of_int @@ findVarPos v (!varPositions2)) ^ "(%rsp)\n"*)
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

  | AssignExp (s, e) -> (expToAsm e) ^ "\tpop " ^ (findVarName s (!varPositions)) ^ "(%rip)\n"
  (*| AssignExp (s, e) -> let len = (List.length !varPositions2) + 1 in
			let () = print_string "first\n" in
			let () = varPositions2 := ((s, (len * 4)) :: !varPositions2) in
			let () = print_string "second\n" in
			(expToAsm e) ^ (asm_asnVar (len * 4)) *)
  (*| AssignExp (s, e) -> print_string "AsnExp\n";
			let pos = addVar s in
			(expToAsm e) ^ (asm_asnVar pos)*)

  | IfThenElse (b, e1, e2) -> let labelName = "l" ^ (string_of_int @@ List.length !labels) in
			      let endLabel = labelName ^ "e" in
			      let jmp = "\tjmp " ^ endLabel ^ "\n" in
			      labels := labelName :: !labels;
			      (* Note: It jumps if true, so false first, true second *)
			      (expToAsm b) ^ (asm_ite labelName) ^
				((expToAsm e2) ^ jmp) ^
				  ((labelName ^ ":\n") ^ (expToAsm e1)) ^
				    (endLabel ^ ":\n")
						    
  | _ -> exit 1

(** Converts a program to assembly *)
let programToAsm (p : program) =
  let dataSeg = asm_dataSegment ^ (List.fold_right (fun e -> (^) (makeDataSegment e)) p "") in
  dataSeg ^ asm_prefix ^ (List.fold_right (fun e -> (^) (expToAsm e)) p "") ^ asm_suffix
 (* Note: does not ignore nonesense programs such as 3 + 3 3 + 3 *)
(*let programToAsm (p : program) =
  let rec helper (p : program) = match p with
  | [] -> ""
  | hd::tl -> (match hd with
	       |AssignExp _ -> print_string "Assign\n"
	       | _ -> print_string "Not assign\n"); (expToAsm hd) ^ helper tl
  in
  asm_prefix ^ (helper p) ^ asm_suffix*)

(*
let programToAsm (p : program) =
  let dataSeg = asm_dataSegment ^ (List.fold_right (fun e -> (^) (makeDataSegment e))) in
  match p with
  | e::[] -> dataSeg ^ asm_prefix ^ (expToAsm e) ^ asm_suffix
  | _ -> print_string "Syntax error\n"; exit 1 *)
		
