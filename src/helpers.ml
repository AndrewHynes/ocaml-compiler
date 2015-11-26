(** Contains a selection of useful helper functions that are used throughout the project *)


(** Helper function to see if something exists in a list *)
let exists x xs = (List.length @@ List.filter (fun y -> y = x) xs) >= 1

(** Helper function that safely gets the tail of a list *)
let tail = function
    | [] -> []
    | hd::tl -> tl

(** Helper function that deletes the first occurence of some element in a list *)
let rec delete elem = function
  | [] -> []
  | hd::tl when hd = elem -> tl
  | hd::tl -> hd::(delete elem tl)
		
(** Helper function that drops n elements from the front of a list *)
let rec drop n xs = match n with
  | n when n <= 0 -> xs
  | n -> drop (n - 1) (tail xs)

(** Helper function that takes the first n elements from the front of a list *)
let rec take n xs = match xs with
  | [] -> []
  | _ when n <= 0 -> []
  | hd::tl -> hd::(take (n - 1) tl)

(** Helper function that zips two lists together *)
let rec zip l ls = match l, ls with
  | [], [] -> []
  | _, [] -> []
  | [], _ -> []
  | x::xs, y::ys -> (x, y) :: zip xs ys

(** Haskell style $ *)
let ($) = (@@)


	    
	    (*
while (let x = 1) x < 10 { while (let y = 10) y > 0 { print x + y; loopWith y - 1} loopWith x + 1 }

while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1} loopWith x + 1 }

while (let x = 1) x < 10 { while (let y = 1) !(y == 1) { print x + y; loopWith y - 1} print x; loopWith x + 1 }

while (let x = 0) x <= 10 { print x; loopWith x + 1 }

 *)
