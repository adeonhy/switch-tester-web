'use strict';

var $$Array = require("bs-platform/lib/js/array.js");
var Curry = require("bs-platform/lib/js/curry.js");
var Belt_Id = require("bs-platform/lib/js/belt_Id.js");
var Belt_Map = require("bs-platform/lib/js/belt_Map.js");
var Caml_obj = require("bs-platform/lib/js/caml_obj.js");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");

function groupBy(key, items) {
  var cmp = Caml_obj.caml_compare;
  var Cmp = Belt_Id.comparable(cmp);
  var empty = Belt_Map.make(Cmp);
  return Belt_Map.toArray(Belt_Map.map(Belt_Array.reduce(items, empty, (function (map, item) {
                        return Belt_Map.update(map, Curry._1(key, item), (function (param) {
                                      if (param !== undefined) {
                                        return {
                                                hd: item,
                                                tl: param
                                              };
                                      } else {
                                        return {
                                                hd: item,
                                                tl: /* [] */0
                                              };
                                      }
                                    }));
                      })), $$Array.of_list));
}

exports.groupBy = groupBy;
/* No side effect */
