global.fetch = require('jest-fetch-mock')

window.matchMedia = window.matchMedia || function() {
  return {
    matches       : false,
    addListener   : function() {},
    removeListener: function() {}
  }
}
