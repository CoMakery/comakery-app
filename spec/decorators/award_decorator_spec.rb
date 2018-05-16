require 'rails_helper'

describe AwardDecorator do
  describe '#issuer_display_name' do
    let!(:issuer) { create :account, first_name: 'johnny', last_name: 'johnny' }
    let!(:project) { create :project, account: issuer }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, award_type: award_type, issuer: issuer }

    it 'returns the user name' do
      expect(award.decorate.issuer_display_name).to eq('johnny johnny')
    end
  end

  context 'recipient names' do
    let!(:recipient) { create(:account, first_name: 'Betty', last_name: 'Ross') }
    let!(:project) { create :project }
    let!(:award_type) { create :award_type, project: project }
    let!(:award) { create :award, account: recipient, award_type: award_type }

    describe '#recipient_display_name' do
      it 'returns the full name' do
        expect(award.decorate.recipient_display_name).to eq('Betty Ross')
      end
    end
  end
end
