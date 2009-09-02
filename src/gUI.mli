(*
    gUI.mli - This file is part of OCamlBoggle
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

module App :
  sig
    val name : string
    val icon : GdkPixbuf.pixbuf
    val version : string
    val title : string
  end

val window : GWindow.window

module Table :
  sig
    type 'a matrix = 'a array array
    val squares : GEdit.entry matrix
    val get_grid : unit -> string matrix
    val clear : unit -> unit
    val lock : unit -> unit
    val unlock : unit -> unit
    val iter : (GEdit.entry -> unit) -> unit -> unit
  end

module type TREE_VIEW =
  sig
    val add : key:string -> word:string -> score:int -> (int * int) list -> unit
    val clear : unit -> unit
    val view : GTree.view
  end

module Words : TREE_VIEW
(*module Guesses : TREE_VIEW*)
module Missing : TREE_VIEW


val quit : GButton.button
val replay : GButton.button
val find : GButton.button

val print : ('a, unit, string, unit) format4 -> 'a
