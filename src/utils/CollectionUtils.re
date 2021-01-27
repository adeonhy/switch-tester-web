let groupBy = (type a, key, items) => {
  let cmp: (a, a) => int = Pervasives.compare;
  module Cmp = (val Belt.Id.comparable(~cmp));
  let empty = Belt.Map.make(~id=(module Cmp));
  let merge = newItem =>
    fun
    | None => Some([newItem])
    | Some(existingItems) => Some([newItem, ...existingItems]);
  Belt.Array.reduce(items, empty, (map, item) =>
    Belt.Map.update(map, key(item), merge(item))
  )
  ->(Belt.Map.map(Array.of_list))
  |> Belt.Map.toArray;
};
