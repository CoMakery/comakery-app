async function transferAwardOnQtum(award) { // award in JSON
  if (award.project.coin_type === 'qrc20') {
    transferQrc20Tokens(award);
  } else if (award.project.coin_type === 'qtum') {
    const network = award.project.blockchain_network.replace('qtum_', '')
    const tx = await sendQtums(network, award.account.qtum_wallet, award.total_amount)
    console.log('transaction address: ' + tx)
    if(tx) {
      // update_transaction_address_project_award_path
      $.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: tx })
    }
  }
};
