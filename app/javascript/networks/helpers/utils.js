import jQuery from 'jquery'

export default {
  showMessageWhenTransactionFailed(award) {
    if (jQuery('body.projects-show').length > 0) {
      jQuery('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
  },
  updateTransactionAddress(award, txHash, linkToTx) {
    // update_transaction_address_project_award path
    jQuery.post('/projects/' + award.project.id + '/awards/' + award.id + '/update_transaction_address', { tx: txHash }, () => {
      const alertMsg = `The <a href='${linkToTx}' target='_blank'>transaction address</a> of the award has been successfully updated`
      window.alertMsg('#metamaskModal1', alertMsg)
    }).fail(() => {
      const alertMsg = `The tokens have been successfully transferred, but the <a href='${linkToTx}' target='_blank'>transaction address</a> of the award cannot be updated`
      window.alertMsg('#metamaskModal1', alertMsg)
    })
  }
}
