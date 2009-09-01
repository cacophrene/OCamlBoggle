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

open Printf

let size = ref 4

let set_size n =
  if n >= 4 && n <= 6 then size := n
  else eprintf "(OCamlBoggle) Error: Bad tray size %d will be ignored.\n%!" n


open Arg

let spec = align [
  "-n", Int set_size, " Choisir la taille de la grille (défaut : 4)"
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
