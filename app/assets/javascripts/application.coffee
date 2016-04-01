# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https:#github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
# = require jquery
# = require jquery_ujs
# = require d3
# = require d3pie
# = require foundation
# = require moment
# = require underscore
# = require chart_colors
# = require_tree .

# = require web3
# = require hooked-web3-provider
# = require ethereumjs-accounts

$ ->
  $(document).foundation()

  # lets hope we never have more than 1000 initial records (award types only have 3 by default)
  nextIdentifier = 1000
  $("*[data-duplicate]").click (e)->
    e.preventDefault()
    templateSelector = $(e.target).attr('data-duplicate')
    template = $(templateSelector)
    newElement = template.clone()
    newElement.removeClass('hide')
    newElement.removeClass(templateSelector.replace('.', ''))
    newElementIdentifier = nextIdentifier++
    _.each $(newElement).find("input"), (input)->
      currentName = $(input).attr("name")
      number = +currentName.match(/[0-9]+/)[0]
      fixedName = currentName.replace(/\[[0-9]+\]/, "[" + (number + nextIdentifier) + "]")
      $(input).attr("name", fixedName)

    template.parent().append(newElement)

  $(document).on "click", "*[data-toggles]", (e)->
    selector = $(e.target).attr('data-toggles')
    $(selector).toggleClass("hide")

  $(document).on "click", "*[data-mark-and-hide]", (e)->
    e.preventDefault()
    removeSelector = $(e.target).attr('data-mark-and-hide')
    removeElement = $(e.target).closest(removeSelector)
    removeElement.hide()
    removeElement.find("input[data-destroy]").val("1")



window.web3 = new Web3()
gethNode = "http://104.236.178.16:8545"

# web3.setProvider(new web3.providers.HttpProvider(gethNode))



# Accounts = require('ethereumjs-accounts')
accounts = new Accounts()

# accountObject = accounts.new('password')
# console.log(accountObject)


# Get and decrypt an account stored in browser
# accountObject = accounts.get('0xa9a30b87f3d25d32a91b2459095f3297bf4383b5', 'password')
# console.log(accountObject)


# Return all accounts stored in browser
# accountList = accounts.get()
# console.log accountList

provider = new HookedWeb3Provider(
  host: gethNode
  transaction_signer: accounts)

web3.setProvider provider


etherBalance = (addr)->
  web3.fromWei(web3.eth.getBalance(addr).toNumber()) + " ether"

################################


Contract = web3.eth.contract [
  {
     constant: false,
     inputs: [{
         name: "receiver",
         type: "address"
     }, {
         name: "amount",
         type: "uint256"
     }],
     name: "sendCoin",
     outputs: [{
         name: "sufficient",
         type: "bool"
     }],
     type: "function"
  }, {
     constant: true,
     inputs: [{
         name: "",
         type: "address"
     }],
     name: "coinBalanceOf",
     outputs: [{
         name: "",
         type: "uint256"
     }],
     type: "function"
  }, {
     inputs: [{
         name: "supply",
         type: "uint256"
     }],
     type: "constructor"
  }, {
     anonymous: false,
     inputs: [{
         indexed: false,
         name: "sender",
         type: "address"
     }, {
         indexed: false,
         name: "receiver",
         type: "address"
     }, {
         indexed: false,
         name: "amount",
         type: "uint256"
     }],
     name: "CoinTransfer",
     type: "event"
  }]

contract = Contract.at "0x1ecb894226aae28c436b54ebeb2187f5da3410b9"


civ2 = "0xef7ea5b3d74791b9996f8cbcbaebe516f5e4ee36"
browser = '0xa9a30b87f3d25d32a91b2459095f3297bf4383b5'
browserAccount = accounts.get(browser, 'password')
console.log browserAccount

contract.sendCoin civ2, 50, from: browser, (err, res)->
  console.log err, res

console.log "Civ2: " + contract.coinBalanceOf(civ2) + " coins " + etherBalance(civ2)
console.log "Browser: " + contract.coinBalanceOf(browser) + " coins " + etherBalance(browser)


###
Future work
Log out: deletes all accounts from localStorage
Log in: paste in BIP32 key
ability to generate key and export in BIP32
check out existing open source eth token contracts

ability for Rails server to top up browser account ether/gas.

sandbox server in testnet to try the concept out without spending money/ether


hello world:
curl -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}' 104.236.178.16:8545

###
