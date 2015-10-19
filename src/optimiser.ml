(* Optimises the file 
Currently has:
* Constant folding for both numbers and booleans
*)

open Syntax


let rec isMathsOnly (exp : expression) = match exp with
  | Value l -> (match l with
	        | Int _ -> true
		| Float _ -> true
	        | _ -> false)
  | Plus (n, m) -> true && isMathsOnly n && isMathsOnly m
  | Times (n, m) -> true && isMathsOnly n && isMathsOnly m
  | Minus (n, m) -> true && isMathsOnly n && isMathsOnly m
  | Div (n, m) -> true && isMathsOnly n && isMathsOnly m
  | Mod (n, m) -> true && isMathsOnly n && isMathsOnly m
							       
  | _ -> false
	   
let rec isLogicOnly (exp : expression) = match exp with
  | Value l -> (match l with
	        | Bool _ -> true
	        | _ -> false)
		 
  | Not b -> true && isLogicOnly b
  | Or (b, c) -> true && isLogicOnly b && isLogicOnly c
  | And (b, c) -> true && isLogicOnly b && isLogicOnly c

  | EQ (n, m) -> true && isMathsOnly n && isMathsOnly m
  | LT (n, m) -> true && isMathsOnly n && isMathsOnly m
  | GT (n, m) -> true && isMathsOnly n && isMathsOnly m
  | LTEQ (n, m) -> true && isMathsOnly n && isMathsOnly m
  | GTEQ (n, m) -> true && isMathsOnly n && isMathsOnly m

  | _ -> false
	   
(* Note: converts to float 
   May change that in the future. *)
let rec evalMaths (exp : expression) = match exp with
  | Value l -> (match l with
	        | Int i -> float_of_int i
	        | Float f -> f
		| _ -> exit 1 (* Something bad happened *) )
  | Plus (n, m) -> (evalMaths n) +. (evalMaths m)
  | Times (n, m) -> (evalMaths n) *. (evalMaths m)
  | Minus (n, m) -> (evalMaths n) -. (evalMaths m)
  | Div (n, m) -> (evalMaths n) /. (evalMaths m)				     
  | Mod (n, m) -> mod_float (evalMaths n) (evalMaths m)
  | _ -> exit 1 (* Something bad happened *)

let rec evalLogic (exp : expression) = match exp with
  | Value l -> (match l with
		| Bool b -> b
		| _ -> exit 1 (* Something bad happened *) )
		 
  | Not b -> not (evalLogic b)
  | Or (b, c) -> (evalLogic b) || (evalLogic c)
  | And (b, c) -> (evalLogic b) && (evalLogic c)

  | EQ (n, m) -> (evalMaths n) = (evalMaths m)
  | LT (n, m) -> (evalMaths n) < (evalMaths m)
  | GT (n, m) -> (evalMaths n) > (evalMaths m)
  | LTEQ (n, m) -> (evalMaths n) <= (evalMaths m)
  | GTEQ (n, m) -> (evalMaths n) >= (evalMaths m)
				   
				     
  | _ -> exit 1 (* Something bad happened *)
		    
let rec foldConstants (exp : expression) = match exp with
  (* Maths *)
  | Plus (n, m) when isMathsOnly (Plus (n, m)) -> Value (Float (evalMaths (Plus (n, m))))
  | Plus (n, m) -> Plus (foldConstants n, foldConstants m)

  | Times (n, m) when isMathsOnly (Times (n, m)) -> Value (Float (evalMaths (Times (n, m))))
  | Times (n, m) -> Times (foldConstants n, foldConstants m)

  | Minus (n, m) when isMathsOnly (Minus (n, m)) -> Value (Float (evalMaths (Minus (n, m))))
  | Minus (n, m) -> Minus (foldConstants n, foldConstants m)

  | Div (n, m) when isMathsOnly (Div (n, m)) -> Value (Float (evalMaths (Div (n, m))))
  | Div (n, m) -> Div (foldConstants n, foldConstants m)

  | Mod (n, m) when isMathsOnly (Mod (n, m)) -> Value (Float (evalMaths (Mod (n, m))))
  | Mod (n, m) -> Mod (foldConstants n, foldConstants m)

  (* Logic *)
  | Not b when isLogicOnly b -> Value (Bool (evalLogic (Not b)))
  | Not b -> Not (foldConstants b)

  | And (b, c) when isLogicOnly (And (b, c)) -> Value (Bool (evalLogic (And (b, c))))
  | And (b, c) -> And (foldConstants b, foldConstants c)

  | Or (b, c) when isLogicOnly (Or (b, c)) -> Value (Bool (evalLogic (Or (b, c))))
  | Or (b, c) -> Or (foldConstants b, foldConstants c)

  | EQ (b, c) when isLogicOnly (EQ (b, c)) -> Value (Bool (evalLogic (EQ (b, c))))
  | EQ (b, c) -> EQ (foldConstants b, foldConstants c)

  | LT (b, c) when isLogicOnly (LT (b, c)) -> Value (Bool (evalLogic (LT (b, c))))
  | LT (b, c) -> LT (foldConstants b, foldConstants c)

  | GT (b, c) when isLogicOnly (GT (b, c)) -> Value (Bool (evalLogic (GT (b, c))))
  | GT (b, c) -> GT (foldConstants b, foldConstants c)

  | LTEQ (b, c) when isLogicOnly (LTEQ (b, c)) -> Value (Bool (evalLogic (LTEQ (b, c))))
  | LTEQ (b, c) -> LTEQ (foldConstants b, foldConstants c)

  | GTEQ (b, c) when isLogicOnly (GTEQ (b, c)) -> Value (Bool (evalLogic (GTEQ (b, c))))
  | GTEQ (b, c) -> GTEQ (foldConstants b, foldConstants c)

  (* Conditionals/Flow *)
  | IfThenElse (b, e1, e2) when isLogicOnly b -> if evalLogic b
						 then e1
						 else e2

  (* Folding the expressions inside expressions *)
  | PrintExp e -> PrintExp (foldConstants e)
  | AssignExp (s, e) -> AssignExp (s, foldConstants e)
  | Application (e, e2) -> Application (foldConstants e, foldConstants e2)
  | Lambda (xs, e) -> Lambda (xs, foldConstants e)
  | Function (s, xs, e) -> Function (s, xs, foldConstants e)
  | FunCall (s, es) -> FunCall (s, List.map foldConstants es)

  (* Anything else is returned as-is *)
  | x -> x
