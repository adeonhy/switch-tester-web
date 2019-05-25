require('../css/style.css');
const { Elm } = require('../elm/weight.elm');

var app = Elm.Main.init({
  node: document.getElementById('elm')
});
