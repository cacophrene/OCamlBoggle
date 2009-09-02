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

let counter = ref 180

let decr_counter () =
  decr counter;
  GUI.set_remaining_time ~seconds:!counter;
  !counter > 0

let run () =
  init ();
  let t = Find.run () in
  Find.SSet.iter (fun (key, _, _) -> print_endline key) t;
  Glib.Timeout.add ~ms:1000 ~callback:decr_counter;  ()
