import jQuery from 'jquery'

export default {
  showMessageWhenTransactionFailed(award) {
    if (jQuery('body.projects-show').length > 0) {
      jQuery('.flash-msg').html('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on the <a href="/projects/' + award.project.id + '/awards">awards</a> page.')
    }
  },
  updateTransactionAddress(award, txHash, linkToTx) {
    jQuery.post(`/projects/${award.project.id}/batches/${award.award_type.id}/tasks/${award.id}/update_transaction_address`, { tx: txHash }, () => {
      const alertMsg = `Your award is successfully sent. Please check the <a href='${linkToTx}' target='_blank'>transaction address</a>`
      alert( alertMsg, 'OK')
    }).fail(() => {
      const alertMsg = `The tokens have been successfully transferred, but the <a href='${linkToTx}' target='_blank'>transaction address</a> of the award cannot be updated`
      alert( alertMsg, 'OK')
    })
  }
}
