window.loginWithMetaMask = {}

loginWithMetaMask.handleAuthenticate = (ref) ->
  publicAddress = ref.publicAddress
  signature = ref.signature
  fetch('/api/accounts/auth',
    body: JSON.stringify(
      publicAddress: publicAddress
      signature: signature)
    headers: 'Content-Type': 'application/json'
    method: 'POST').then (response) ->
    response.json()

loginWithMetaMask.handleSignup = (publicAddress, network) ->
  fetch('/api/accounts',
    body: JSON.stringify(public_address: publicAddress, network_id: network)
    headers: 'Content-Type': 'application/json'
    method: 'POST').then (response) ->
    response.json()

loginWithMetaMask.handleSignMessage = (ref) ->
  publicAddress = ref.publicAddress
  nonce = ref.nonce
  new Promise((resolve, reject) ->
    web3.personal.sign web3.fromUtf8('Comakery, I am signing my nonce: ' + nonce), publicAddress, (err, signature) ->
      if err
        return reject(err)
      resolve
        publicAddress: publicAddress
        signature: signature
)

loginWithMetaMask.handleClick = ->
  # onLoggedIn = null
  if !window.web3
    window.alert 'Please install MetaMask first.'
    return
  if !web3
    web3 = new Web3(window.web3.currentProvider)
  if !web3.eth.coinbase
    window.alert 'Please activate MetaMask first.'
    return
  publicAddress = web3.eth.coinbase.toLowerCase()
  # state loading: true
  fetch('/api/accounts/find_by_public_address?publicAddress=' + publicAddress).then((response) ->
    response.json()
  ).then((users) ->
    if users.length then users[0] else loginWithMetaMask.handleSignup(publicAddress, web3.version.network)
  ).then(loginWithMetaMask.handleSignMessage).then(loginWithMetaMask.handleAuthenticate).then(onLoggedIn).catch (err) ->
    window.alert err
    # state loading: false
    return
  return

