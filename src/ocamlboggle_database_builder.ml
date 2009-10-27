(* ocamlboggle-database-builder.ml *)

open Printf

let n = ref 0

module PrefixTree =
  struct
    open Genlex

    let tokenize = make_lexer [":"]

    let rec parse_tree t = parser
      | [< 'Ident key; 'Kwd ":"; dat = parse_dat []; stream >] ->
        incr n;
        parse_tree (Trie.ASCII.add key dat t) stream
      | [< >] -> t
    and parse_dat l = parser
      | [< 'String str; stream >] -> parse_dat (str :: l) stream
      | [< >] -> l

    let of_file t file =
      let ich = open_in file in
      let res = parse_tree t (tokenize (Stream.of_channel ich)) in
      close_in ich;
      res 
  end

let merge () =
  let rec loop t i =
    if i < 7 then (
      n := 0;
      let str = sprintf "lex/LEX%02d" i in
      printf "> Loading %s.\n%!" str;
      try loop (PrefixTree.of_file t str) (i + 1) with _ ->
        printf "> ERROR line %d.\n%!" !n; exit 2
    ) else t
  in loop Trie.ASCII.empty 0

let output_database t =
  let och = open_out "OCAMLBOGGLE-DATABASE" in
  output_value och t;
  close_out och

let _ =
  let t = merge () in
  printf "> Lexicon size : %d entries\n%!" (Trie.ASCII.length t);
  output_database t;
  printf "> Output written in file OCAMLBOGGLE_DATABASE\n\n%!"
