'use strict';

var $$Array = require("bs-platform/lib/js/array.js");
var Curry = require("bs-platform/lib/js/curry.js");
var React = require("react");
var Belt_Array = require("bs-platform/lib/js/belt_Array.js");
var Belt_Option = require("bs-platform/lib/js/belt_Option.js");
var Caml_option = require("bs-platform/lib/js/caml_option.js");
var Consts$SwitchTester = require("../Consts.bs.js");
var KeySwitch$SwitchTester = require("../models/KeySwitch.bs.js");
var KeyMapping$SwitchTester = require("../models/KeyMapping.bs.js");
var StockDescription$SwitchTester = require("../models/StockDescription.bs.js");

function SwitchViewer$HelpView(Props) {
  var helpType = Props.helpType;
  var onHide = Props.onHide;
  if (helpType === undefined) {
    return null;
  }
  var helpImageUrl = helpType ? Consts$SwitchTester.helpImageOfSwitchTypes : Consts$SwitchTester.helpImageOfPins;
  return React.createElement("div", undefined, React.createElement("div", {
                  className: "modal"
                }, React.createElement("img", {
                      className: "help-image",
                      src: helpImageUrl
                    })), React.createElement("div", {
                  className: "overlay",
                  onClick: onHide
                }));
}

var HelpView = {
  make: SwitchViewer$HelpView
};

function SwitchViewer$DefaultView(Props) {
  return React.createElement("div", {
              className: "center"
            }, React.createElement("img", {
                  className: "default-image",
                  src: Consts$SwitchTester.urlOfTopImage
                }));
}

var DefaultView = {
  make: SwitchViewer$DefaultView
};

function SwitchViewer$HelpButton(Props) {
  var helpType = Props.helpType;
  var showHelpCallback = Props.showHelpCallback;
  return React.createElement("img", {
              className: "help-icon",
              src: "public/question.svg",
              onClick: (function (param) {
                  return Curry._1(showHelpCallback, helpType);
                })
            });
}

var HelpButton = {
  make: SwitchViewer$HelpButton
};

function SwitchViewer$SwitchAttributesView(Props) {
  var attributes = Props.attributes;
  return React.createElement("dl", undefined, Belt_Array.concatMany($$Array.map((function (param) {
                        return [
                                React.createElement("dt", undefined, param[0]),
                                React.createElement("dd", undefined, param[1])
                              ];
                      }), KeySwitch$SwitchTester.arrayOfAttributes(attributes))));
}

var SwitchAttributesView = {
  make: SwitchViewer$SwitchAttributesView
};

function SwitchViewer$SwitchView(Props) {
  var keySwitch = Props.keySwitch;
  var stock = Props.stock;
  var match = React.useState(function () {
        
      });
  var setHelpType = match[1];
  var stockDescription = Belt_Option.getWithDefault(Belt_Option.map(stock, (function (st) {
              return st.description;
            })), "");
  var handleShowHelp = function (helpType) {
    return Curry._1(setHelpType, (function (param) {
                  return helpType;
                }));
  };
  if (keySwitch !== undefined) {
    return React.createElement("div", {
                className: "summary"
              }, React.createElement(SwitchViewer$HelpView, {
                    helpType: match[0],
                    onHide: (function (param) {
                        return Curry._1(setHelpType, (function (param) {
                                      
                                    }));
                      })
                  }), React.createElement("div", {
                    className: "summary-image"
                  }, React.createElement("img", {
                        className: "switch-image",
                        src: keySwitch.imageUrl
                      })), React.createElement("div", {
                    className: "summary-info"
                  }, React.createElement("p", {
                        className: "switch-comment"
                      }, keySwitch.comment), React.createElement("p", {
                        className: "switch-name"
                      }, keySwitch.name), React.createElement("div", {
                        className: "right"
                      }, React.createElement("span", {
                            className: "stock-description"
                          }, stockDescription)), React.createElement("div", {
                        className: "right"
                      }, React.createElement("span", {
                            className: "small"
                          }, "価格 "), React.createElement("span", {
                            className: "switch-price"
                          }, keySwitch.price), React.createElement("span", {
                            className: "small"
                          }, " 円")), React.createElement("p", {
                        className: "switch-type"
                      }, keySwitch.type_ + ("軸 / " + (keySwitch.weight + "g")), React.createElement(SwitchViewer$HelpButton, {
                            helpType: /* SwitchType */1,
                            showHelpCallback: handleShowHelp
                          })), React.createElement("p", {
                        className: "switch-type"
                      }, "ピン数: " + keySwitch.pin, React.createElement(SwitchViewer$HelpButton, {
                            helpType: /* SwitchPins */0,
                            showHelpCallback: handleShowHelp
                          }))), React.createElement("div", {
                    className: "switch-detail"
                  }, React.createElement(SwitchViewer$SwitchAttributesView, {
                        attributes: keySwitch.otherAttributes
                      })));
  } else {
    return React.createElement(SwitchViewer$DefaultView, {});
  }
}

var SwitchView = {
  make: SwitchViewer$SwitchView
};

function SwitchViewer(Props) {
  var match = React.useState(function () {
        return true;
      });
  var setShowDefault = match[1];
  var match$1 = React.useState(function () {
        return 0;
      });
  var setCount = match$1[1];
  var count = match$1[0];
  var match$2 = React.useState(function () {
        
      });
  var setCurrentKey = match$2[1];
  var keyMatcher = KeyMapping$SwitchTester.useKeyMatcher(Consts$SwitchTester.urlOfSwitchesSpreadsheetJson);
  var stockMatcher = StockDescription$SwitchTester.useStockMatcher(Consts$SwitchTester.urlOfStocksSpreadsheetJson);
  var handleKeyDown = function (k) {
    console.log(k.key);
    Curry._1(setCount, (function (param) {
            return 0;
          }));
    return Curry._1(setCurrentKey, (function (param) {
                  return Caml_option.some(k);
                }));
  };
  React.useEffect((function () {
          var id = setInterval((function (param) {
                  if (count >= Consts$SwitchTester.claerIntervalSec) {
                    Curry._1(setCount, (function (param) {
                            return 0;
                          }));
                    return Curry._1(setShowDefault, (function (param) {
                                  return true;
                                }));
                  } else {
                    Curry._1(setCount, (function (c) {
                            return c + 1 | 0;
                          }));
                    return Curry._1(setShowDefault, (function (param) {
                                  return false;
                                }));
                  }
                }), 1000);
          return (function (param) {
                    clearInterval(id);
                    
                  });
        }), []);
  React.useEffect((function () {
          document.addEventListener("keydown", handleKeyDown);
          return (function (param) {
                    document.removeEventListener("keyDown", handleKeyDown);
                    
                  });
        }), []);
  var keySwitch = Curry._1(keyMatcher, match$2[0]);
  var stock = Curry._1(stockMatcher, keySwitch);
  return React.createElement("div", {
              className: "container"
            }, match[0] ? React.createElement(SwitchViewer$DefaultView, {}) : React.createElement(SwitchViewer$SwitchView, {
                    keySwitch: keySwitch,
                    stock: stock
                  }));
}

var make = SwitchViewer;

exports.HelpView = HelpView;
exports.DefaultView = DefaultView;
exports.HelpButton = HelpButton;
exports.SwitchAttributesView = SwitchAttributesView;
exports.SwitchView = SwitchView;
exports.make = make;
/* react Not a pure module */
