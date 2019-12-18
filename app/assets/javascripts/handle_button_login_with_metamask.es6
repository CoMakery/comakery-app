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
  if (!window.web3.currentProvider.selectedAddress && window.ethereum) {
    await(ethereum.enable());
  }
  if (!window.web3.currentProvider.selectedAddress) {
    $('#metamaskModal1').foundation('open');
    return;
  }
  publicAddress = window.web3.currentProvider.selectedAddress.toLowerCase();
  $target.find('span').text('Loading ...');
  fetch('/api/accounts/find_by_public_address?public_address=' + publicAddress).then(function(response) {
    return response.json();
  }).then(function(data) {
    if (data.publicAddress) {
      return data;
    } else {
      return loginWithMetaMask.handleSignup(publicAddress, web3.version.network);
    }
  }).then(loginWithMetaMask.handleAuthenticate)["catch"](function(err) {
    $target.find('span').text('Sign in with MetaMask');
  });
};
