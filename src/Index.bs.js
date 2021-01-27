'use strict';

var React = require("react");
var ReactDom = require("react-dom");
var SwitchViewer$SwitchTester = require("./SwitchViewer/SwitchViewer.bs.js");

var root = document.querySelector("#root");

if (!(root == null)) {
  ReactDom.render(React.createElement(SwitchViewer$SwitchTester.make, {}), root);
}

/* root Not a pure module */
