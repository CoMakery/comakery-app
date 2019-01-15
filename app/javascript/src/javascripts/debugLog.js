const LOG_CONFIG = JSON.parse(document.body.getAttribute('data-log-config'))

const debugLog = function(item) {
  if (LOG_CONFIG && LOG_CONFIG.ENABLE_DEBUGGING) {
    let msgToLog = ''
    if (item instanceof Error) {
      msgToLog = JSON.stringify(item, Object.getOwnPropertyNames(item))
    } else {
      msgToLog = item
    }
    console.error(msgToLog)
  }
}

module.exports = debugLog
