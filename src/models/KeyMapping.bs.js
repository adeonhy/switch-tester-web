'use strict';

var List = require("bs-platform/lib/js/list.js");
var $$Array = require("bs-platform/lib/js/array.js");
var Curry = require("bs-platform/lib/js/curry.js");
var React = require("react");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var KeySwitch$SwitchTester = require("./KeySwitch.bs.js");
var SheetDecoder$SwitchTester = require("./SheetDecoder.bs.js");
var CollectionUtils$SwitchTester = require("../utils/CollectionUtils.bs.js");

var defaultKeyInfo = {
  key: "",
  isCtrl: false
};

var default_keySwitch = KeySwitch$SwitchTester.$$default(undefined);

var $$default = {
  keyInfo: defaultKeyInfo,
  keySwitch: default_keySwitch
};

function updateKeyMapping(m, cell, header) {
  var match = cell.col;
  var switcher = match - 1 | 0;
  if (switcher > 2 || switcher < 0) {
    if (switcher !== 3) {
      return {
              keyInfo: m.keyInfo,
              keySwitch: KeySwitch$SwitchTester.updateKeySwitch(m.keySwitch, cell, header)
            };
    }
    var init = m.keyInfo;
    return {
            keyInfo: {
              key: init.key,
              isCtrl: cell.value === "TRUE"
            },
            keySwitch: m.keySwitch
          };
  }
  if (switcher < 2) {
    return m;
  }
  var init$1 = m.keyInfo;
  return {
          keyInfo: {
            key: cell.value,
            isCtrl: init$1.isCtrl
          },
          keySwitch: m.keySwitch
        };
}

function makeKeyMapping(data, header) {
  return $$Array.fold_left((function (m, cell) {
                return updateKeyMapping(m, cell, header);
              }), $$default, data);
}

function parseSheet(sheet) {
  var rowGroupedCells = $$Array.to_list(CollectionUtils$SwitchTester.groupBy((function (cell) {
              return cell.row;
            }), $$Array.map((function (e) {
                  return e.cell;
                }), sheet.feed.entry)));
  if (!rowGroupedCells) {
    return ;
  }
  var header = rowGroupedCells.hd[1];
  return List.map((function (row) {
                return makeKeyMapping(row[1], header);
              }), rowGroupedCells.tl);
}

function useKeyMatcher(keyMappingJsonUrl) {
  var match = React.useState(function () {
        
      });
  var setKeyMappings = match[1];
  var keyMappings = match[0];
  React.useEffect((function () {
          fetch(keyMappingJsonUrl).then(function (response) {
                    return response.json();
                  }).then(function (jsonResponse) {
                  var s = parseSheet(SheetDecoder$SwitchTester.sheet(jsonResponse));
                  Curry._1(setKeyMappings, (function (param) {
                          return s;
                        }));
                  return Promise.resolve(undefined);
                }).catch(function (err) {
                console.log(err);
                Curry._1(setKeyMappings, (function (param) {
                        
                      }));
                return Promise.resolve(undefined);
              });
          
        }), []);
  return function (key) {
    if (key === undefined) {
      return ;
    }
    if (keyMappings === undefined) {
      return ;
    }
    var k = Caml_option.valFromOption(key);
    return Belt_Option.map(List.find_opt((function (m) {
                      return k.key === m.keyInfo.key;
                    }), keyMappings), (function (m) {
                  return m.keySwitch;
                }));
  };
}

exports.defaultKeyInfo = defaultKeyInfo;
exports.$$default = $$default;
exports.default = $$default;
exports.__esModule = true;
exports.updateKeyMapping = updateKeyMapping;
exports.makeKeyMapping = makeKeyMapping;
exports.parseSheet = parseSheet;
exports.useKeyMatcher = useKeyMatcher;
/* default Not a pure module */
