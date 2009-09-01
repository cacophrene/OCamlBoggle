open Printf

module Parser =
  struct
    open Genlex
    let tokenize = make_lexer [":"; ";"]

    let rec get_trie t = parser
      | [< 'Ident str; 'Kwd ":"; l = get_list []; 'Kwd ";"; stream >] ->
        get_trie (Trie.ASCII.add str l t) stream
      | [< >] -> t
    and get_list acc = parser
      | [< 'String str; stream >] -> get_list (str :: acc) stream
      | [< >] -> List.sort compare acc

    let from_file t file =
      let ich = open_in file in
      let res = get_trie t (tokenize (Stream.of_channel ich)) in
      close_in ich;
      res
  end

let string_of_list =
  let buf = Buffer.create 16 in
  function l ->
    Buffer.clear buf;
    List.iter (fun str ->
      if Buffer.length buf > 0 then Buffer.add_char buf ' ';
      bprintf buf "\"%s\"" str
    ) l;
    Buffer.contents buf

let out t =
  let och = open_out "NEW-LEXICON" in
  Trie.ASCII.iter (fun key dat ->
    fprintf och "%-35s : %s;\n" key (string_of_list dat)
  ) t;
  close_out och

let get () =
  let rec loop t n =
    if n < 6 then loop (Parser.from_file t (sprintf "LEX%02d" n)) (n + 1)
    else t
  in loop Trie.ASCII.empty 0

let pat = Str.regexp "[\t ]+"

let spe t =
  let och = open_out "OCAMLBOGGLE-DATABASE" in
  output_value och t;
  close_out och

let _ =
  let rec loop acc =
    let key = String.uppercase (read_line (print_string "Clef : ")) in
    if String.length key > 0 then (
      let dat = read_line (print_string "Mots : ") in
      printf "> Adding [%s] associated with key %s.\n%!" dat key;
      loop ((key, Str.split pat dat) :: acc) 
    ) else acc in
  printf "> Please wait while loading lexicon.\n%!";
  let t = get () in
  printf "> Current lexicon size is : %d entries.\n%!" (Trie.ASCII.length t);
  let l = loop [] in
  let t = List.fold_left (fun t (str, dat) -> Trie.ASCII.add str dat t) t l in
  printf "> New lexicon size is : %d entries.\n%!" (Trie.ASCII.length t);
  printf "Output specialized version for OCamlBoggle.\n%!";
  spe t;
  printf "Save lexicon as plain text file.\n%!";
  out t;
  printf "Splitting.\n%!";
  Sys.command "split -d -l 100000 NEW-LEXICON LEX"

