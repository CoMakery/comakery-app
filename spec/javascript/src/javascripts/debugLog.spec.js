it('debugLog', () => {
  document.body.setAttribute('data-log-config', '{"ENABLE_DEBUGGING":true}')
  console.log = jest.fn()
  const debugLog = require('src/javascripts/debugLog')
  debugLog('hi')
  debugLog(new Error('error'))
  expect(console.log).toHaveBeenCalledTimes(2)
})
