(*
    trie.ml - This file is part of OCamlBoggle
    Copyright (C) 2009  Edouard Evangelisti

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*)

open Printf

module type CHAR =
  sig
    type t
    val compare : t -> t -> int
    val explode : string -> t list
    val rev_implode : t list -> string
  end

module type LEXICON = 
  sig
    type 'a t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val add : string -> 'a -> 'a t -> 'a t
    val get : string -> 'a t -> 'a
    val mem : string -> 'a t -> bool
    val mem_prefix : string -> 'a t -> bool
    val remove : string -> 'a t -> 'a t
    val length : 'a t -> int
    val sub : string -> 'a t -> 'a t
    val iter : (string -> 'a -> unit) -> 'a t -> unit
    val of_list : string list -> 'a list -> 'a t
    val to_list : 'a t -> (string * 'a) list
  end

module Make(Char : CHAR) : LEXICON =
  struct
    module CMap = Map.Make(Char)

    let dummy : Char.t = Obj.magic ()

    type 'a t = { flag : 'a option; cmap : 'a t CMap.t }

    let empty = { flag = None; cmap = CMap.empty }
    let is_empty t = t.flag = None && CMap.is_empty t.cmap

    let default chr cmap = try CMap.find chr cmap with Not_found -> empty

    let add str dat t =
      let rec loop t = function
        | [] -> { t with flag = Some dat }
        | chr :: l -> let res = loop (default chr t.cmap) l in
          { t with cmap = CMap.add chr res t.cmap }
      in loop t (Char.explode str)

    let mem str t =
      let rec loop t = function
        | [] -> t.flag <> None
        | chr :: l when CMap.mem chr t.cmap -> loop (CMap.find chr t.cmap) l
        | _ -> false
      in loop t (Char.explode str) 

    let get str t =
      let rec loop t = function
        | [] -> (match t.flag with Some dat -> dat | _ -> raise Not_found)
        | chr :: l when CMap.mem chr t.cmap -> loop (CMap.find chr t.cmap) l
        | _ -> raise Not_found
      in loop t (Char.explode str) 

    let mem_prefix str t =
      if String.length str > 0 then (
        let rec loop t = function
          | [] -> true
          | chr :: l when CMap.mem chr t.cmap -> loop (CMap.find chr t.cmap) l
          | _ -> false
        in loop t (Char.explode str) 
      ) else false

    let remove str t =
      let rec loop t = function
        | [] -> { t with flag = None }
        | chr :: l when CMap.mem chr t.cmap -> 
          let res = loop (CMap.find chr t.cmap) l in
          { t with cmap = (if is_empty res then CMap.remove chr 
            else CMap.add chr res) t.cmap }
        | _ -> t
      in loop t (Char.explode str)

    (* Cette version est plus rapide que celle à base de CMap.fold.
     * Test: 1000 appels avec un trie de 20 576 éléments (bytecode).
     * Version CMap.fold (fun _ -> loop) : 11 s
     * Version CMap.fold loop avec dummy :  9 s
     * Version CMap.iter avec référence : 8.5 s *)
    let length t =
      let res = ref 0 in
      let rec loop _ t =
        if t.flag <> None then incr res;
        CMap.iter loop t.cmap;
      in loop dummy t; !res

    let sub str t =
      let rec loop t = function
        | [] -> t
        | chr :: l when CMap.mem chr t.cmap -> { flag = None; 
          cmap = CMap.add chr (loop (CMap.find chr t.cmap) l) CMap.empty }
        | _ -> raise Not_found
      in loop t (Char.explode str)

    let iter f =
      let rec loop seq t =
        begin match t.flag with
          | Some dat -> f (Char.rev_implode seq) dat
          | _ -> ()
        end;
        CMap.iter (fun chr -> loop (chr :: seq)) t.cmap
      in loop []

    let of_list l1 l2 =
      let rec loop t = function
        | [], [] -> t
        | str :: l1, dat :: l2 -> loop (add str dat t) (l1, l2)
        | _ -> invalid_arg "Trie.of_list"
      in loop empty (l1, l2)

    let to_list t =
      let rec loop seq t l =
        CMap.fold (fun chr -> loop (chr :: seq)) t.cmap 
        (match t.flag with Some dat -> (Char.rev_implode seq, dat) :: l | _ -> l)
      in List.rev (loop [] t [])
  end

module ASCII : LEXICON = Make (
  struct
    type t = int
    let compare = compare

    let explode str = 
      let rec loop res = function
        | 0 -> res
        | i -> let j = i - 1 in
          loop (Char.code (String.unsafe_get str j) :: res) j
      in loop [] (String.length str)

    let rev_implode =
      let buf = Buffer.create 16 in
      function l ->
        let rec loop = function
          | [] -> Buffer.reset buf
          | n :: l -> loop l;
            Buffer.add_char buf (Char.chr n)
        in loop l;
        Buffer.contents buf
  end
)
