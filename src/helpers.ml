(** Contains a selection of useful helper functions that are used throughout the project *)


(** Helper function to see if something exists in a list *)
let exists x xs = (List.length @@ List.filter (fun y -> y = x) xs) >= 1

(** Helper function that safely gets the tail of a list *)
let tail = function
    | [] -> []
    | hd::tl -> tl

(** Helper function that drops n elements from the front of a list *)
let rec drop n xs = match n with
  | n when n <= 0 -> xs
  | n -> drop (n - 1) (tail xs)

(** Helper function that takes the first n elements from the front of a list *)
let rec take n xs = match xs with
  | [] -> []
  | _ when n <= 0 -> []
  | hd::tl -> hd::(take (n - 1) tl)

(** Haskell style $ *)
let ($) = (@@)


	    
