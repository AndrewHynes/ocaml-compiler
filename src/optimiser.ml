(** An optimiser that optimises the parsed AST by using various techniques. *) 
open Syntax
open Helpers

(** Checks to see if an expression contains only maths *)
let rec isMathsOnly (exp : expression) = match exp with
  | Value l -> (match l with
	        | Int _ -> true
		| Float _ -> true
	        | _ -> false)
  | Plus (n, m)  -> isMathsOnly n && isMathsOnly m
  | Times (n, m) -> isMathsOnly n && isMathsOnly m
  | Minus (n, m) -> isMathsOnly n && isMathsOnly m
  | Div (n, m)   -> isMathsOnly n && isMathsOnly m
  | Mod (n, m)   -> isMathsOnly n && isMathsOnly m
							       
  | _ -> false
	   
(** Checks to see if an expression contains only logic *)
let rec isLogicOnly (exp : expression) = match exp with
  | Value l -> (match l with
	        | Bool _ -> true
	        | _ -> false)
		 
  | Not b -> isLogicOnly b
  | Or (b, c) -> isLogicOnly b && isLogicOnly c
  | And (b, c) -> isLogicOnly b && isLogicOnly c

  | EQ (n, m)   -> isMathsOnly n && isMathsOnly m
  | LT (n, m)   -> isMathsOnly n && isMathsOnly m
  | GT (n, m)   -> isMathsOnly n && isMathsOnly m
  | LTEQ (n, m) -> isMathsOnly n && isMathsOnly m
  | GTEQ (n, m) -> isMathsOnly n && isMathsOnly m

  | _ -> false
	   
(** Evaluates a constant expression containing only maths *)
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

	      

(** Evaluates a constant expression containing only logic *)
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

(** True if the expression is constant, false otherwise *)
let isConstOnly e = isLogicOnly e || isMathsOnly e

(** 'Folds' the constants in a single expression, and performs optimisations such as:

- Replaces maths with constants (e.g. replaces 3 + 3 with 6)

- Replaces boolean expressions with constants (e.g. replaces !false with true)

- Replaces if-then-else statements with the correct branch if the boolean is not dependent on variables

- Does this recursively and fully optimises the AST (for example, it would simplify the expression (lambda _ -> lambda _ -> 6) to (lambda _ -> lambda _ -> 6) *)
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
  | Function (s, xs, p) -> Function (s, xs, List.map foldConstants p)
  | FunCall (s, es) -> FunCall (s, List.map foldConstants es)

  (* Anything else is returned as-is *)
  | x -> x

(** Checks to see if an expression contains a given variable *)
let rec expContainsVar v = function
  | Value l -> (match l with
	       | Var s -> s = v
	       | _ -> false)

  | Plus (n, m) -> expContainsVar v n || expContainsVar v m
  | Times (n, m) -> expContainsVar v n || expContainsVar v m
  | Minus (n, m) -> expContainsVar v n || expContainsVar v m
  | Div (n, m) -> expContainsVar v n || expContainsVar v m
  | Mod (n, m) -> expContainsVar v n || expContainsVar v m
  | Not b -> expContainsVar v b
  | And (b, c) -> expContainsVar v b || expContainsVar v c
  | Or (b, c) -> expContainsVar v b || expContainsVar v c
  | EQ (b, c) -> expContainsVar v b || expContainsVar v c
  | LT (b, c) -> expContainsVar v b || expContainsVar v c
  | GT (b, c) -> expContainsVar v b || expContainsVar v c
  | LTEQ (b, c) -> expContainsVar v b || expContainsVar v c
  | GTEQ (b, c) -> expContainsVar v b || expContainsVar v c
  | IfThenElse (b, e1, e2) -> expContainsVar v b || expContainsVar v e1 || expContainsVar v e2

  | PrintExp e -> expContainsVar v e
  | Application (e, e2) -> expContainsVar v e || expContainsVar v e2
  | AssignExp (s, e) -> expContainsVar v e
  | Lambda (xs, e) -> expContainsVar v e && (not (exists v xs))
  | Function (s, xs, p) -> (List.fold_right (fun x -> (||) (expContainsVar v x)) p false) && (not (exists v xs))
  | FunCall (s, es) -> List.fold_right (fun e -> (||) (expContainsVar v e)) es false
					
  | _ -> false

(** Checks if a list of expressions contains a variable *)
let lexpContainsVar v ls = List.fold_right (fun e -> (||) (expContainsVar v e)) ls false

(** Propagates a constant variable through an expression

To propagate x = 3, one would call

propagateExp "x" (Value (Int 3)) e *) 
let rec propagateExp (v : string) (ve : expression) = function
  | Value l -> (match l with
	       | Var s when v = s -> ve
	       | x -> Value l)
    
  | Plus (n, m) -> Plus (propagateExp v ve n, propagateExp v ve m)
  | Times (n, m) -> Times (propagateExp v ve n, propagateExp v ve m)
  | Minus (n, m) -> Minus (propagateExp v ve n, propagateExp v ve m)
  | Div (n, m) -> Div (propagateExp v ve n, propagateExp v ve m)
  | Mod (n, m) -> Mod (propagateExp v ve n, propagateExp v ve m)
  | Not b -> Not (propagateExp v ve b)
  | And (b, c) -> And (propagateExp v ve b, propagateExp v ve c)
  | Or (b, c) -> Or (propagateExp v ve b, propagateExp v ve c)
  | EQ (b, c) -> EQ (propagateExp v ve b, propagateExp v ve c)
  | LT (b, c) -> LT (propagateExp v ve b, propagateExp v ve c)
  | GT (b, c) -> GT (propagateExp v ve b, propagateExp v ve c)
  | LTEQ (b, c) -> LTEQ (propagateExp v ve b, propagateExp v ve c)
  | GTEQ (b, c) -> GTEQ (propagateExp v ve b, propagateExp v ve c)
  | IfThenElse (b, e1, e2) -> IfThenElse (propagateExp v ve b, propagateExp v ve e1, propagateExp v ve e2)
					 
  | PrintExp e -> PrintExp (propagateExp v ve e)
  | Application (e, e2) -> Application (propagateExp v ve e, propagateExp v ve e2)
  | AssignExp (s, e) -> AssignExp (s, propagateExp v ve e)
				  
  | Lambda (xs, e) -> if (not (exists v xs))
		      then Lambda (xs, propagateExp v ve e)
		      else Lambda (xs, e)

  | Function (s, xs, p) -> if (not (exists v xs))
			   then (* Note: The following has been done to cover cases such as
                                   let x = 3;
                                   func f y = { let x = 4; x + y } *)
			     (* Gets the first assignment statement assigning to the
			        same name as the variable we're trying to propagate *)
			     let rec findFirstAssign acc v = function
			       | [] -> -1
			       | (AssignExp (s, _))::tl when s = v -> acc 
			       | hd::tl -> findFirstAssign (acc + 1) v tl in
                             let pos = findFirstAssign 0 v p in
			     if pos = -1
			     then Function (s, xs, List.map (propagateExp v ve) p)
			     else Function (s, xs, (propagateConst v ve (take pos p)) @
						      (propagateConstants @@ drop pos p))
			   else Function (s, xs, propagateConstants p)

  | FunCall (s, es) -> FunCall (s, List.map (propagateExp v ve) es)

  | x -> x

(** Propagates a given constant throughout the program *)
and propagateConst v e (p : program) = match p with
  | [] -> []
  | hd::tl -> foldConstants (propagateExp v e hd) :: propagateConst v e tl

(** Removes unused variables and propagates constants *)
and propagateConstants (p : program) = match p with
  | [] -> []
  | hd::tl -> (match hd with
	       | AssignExp (s, e) -> if (not (lexpContainsVar s tl))
				     then propagateConstants tl
				     else (if isConstOnly e
					   then propagateConstants (propagateConst s e tl) 
					   else hd::propagateConstants tl)
	       | x -> x::propagateConstants tl)

(** Fully optimises a program with every optimisation it can do. Includes:

- Constant folding

- Constant propagation

- Removing unused variables *)
let optimise p = propagateConstants (List.map foldConstants p)


  
