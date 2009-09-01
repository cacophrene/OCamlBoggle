(*
    find.ml - This file is part of OCamlBoggle
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

let t : string list Trie.ASCII.t = 
  let ich = open_in "OCAMLBOGGLE-DATABASE" in
  let tm1 = Unix.gettimeofday () in
  let lex = input_value ich in
  let tm2 = Unix.gettimeofday () in
  close_in ich;
  GUI.print "Lexique : %d entrées chargées en %.3f s." 
    (Trie.ASCII.length lex) (tm2 -. tm1);
  lex

module Algo =
  struct
    type dir = N | S | E | W | NE | NW | SE | SW
    type square = { text : string; mutable flag : bool }

    let square_of_string s = { text = s; flag = true }

    let dirs = [N; S; E; W; NE; NW; SE; SW]
    let is_valid t x y = 
         x >= 0 
      && x < !Args.size
      && y >= 0 
      && y < !Args.size 
      && t.(x).(y).flag

    let move x y = function
      | N  -> x, y + 1
      | S  -> x, y - 1
      | E  -> x + 1, y
      | W  -> x - 1, y
      | NE -> x + 1, y + 1
      | NW -> x - 1, y + 1
      | SE -> x + 1, y - 1
      | SW -> x - 1, y - 1

    let score_of_string str =
      match String.length str with
      | n when n < 5 -> 1 
      | 5 -> 2
      | 6 -> 3
      | 7 -> 5
      | _ -> 11

    module SSet = Set.Make (
      struct
        type t = string * (int * int) list * string list
        let compare (x, _, _) (y, _, _) =
          let lx = String.length x and ly = String.length y in
          if lx = ly then compare x y else compare ly lx
      end 
    )

    let find_words tbl set x y =
      let rec may_add seq str set i j =
        let sq = tbl.(i).(j) in sq.flag <- false;
        let set' = List.fold_left (may_run seq tbl i j str) (
          if Trie.ASCII.mem str t && String.length str > 2 then
            SSet.add (str, seq, Trie.ASCII.get str t) set
          else set
        ) dirs in sq.flag <- true; set'
      and may_run seq tbl i j str set dir = 
        let i', j' as cpl = move i j dir in 
        if is_valid tbl i' j' then (
          let str' = sprintf "%s%s" str tbl.(i').(j').text in
          if Trie.ASCII.mem_prefix str' t then may_add (cpl :: seq) str' set i' j' 
          else set
        ) else set
    in may_add [x, y] tbl.(x).(y).text set x y         

    let string_of_list =
      let buf = Buffer.create 16 in
      function l ->
        Buffer.clear buf;
        List.iter (fun x -> 
          if Buffer.length buf > 0 then Buffer.add_string buf ", ";
          Buffer.add_string buf x;
        ) l;
        Buffer.contents buf

    let show set tm1 tm2 =
      GUI.Table.lock ();
      let count, score = SSet.fold (fun (key, seq, dat) (count, score) ->
        let s = score_of_string key in
        GUI.Words.add ~key ~word:(string_of_list dat) ~score:s seq;
        count + 1, score + s
      ) set (0, 0) in
      let tm3 = Unix.gettimeofday () in 
      GUI.print "Solution : %d mot(s), %d point(s). Temps de calcul : %.3f s; \
        Temps d'affichage : %.3f." count score 
        (tm2 -. tm1) (tm3 -. tm2)

    let run () =
      GUI.Words.clear ();
      let tbl = Array.map (Array.map square_of_string) 
        (GUI.Table.get_grid ()) in
      let rec select_root x y set =
        if x < !Args.size then 
          select_root 
            (x + if y = !Args.size - 1 then 1 else 0) 
            ((y + 1) mod !Args.size) 
            (find_words tbl set x y)
        else set in
      let tm1 = Unix.gettimeofday () in
      let set = select_root 0 0 SSet.empty in
      let tm2 = Unix.gettimeofday () in
      show set tm1 tm2
  end

let run = Algo.run
