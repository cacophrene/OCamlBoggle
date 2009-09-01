(*
    trie.mli - This file is part of OCamlBoggle
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

(** Le module [Trie] implémente des lexiques en OCaml. Cette implémentation est
 * purement fonctionnelle (c.-à-d. sans effets de bord) et relativement 
 * efficace.
 *
 * Benchmark (Unix.gettimeofday) sur deux listes disponibles sur le net
 *   1. Liste de 22 740 mots
 *      Chargement du dictionnaire en ASCII et UTF_8 en ~ 70 ms
 *   2. Liste de 336 531 mots
 *      Chargement du dictionnaire en ASCII et UTF_8 en ~ 800 ms
 *
 * Remarque importante : la plupart des fonctions de ce module ne sont pas
 * récursives terminales (c'est notamment vrai pour les fonction d'insertion 
 * et de suppression). Cette implémentation n'est donc par conséquent pas
 * utilisable lorsque les {i mots} sont très longs (plus de 10 000 caractères).
 *)

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

module Make : functor (Char : CHAR) -> LEXICON
  (** Foncteur pour construire de nouveaux lexiques. *)

module ASCII : LEXICON
  (** Lexique ASCII. *)
