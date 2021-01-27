'use strict';

var List = require("bs-platform/lib/js/list.js");
var $$Array = require("bs-platform/lib/js/array.js");
var Curry = require("bs-platform/lib/js/curry.js");
var React = require("react");
var SheetDecoder$SwitchTester = require("./SheetDecoder.bs.js");
var CollectionUtils$SwitchTester = require("../utils/CollectionUtils.bs.js");

var $$default = {
  name: "",
  description: ""
};

function updateStockDescription(m, cell) {
  var match = cell.col;
  if (match !== 1) {
    if (match !== 4) {
      return m;
    } else {
      return {
              name: m.name,
              description: cell.value
            };
    }
  } else {
    return {
            name: cell.value,
            description: m.description
          };
  }
}

function makeStockDescription(data) {
  return $$Array.fold_left(updateStockDescription, $$default, data);
}

function parseSheet(sheet) {
  var rowGroupedCells = $$Array.to_list(CollectionUtils$SwitchTester.groupBy((function (cell) {
              return cell.row;
            }), $$Array.map((function (e) {
                  return e.cell;
                }), sheet.feed.entry)));
  if (rowGroupedCells) {
    return List.map((function (row) {
                  return makeStockDescription(row[1]);
                }), rowGroupedCells.tl);
  }
  
}

function useStockMatcher(stockDescriptionJsonUrl) {
  var match = React.useState(function () {
        
      });
  var setDescriptions = match[1];
  var descriptions = match[0];
  React.useEffect((function () {
          fetch(stockDescriptionJsonUrl).then(function (response) {
                    return response.json();
                  }).then(function (jsonResponse) {
                  var d = parseSheet(SheetDecoder$SwitchTester.sheet(jsonResponse));
                  Curry._1(setDescriptions, (function (param) {
                          return d;
                        }));
                  return Promise.resolve(undefined);
                }).catch(function (err) {
                console.log(err);
                Curry._1(setDescriptions, (function (param) {
                        
                      }));
                return Promise.resolve(undefined);
              });
          
        }), []);
  return function (keySwitch) {
    if (keySwitch !== undefined && descriptions !== undefined) {
      return List.find_opt((function (d) {
                    return keySwitch.name === d.name;
                  }), descriptions);
    }
    
  };
}

exports.$$default = $$default;
exports.default = $$default;
exports.__esModule = true;
exports.updateStockDescription = updateStockDescription;
exports.makeStockDescription = makeStockDescription;
exports.parseSheet = parseSheet;
exports.useStockMatcher = useStockMatcher;
/* react Not a pure module */
