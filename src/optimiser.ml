(* Optimises the file 
Currently has:
* Constant folding for both numbers and booleans
*)

open Syntax


let rec isConstantsOnly (exp : expression) = match exp with
  | Value l -> (match l with
	        | Var _ -> false
	        | _ -> true)
  | Plus (n, m) -> true && isConstantsOnly n && isConstantsOnly m
  | Times (n, m) -> true && isConstantsOnly n && isConstantsOnly m
  | Minus (n, m) -> true && isConstantsOnly n && isConstantsOnly m
  | Div (n, m) -> true && isConstantsOnly n && isConstantsOnly m

  | Not b -> true && isConstantsOnly b
  | Or (b, c) -> true && isConstantsOnly b && isConstantsOnly c
  | And (b, c) -> true && isConstantsOnly b && isConstantsOnly c
							       
  | _ -> false

let rec evalLogic (exp : expression) = match exp with
  | Value l -> (match l with
		| Bool b -> b
		| _ -> exit 1 (* type error *) )
  | Not b -> not (evalLogic b)
  | Or (b, c) -> (evalLogic b) || (evalLogic c)
  | And (b, c) -> (evalLogic b) && (evalLogic c)
  | _ -> exit 1 (* type error *)

(* Note: converts to float 
   Can probably change that in the future. *)
let rec evalMaths (exp : expression) = match exp with
  | Value l -> (match l with
	        | Int i -> float_of_int i
	        | Float f -> f
		| _ -> exit 1 (* type error *) )
  | Plus (n, m) -> (evalMaths n) +. (evalMaths m)
  | Times (n, m) -> (evalMaths n) *. (evalMaths m)
  | Minus (n, m) -> (evalMaths n) -. (evalMaths m)
  | Div (n, m) -> (evalMaths n) /. (evalMaths m)
  | _ -> exit 1 (* type error *)
			    
let rec foldConstants (exp : expression) = match exp with
  (* Maths *)
  | Plus (n, m) when isConstantsOnly (Plus (n, m)) -> Value (Float (evalMaths (Plus (n, m))))
  | Plus (n, m) -> Plus (foldConstants n, foldConstants m)

  | Times (n, m) when isConstantsOnly (Times (n, m)) -> Value (Float (evalMaths (Times (n, m))))
  | Times (n, m) -> Times (foldConstants n, foldConstants m)

  | Minus (n, m) when isConstantsOnly (Minus (n, m)) -> Value (Float (evalMaths (Minus (n, m))))
  | Minus (n, m) -> Minus (foldConstants n, foldConstants m)

  | Div (n, m) when isConstantsOnly (Div (n, m)) -> Value (Float (evalMaths (Div (n, m))))
  | Div (n, m) -> Div (foldConstants n, foldConstants m)

  (* Logic *)
  | Not b when isConstantsOnly b -> Value (Bool (evalLogic (Not b)))
  | Not b -> Not (foldConstants b)

  | And (b, c) when isConstantsOnly (And (b, c)) -> Value (Bool (evalLogic (And (b, c))))
  | And (b, c) -> And (foldConstants b, foldConstants c)

  | Or (b, c) when isConstantsOnly (Or (b, c)) -> Value (Bool (evalLogic (Or (b, c))))
  | Or (b, c) -> Or (foldConstants b, foldConstants c)

  (* Folding the expressions inside expressions *)
  | PrintExp e -> PrintExp (foldConstants e)
  | AssignExp (s, e) -> AssignExp (s, foldConstants e)
  | Application (e, e2) -> Application (foldConstants e, foldConstants e2)
  | Lambda (xs, e) -> Lambda (xs, foldConstants e)
  | Function (s, xs, e) -> Function (s, xs, foldConstants e)
  | FunCall (s, es) -> FunCall (s, List.map foldConstants es)

  (* Anything else is returned as-is *)
  | x -> x
