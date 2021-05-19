const axios = require("axios")
const redis = require("redis")
const hwUtils = require("../lib/hotwalletUtils")
const envs = {
  projectId: "1",
  projectApiKey: "project_api_key",
  comakeryServerUrl: null,
  purestakeApi: "purestake_api_key",
  redisUrl: "redis://localhost:6379/0"
}

const ethWalletKeys = {
  publicKey: "057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
  privateKey: "fb2c017e4b6ab9c8c6cf7513223f5cd0b493c249a39a68cd29b26d37274bad29057bac3f6921e98a89a3bfe2b2ec138577da66ee58329b741e44de93431f8bde",
  privateKeyEncrypted: "Z6mKYt1ntc+s1xQkK4HYKZtUsK4Kdg18kOa2p2SL6H0Q4GO0pafso6fEEmQgDoiakzj3lfqp3s5/1kEjNZomWm1h8xdwbBHUT4rrrTfohjdPZAe5Fg1Sw/6hA+mm7dKN8eWzEFaNe7LIdFrzHD0bOz5OSif8+t3QGmQfrbVulRakLfBh5tc6MVOsAMAt57d6nXUhaQfwPtuDB41bPoMRmAYrwjKrTmiu"
}

const wallet = new hwUtils.HotWallet("ethereum_ropsten", "0x2aA78Db0BEff941883C33EA150ed86eaDE09A377", ethWalletKeys)

jest.mock("axios")

const redisClient = redis.createClient()
const hwRedis = new hwUtils.HotWalletRedis(envs, redisClient)
const hwApi = new hwUtils.ComakeryApi(envs)

beforeEach(async () => {
  await hwRedis.deleteCurrentKey()
})

afterAll(() => {
  redisClient.quit()
});

test("API returns successfull response", async () => {
  expect.assertions(1);
  axios.post.mockImplementation(() => Promise.resolve({ status: 201, data: {} }))
  res = await hwApi.registerHotWallet(wallet)

  expect(res.status).toEqual(201)
})

test("API returns failed response", async () => {
  const data = {
    response: {
      status: 422,
      statusText: "Unprocessable Entity",
      data: { errors: { hot_wallet: 'already exists' } }
    }
  }

  axios.post.mockReturnValue(Promise.reject(data));
  res = await hwApi.registerHotWallet(wallet)

  expect(res).toEqual({})
})
