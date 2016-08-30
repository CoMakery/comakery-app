require 'rails_helper'

describe "shared/_awards.html.rb" do
  let!(:issuer) { create(:account) }
  let!(:recipient1) { create(:account) }
  let!(:recipient2) { create(:account) }
  let!(:issuer_auth) { create(:authentication, slack_team_id: 'cats', account: issuer) }
  let!(:recipient1_auth) { create(:authentication, slack_team_id: 'cats', account: recipient1) }
  let!(:recipient2_auth) { create(:authentication, slack_team_id: 'cats', account: recipient2) }
  let!(:project) { create(:project, slack_team_id: 'cats') }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) { create(:award, award_type: award_type, issuer: issuer, authentication: recipient1_auth).decorate }
  let!(:award2) { create(:award, award_type: award_type, issuer: issuer, authentication: recipient2_auth).decorate }

  before { assign :show_recipient, true }
  before { assign :current_account, issuer }
  before { assign :awards, [award1] }

  describe "Blockchain Transaction column" do
    describe 'when project is ethereum enabled' do
      describe 'with award ethereum transaction address' do
        before { award1.ethereum_transaction_address = '0x34567890123456789' }
        it 'shows the blockchain award when it exists' do
          render
          expect(rendered).to have_css '.blockchain-address a', text: '0x34567890...'
        end
      end

      describe 'with no award ethereum transaction address' do
        describe 'when recipient ethereum address is present' do
          before { recipient1.ethereum_wallet = '0x123' }
          it 'says "pending"' do
            render
            expect(rendered).to have_css '.blockchain-address', text: 'pending'
          end
        end

        describe 'when recipient ethereum address is blank' do
          before { recipient1.ethereum_wallet = nil }
          describe 'when logged in as award recipient' do
            before { assign :current_account, recipient1 }
            it 'links to their account' do
              render
              expect(rendered).to have_css '.blockchain-address a[href="/account"]', text: 'no account'
            end
          end

          describe 'when logged in as another user' do
            before { assign :current_account, recipient2 }
            it 'says "no account"' do
              render
              expect(rendered).to have_css '.blockchain-address', text: 'no account'
              expect(rendered).not_to have_css '.blockchain-address a'
            end
          end

          describe 'when not logged in' do
            before { assign :current_account, nil }
            it 'says "no account"' do
              render
              expect(rendered).to have_css '.blockchain-address', text: 'no account'
              expect(rendered).not_to have_css '.blockchain-address a'
            end
          end
        end
      end
    end
  end
end
