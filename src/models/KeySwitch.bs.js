'use strict';

var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Belt_MapString = require("bs-platform/lib/js/belt_MapString.js");

function $$default(param) {
  return {
          id: 0,
          name: "",
          imageUrl: "",
          type_: "",
          price: "",
          weight: "",
          comment: "",
          pin: "",
          stock: "",
          otherAttributes: undefined
        };
}

function updateAttribute(old, cell, header) {
  var headerCell = Belt_Array.getBy(header, (function (h) {
          return h.col === cell.col;
        }));
  var match = cell.value !== "";
  if (match && headerCell !== undefined) {
    return Belt_MapString.set(old, headerCell.value, cell.value);
  } else {
    return old;
  }
}

function updateKeySwitch(s, cell, header) {
  var match = cell.col;
  switch (match) {
    case 5 :
        return {
                id: s.id,
                name: cell.value,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: s.price,
                weight: s.weight,
                comment: s.comment,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 6 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: cell.value,
                type_: s.type_,
                price: s.price,
                weight: s.weight,
                comment: s.comment,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 7 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: cell.value,
                price: s.price,
                weight: s.weight,
                comment: s.comment,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 8 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: cell.value,
                weight: s.weight,
                comment: s.comment,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 9 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: s.price,
                weight: cell.value,
                comment: s.comment,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 10 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: s.price,
                weight: s.weight,
                comment: cell.value,
                pin: s.pin,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 11 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: s.price,
                weight: s.weight,
                comment: s.comment,
                pin: cell.value,
                stock: s.stock,
                otherAttributes: s.otherAttributes
              };
    case 12 :
        return {
                id: s.id,
                name: s.name,
                imageUrl: s.imageUrl,
                type_: s.type_,
                price: s.price,
                weight: s.weight,
                comment: s.comment,
                pin: s.pin,
                stock: cell.value,
                otherAttributes: s.otherAttributes
              };
    case 13 :
    case 14 :
    case 15 :
    case 16 :
    case 17 :
        break;
    default:
      return s;
  }
  return {
          id: s.id,
          name: s.name,
          imageUrl: s.imageUrl,
          type_: s.type_,
          price: s.price,
          weight: s.weight,
          comment: s.comment,
          pin: s.pin,
          stock: s.stock,
          otherAttributes: updateAttribute(s.otherAttributes, cell, header)
        };
}

var arrayOfAttributes = Belt_MapString.toArray;

exports.$$default = $$default;
exports.default = $$default;
exports.__esModule = true;
exports.arrayOfAttributes = arrayOfAttributes;
exports.updateAttribute = updateAttribute;
exports.updateKeySwitch = updateKeySwitch;
/* No side effect */
