(*
    gUI.ml - This file is part of OCamlBoggle
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

let _ = GMain.init (); Args.parse ()

module App =
  struct
    let name = "OCamlBoggle"
    let icon = GdkPixbuf.from_file "ocamlboggle-icon.png"
    let version = "1.1"
    let title = name ^ " " ^ version
  end

let window = 
  let wnd = GWindow.window
    ~title:App.title
    ~icon:App.icon
    ~resizable:false
    ~position:`CENTER () in
  wnd#connect#destroy ~callback:GMain.quit;
  wnd

let status_icon = GMisc.status_icon_from_pixbuf App.icon

let vbox = GPack.vbox
  ~spacing:5 
  ~border_width:5
  ~packing:window#add () 

let hbox = GPack.hbox
  ~spacing:5
  ~packing:vbox#add () 

module Table =
  struct
    type 'a matrix = 'a array array

    let container = GPack.table
      ~rows:!Args.size
      ~columns:!Args.size
      ~row_spacings:5
      ~col_spacings:5
      ~homogeneous:true
      ~packing:hbox#add ()

    let len = 80

    let squares =
      Array.init !Args.size (fun top ->
        Array.init !Args.size (fun left -> 
          let entry = GEdit.entry
            ~editable:false
            ~max_length:1
            ~width:len
            ~height:len
            ~xalign:0.5
            ~packing:(container#attach ~top ~left) () in
          entry#misc#modify_font_by_name "Sans Bold 40";
          entry ))
    let iter f () = Array.iter (Array.iter f) squares
    let clear = iter (fun entry -> entry#delete_text ~start:0 ~stop:1)
    let lock = iter (fun entry -> entry#set_editable false)
    let unlock = iter (fun entry -> entry#set_editable true)
    let get_grid () = Array.map (Array.map (fun entry -> entry#text)) squares
  end

let container = GPack.vbox ~spacing:5 ~packing:hbox#add ()
let notebook = GPack.notebook ~packing:container#add ()

module type TAB_INFOS =
  sig
    val title : string
  end

module type TREE_VIEW =
  sig
    val add : 
      ?select:bool -> 
      key:string -> 
      word:string -> 
      score:int -> (int * int) list -> unit
    val clear : unit -> unit
    val view : GTree.view
  end

module Make = functor (TabInfo : TAB_INFOS) ->
  struct
    let container = GPack.vbox ()
    module Data =
      struct
        let cols = new GTree.column_list
        let key = cols#add Gobject.Data.string
        let word = cols#add Gobject.Data.string
        let score = cols#add Gobject.Data.int
        let seq = cols#add Gobject.Data.caml
        let store = GTree.list_store cols
      end


    let clear_path =
      let init = [`NORMAL, `WHITE] in
      Table.iter (fun entry -> entry#misc#modify_base init)

    let clear () =
      Table.unlock ();
      clear_path ();
      Data.store#clear ()

    module View =
      struct
        let common = [`EDITABLE false]
        let key = GTree.cell_renderer_text (`WEIGHT `BOLD :: common)
        let word = GTree.cell_renderer_text (`STYLE `ITALIC :: common)
        let score = GTree.cell_renderer_text common
        let create_view_column title cell data =
          let vcol = GTree.view_column ~title () in
          vcol#pack cell;
          vcol#add_attribute cell "text" data;
          vcol
        let col1 = create_view_column "Lettres" key Data.key
        let col2 = create_view_column "Mots" word Data.word
        let col3 = create_view_column "Points" score Data.score
      end

    let scroll = GBin.scrolled_window
      ~hpolicy:`ALWAYS
      ~vpolicy:`ALWAYS
      ~width:(!Args.size * (Table.len + 5)  - 5)
      ~packing:container#add ()

    let show_path = 
      let highlight = [`NORMAL, `NAME "#eac64a"] in
      fun selection () ->
        clear_path ();
        match selection#get_selected_rows with
        | [] -> ()
        | path :: _ -> let row = Data.store#get_iter path in
          List.iter (fun (x, y) ->
            Table.squares.(x).(y)#misc#modify_base highlight
          ) (Data.store#get ~row ~column:Data.seq)

    let view = 
      let view = GTree.view
        ~height:150
        ~model:Data.store
        ~packing:scroll#add () in
      List.iter (fun c -> ignore (view#append_column c)) 
        [View.col1; View.col2; View.col3];
      let sel = view#selection in
      sel#connect#changed (show_path sel);
      view

    let add ?(select = false) ~key ~word ~score seq = 
      let row = Data.store#append () in
      Data.store#set ~row ~column:Data.key key;
      Data.store#set ~row ~column:Data.word word;
      Data.store#set ~row ~column:Data.score score;
      Data.store#set ~row ~column:Data.seq seq;
      if select then view#selection#select_iter row

    let page = notebook#append_page
      ~tab_label:(GMisc.label ~text:TabInfo.title ())#coerce
      container#coerce
  end

module Guesses = Make(struct let title = "Mots devinés" end)
module Missing = Make(struct let title = "Mots manqués" end)

let label_box = GPack.hbox
  ~spacing:10
  ~packing:(container#pack ~expand:false) ()

let time = GMisc.label 
  ~markup:"<b><big>03:00</big></b>" 
  ~packing:label_box#add ()

let score = GMisc.label 
  ~markup:"<b><big>0 point(s)</big></b>" 
  ~packing:label_box#add ()

let set_remaining_time ~seconds:n =
  let min = n / 60 and sec = n mod 60 in
  Printf.ksprintf time#set_label "<b><big>%02d:%02d</big></b>" min sec

let set_score ~max n =
  Printf.ksprintf score#set_label "<b><big>%d / %d</big></b>" n max

let ensure_uppercase entry t =
  if entry#editable then (
    let n = GdkEvent.Key.keyval t in
    if n >= 97 && n <= 122 || n >= 65 && n <= 90 then (
      let pos = entry#position + 1 in
      let str = String.uppercase (GdkEvent.Key.string t) in
      entry#insert_text str ~pos;
      entry#set_position (pos + Glib.Utf8.length str);
      true
    ) else n <> 65288 && n <> 65535 && n <> 65289
  ) else false

let guess_word = 
  let entry = GEdit.entry 
    ~packing:(container#pack ~expand:false) () in
  entry#misc#modify_font_by_name "Sans Bold 12";
  entry#event#connect#key_press (ensure_uppercase entry);
  entry

let bbox = GPack.button_box `HORIZONTAL
  ~layout:`START
  ~border_width:5
  ~packing:(vbox#pack ~expand:false) ()

let rerun = 
  let btn = GButton.button
    ~label:"Nouvelle partie"
    ~packing:bbox#add () in
  btn#set_image (GMisc.image ~stock:`NEW ())#coerce;
  btn
