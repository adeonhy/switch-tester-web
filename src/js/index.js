require('../css/style.css');
const { Elm } = require('../Main.elm');

console.log("pre elm init")
var app = Elm.Main.init({
  node: document.getElementById('elm')
});

const swPath = 'sw.js'
if (`serviceWorker` in navigator) {
  window.addEventListener(`load`, () => {
    navigator.serviceWorker.register(swPath)
      .then(() => console.log('sw register done.'))
			.catch(error => console.log(`Can't register Service Worker`, error))
  })
}
