type 'a parser =
  string -> string * 'a

let ( *> ) (p1: 'a parser) (p2: 'b parser): 'b parser =
  fun str ->
    let (str', _) = p1 str in
    p2 str'

let ( <* ) (p1: 'a parser) (p2: 'b parser): 'a parser =
  fun str ->
    let (str', x) = p1 str in
    let (str'', _) = p2 str' in
    str'', x

let ( <*> ) (p1: 'a parser) (p2: 'b parser): ('a * 'b) parser =
  fun str ->
    let (str', a) = p1 str in
    let (str'', b) = p2 str' in
    str'', (a, b)

let map (f: 'a -> 'b) (p: 'a parser): 'b parser =
  fun str ->
    let (str', a) = p str in
    str', f a

let parse_int str =
  let i = ref 0 in
  while
    let c =
      try Char.code (String.get str !i)
      with Invalid_argument (_) -> 0
    in
    (c >= Char.code '0') && (c <= Char.code '9')
  do
    incr i
  done;
  let n = int_of_string @@ Str.string_before str !i in
  Str.string_after str !i, n

let parse_char c str =
  assert ((String.get str 0) = c);
  Str.string_after str 1, c

let parse_pair =
  (parse_int <* parse_char '-') <*> parse_int

let parse_line =
  (parse_pair <* parse_char ',') <*> parse_pair

let parse_all str =
  String.split_on_char '\n' str
  |> List.filter (fun s -> (String.length s) > 0)
  |> List.map (fun s -> snd @@ parse_line s)

let part1 (str: string): unit =
  let n =
    let contains ((a1, a2), (b1, b2)) =
      a1 <= b1 && a2 >= b2 || b1 <= a1 && b2 >= a2
    in
    parse_all str
    |> List.filter contains
    |> List.length
  in
  Printf.printf "part 1) fully contained pairs: %d\n" n

let part2 (str: string): unit =
  let n =
    let overlaps ((a1, a2), (b1, b2)) =
      a1 >= b1 && a1 <= b2 || b1 >= a1 && b1 <= a2
    in
    parse_all str
    |> List.filter overlaps
    |> List.length
  in
  Printf.printf "part 2) overlapping pairs: %d\n" n

let read_file filename =
  let chan = open_in filename in
  let s = really_input_string chan (in_channel_length chan) in
  close_in chan;
  s

let () =
  (* arguments *)
  let usage = "soln [input]" in
  let input = ref "" in
  let anon filename = input := filename in
  Arg.parse [] anon usage;

  (* parse *)
  let text = read_file !input in
  part1 text;
  part2 text;