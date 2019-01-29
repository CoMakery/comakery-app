import ScatterJS from 'scatterjs-core'

const testNet = ScatterJS.Network.fromJson({
  blockchain: 'eos',
  chainId   : 'e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473',
  host      : 'jungle2.cryptolions.io',
  port      : 443,
  protocol  : 'https'
})

const mainNet = ScatterJS.Network.fromJson({
  blockchain: 'eos',
  chainId   : 'aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906',
  host      : 'eosapi.blockmatrix.network',
  port      : 443,
  protocol  : 'https'
})

export default { mainNet, testNet}
