const hwUtils = require('../lib/hotwalletUtils')

test('all ENVs are set', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(true)
})

test('projectId is null', async () => {
  const envs = {
    projectId: null,
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectId is undefined', async () => {
  const envs = {
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectId is undefined', async () => {
  const envs = {
    projectId: undefined,
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectApiKey is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: null,
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('comakeryServerUrl is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: null,
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('purestakeApi is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: null,
    redisUrl: "redis://localhost:6379/0"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('redisUrl is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: null
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})
