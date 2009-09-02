(*
    args.ml - This file is part of OCamlBoggle
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

open Arg
open Printf

let grid = ref None
let size = ref 4
let time = ref 180

let set_time n =
  if n >= 2 || n < 11 then time := 60 * n
  else eprintf "(OcamlBoggle) Error: \
    Invalid time %d min replaced by 3 min.\n%!" n

let set_size n =
  if n >= 4 && n <= 6 then size := n
  else eprintf "(OCamlBoggle) Error: Bad tray size %d will be ignored.\n%!" n

let check_chars str =
  let rec loop i =
    if i < 16 then (
      let chr = Char.code str.[i] in
      (chr > 96 && chr < 123 || chr > 64 && chr < 91) && loop (i + 1)
    ) else true
  in loop 0

let set_grid s =
  if String.length s = 16 && check_chars s then 
    grid := Some (String.uppercase s)
  else eprintf "(OCamlBoggle) Invalid char sequence %S will be ignored.\n%!" s

let spec = align [
  "-n", Int set_size, " Choisir la taille de la grille (défaut : 4)";
  "-grid", String set_grid, " Choisir la grille.";
  "-time", Int set_time, " Durée d'une partie en minutes (défaut : 3 min).";
]

let anon _ = ()
let header = "\
  OCamlBoggle 1.0\n\
  Copyright (C) 2009  Edouard Evangelisti\n\
  --------------------\n\
  This program comes with ABSOLUTELY NO WARRANTY.\n\
  This is free software, and you are welcome to redistribute it\n\
  under certain conditions; see the about box for details.\n"

let usage = "Utilisation : OCamlBoggle [OPTION]..."

let parse () = 
  print_endline header;
  parse spec anon usage
