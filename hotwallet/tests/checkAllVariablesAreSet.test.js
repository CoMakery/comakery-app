const hwUtils = require('../lib/hotwalletUtils')

describe("Check that all variables are set test suite", () => {

  test('all ENVs are set', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key", // optional
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710, // optional
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000, // optional
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(true)
})

test('redisUrl is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    infuraProjectId: "infura_project_id",
    redisUrl: null,
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('emptyQueueDelay is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: null,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: null,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(true)
})

test('ethereumTokenSymbol is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
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
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: null
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('ethereumContractAddress is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    infuraProjectId: "infura_project_id",
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: null
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})

test('maxAmountForTransfer is null', async () => {
  const envs = {
    projectId: "1",
    projectApiKey: "project_api_key",
    comakeryServerUrl: "http://cmk.server",
    purestakeApi: "purestake_api_key",
    infuraProjectId: null,
    redisUrl: "redis://localhost:6379/0",
    emptyQueueDelay: 30,
    optInApp: 13997710,
    blockchainNetwork: 'algorand_test',
    maxAmountForTransfer: 100000000,
    ethereumTokenSymbol: "XYZ2",
    ethereumContractAddress: "0x1d1592c28fff3d3e71b1d29e31147846026a0a37"
  }
  expect(hwUtils.checkAllVariablesAreSet(envs)).toBe(false)
})
});
