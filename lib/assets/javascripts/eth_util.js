module.exports = {
  verify_signature: function(publicAddress, signature, msg) {
    var ethUtil = require('ethereumjs-util')
    var msgBuffer = ethUtil.toBuffer(msg);
    var msgHash = ethUtil.hashPersonalMessage(msgBuffer);
    var signatureBuffer = ethUtil.toBuffer(signature);
    var signatureParams = ethUtil.fromRpcSig(signatureBuffer);
    var publicKey = ethUtil.ecrecover(
      msgHash,
      signatureParams.v,
      signatureParams.r,
      signatureParams.s
    );
    var addressBuffer = ethUtil.publicToAddress(publicKey);
    var address = ethUtil.bufferToHex(addressBuffer);

    if (address.toLowerCase() === publicAddress.toLowerCase()) {
      return true;
    } else {
      return false;
    }
} };
