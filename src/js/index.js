require('../css/style.css');
const { Elm } = require('../elm/main.elm');

var app = Elm.Main.init({
  node: document.getElementById('elm')
});
