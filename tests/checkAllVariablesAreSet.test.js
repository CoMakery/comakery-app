const hwUtils = require('../lib/hotwalletUtils')

test('all ENVs are set', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710, // not required
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(true)
})

test('projectId is null', async () => {
  const envs = {
    projectId: null,
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectId is undefined', async () => {
  const envs = {
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectId is undefined', async () => {
  const envs = {
    projectId: undefined,
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('projectApiKey is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: null,
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('comakeryServerUrl is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: null,
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('purestakeApi is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: null,
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('redisUrl is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: null,
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('checkForNewTransactionsDelay is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: null,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('optInApp is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: null,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  // It's not required
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(true)
})


test('blockchainNetwork is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: null,
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('maxAmountForTransfer is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: null,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('ethereumTokenSymbol is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: null,
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('ethereumContractAddress is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    redisUrl: "redis://localhost:6379/0",
    checkForNewTransactionsDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: null
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})
