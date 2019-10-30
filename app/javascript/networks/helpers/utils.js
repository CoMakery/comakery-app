import jQuery from 'jquery'

export default {
  showMessageWhenTransactionFailed(award) {
    if (jQuery('body.projects-show').length > 0) {
      alert('The tokens have been awarded but not transferred. You can transfer tokens on the blockchain on transfers page.')
    }
  },
  updateTransactionAddress(award, txHash, linkToTx) {
    jQuery.post(`/projects/${award.project.id}/batches/${award.award_type.id}/tasks/${award.id}/update_transaction_address`, { tx: txHash }, () => {
      alert('Your award is successfully sent.')
      location.reload()
    }).fail(() => {
      alert('The tokens have been successfully transferred, but the transaction address of the award cannot be updated.')
      location.reload()
    })
  }
}
