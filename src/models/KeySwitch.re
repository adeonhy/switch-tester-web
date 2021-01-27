open SheetDecoder;
type attributeType = Belt.Map.String.t(string);

type t = {
  id: int,
  name: string,
  imageUrl: string,
  type_: string,
  price: string,
  weight: string,
  comment: string,
  pin: string,
  stock: string,
  otherAttributes: attributeType,
};

let default = (): t => {
  id: 0,
  name: "",
  imageUrl: "",
  type_: "",
  price: "",
  weight: "",
  comment: "",
  pin: "",
  stock: "",
  otherAttributes: Belt.Map.String.empty,
};

let arrayOfAttributes = Belt.Map.String.toArray;

let updateAttribute =
    (old: attributeType, cell: cell, header: array(cell)): attributeType => {
  let headerCell = header->Belt.Array.getBy(h => h.col == cell.col);

  switch (cell.value != "", headerCell) {
  | (true, Some(h)) => Belt.Map.String.set(old, h.value, cell.value)
  | _ => old
  };
};

let updateKeySwitch = (s: t, cell: cell, header: array(cell)): t => {
  switch (cell.col) {
  | 5 => {...s, name: cell.value}
  | 6 => {...s, imageUrl: cell.value}
  | 7 => {...s, type_: cell.value}
  | 8 => {...s, price: cell.value}
  | 9 => {...s, weight: cell.value}
  | 10 => {...s, comment: cell.value}
  | 11 => {...s, pin: cell.value}
  | 12 => {...s, stock: cell.value}
  | 13
  | 14
  | 15
  | 16
  | 17 => {
      ...s,
      otherAttributes: updateAttribute(s.otherAttributes, cell, header),
    }
  | _ => s
  };
};
