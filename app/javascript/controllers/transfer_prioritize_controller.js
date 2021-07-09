import { Controller } from 'stimulus'

export default class extends Controller {
    static targets = [ 'transferPrior' ];

    updateTransferFormSrc() {
        // alert('test');
        let transferSettingsSelector = $('#transfer_settings')

        // Disable lazy load
        transferSettingsSelector.attr('loading', '')
    }
}
