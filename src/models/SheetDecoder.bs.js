'use strict';

var Caml_format = require("bs-platform/lib/js/caml_format.js");
var Json_decode = require("@glennsl/bs-json/src/Json_decode.bs.js");

function cell(data) {
  return {
          row: Caml_format.caml_int_of_string(Json_decode.field("row", Json_decode.string, data)),
          col: Caml_format.caml_int_of_string(Json_decode.field("col", Json_decode.string, data)),
          value: Json_decode.field("$t", Json_decode.string, data)
        };
}

function entry(data) {
  return {
          cell: Json_decode.field("gs$cell", cell, data)
        };
}

function feed(data) {
  return {
          entry: Json_decode.field("entry", (function (param) {
                  return Json_decode.array(entry, param);
                }), data)
        };
}

function sheet(data) {
  return {
          feed: Json_decode.field("feed", feed, data)
        };
}

exports.cell = cell;
exports.entry = entry;
exports.feed = feed;
exports.sheet = sheet;
/* No side effect */
