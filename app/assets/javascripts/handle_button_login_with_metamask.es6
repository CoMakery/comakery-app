window.loginWithMetaMask = window.loginWithMetaMask || {}

loginWithMetaMask.handleClick = async function() {
  var $target, publicAddress, web3;
  $target = $('.auth-button.signin-with-metamask');
  if (window.ethereum) {
    window.web3 = new Web3(ethereum);
  }
  if (!window.web3) {
    $('#metamaskModal1').foundation('open');
    return;
  }
  if (!web3) {
    web3 = new Web3(window.web3.currentProvider);
  }
  if (!web3.eth.coinbase && window.ethereum) {
    await(ethereum.enable());
  }
  if (!web3.eth.coinbase) {
    $('#metamaskModal1').foundation('open');
    return;
  }
  publicAddress = web3.eth.coinbase.toLowerCase();
  $target.find('span').text('Loading ...');
  fetch('/api/accounts/find_by_public_address?public_address=' + publicAddress).then(function(response) {
    return response.json();
  }).then(function(data) {
    if (data.public_address) {
      return data;
    } else {
      return loginWithMetaMask.handleSignup(publicAddress, web3.version.network);
    }
  }).then(loginWithMetaMask.handleAuthenticate)["catch"](function(err) {
    $target.find('span').text('Sign in with MetaMask');
  });
};
