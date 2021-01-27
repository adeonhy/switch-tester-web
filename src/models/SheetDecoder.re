type cell = {
  row: int,
  col: int,
  value: string,
};
type entry = {cell};
type feed = {entry: array(entry)};
type sheet = {feed};

let cell = (data: Js.Json.t) =>
  Json.Decode.{
    row: data |> field("row", string) |> int_of_string,
    col: data |> field("col", string) |> int_of_string,
    value: data |> field("$t", string),
  };

let entry = (data: Js.Json.t) =>
  Json.Decode.{cell: data |> field("gs$cell", cell)};

let feed = (data: Js.Json.t) =>
  Json.Decode.{entry: data |> field("entry", Json.Decode.array(entry))};

let sheet = (data: Js.Json.t) =>
  Json.Decode.{feed: data |> field("feed", feed)};
