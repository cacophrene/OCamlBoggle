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
      (** Nom de l'application. *)
    val icon : GdkPixbuf.pixbuf
      (** Icône affichée dans le systray. *)
    val version : string
      (** Numéro de version. *)
    val title : string
      (** Titre complet (c.-à-d. nom et numéro de version). *)
  end

val window : GWindow.window
  (** Fenêtre principale de l'application. *)

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

module Guesses : TREE_VIEW
  (** Mots devinés. *)

module Missing : TREE_VIEW
  (** Mots non devinés. *)

val set_remaining_time : seconds:int -> unit
  (** Temps restant avant la fin de la partie et l'affichage de la solution. *)

val guess_word : GEdit.entry
  (** Case de texte où sont saisis les mots devinés. *)
val rerun : GButton.button
  (** Nouvelle partie. *)
