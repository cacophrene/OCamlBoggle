(*
    play.ml - This file is part of OCamlBoggle
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

let dice_matrix = [|
  [|"O"; "T"; "A"; "E"; "I"; "A"|];
  [|"O"; "N"; "E"; "S"; "D"; "T"|];
  [|"U"; "L"; "I"; "W"; "R"; "E"|];
  [|"A"; "B"; "I"; "L"; "R"; "T"|];
  [|"Z"; "N"; "A"; "D"; "E"; "V"|];
  [|"I"; "S"; "E"; "H"; "R"; "N"|];
  [|"M"; "B"; "Q"; "J"; "O"; "A"|];
  [|"N"; "L"; "U"; "E"; "G"; "Y"|];
  [|"E"; "E"; "S"; "I"; "H"; "F"|];
  [|"G"; "E"; "N"; "I"; "V"; "T"|];
  [|"U"; "N"; "T"; "O"; "E"; "K"|];
  [|"M"; "R"; "I"; "S"; "A"; "O"|];
  [|"P"; "D"; "C"; "E"; "M"; "A"|];
  [|"R"; "L"; "A"; "S"; "E"; "C"|];
  [|"T"; "U"; "E"; "S"; "P"; "L"|];
  [|"X"; "F"; "A"; "R"; "I"; "O"|];
|]

let init () =
  Random.self_init ();
  GUI.Table.iter (
    function entry ->
      entry#set_text dice_matrix.(Random.int 16).(Random.int 6)
  ) ()

let max = ref 0
let score = ref 0
let counter = ref 180
let solution = ref Find.SSet.empty

let show_missing () =
  Find.SSet.iter (fun (key, pos, l) -> 
    let word = Find.string_of_list l in
    let score = Find.score_of_string key in
    GUI.Missing.add ~key ~word ~score pos;
  ) !solution


let decr_counter () =
  decr counter;
  GUI.set_remaining_time ~seconds:!counter;
  if !counter = 0 then show_missing ();
  !counter > 0



let check_guessed_word t =
  if GdkEvent.Key.keyval t = 65293 then (
    let str = GUI.guess_word#text in
    begin try
      Find.SSet.iter (fun ((key, pos, l) as tpl) -> 
        if key = str then (
          let word = Find.string_of_list l in
          let sc = Find.score_of_string key in
          score := !score + sc;
          GUI.set_score ~max:!max !score;
          GUI.Guesses.add ~select:true ~key ~word ~score:sc pos;
          solution := Find.SSet.remove tpl !solution;
          raise Exit;
        )
      ) !solution;
    with Exit -> GUI.guess_word#set_text "" end;
    true
  ) else false

let run () =
  init ();
  solution := Find.run ();
  max := Find.SSet.fold (fun (key, _, _) n -> n + Find.score_of_string key) !solution 0;
  GUI.set_score ~max:!max 0;
  Glib.Timeout.add ~ms:1000 ~callback:decr_counter;  ()
