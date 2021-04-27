require 'rails_helper'
require 'features/dashboard/wallet_connect_spec'

describe 'project accounts page' do
  it_behaves_like 'having wallet connect button', { path_helper: :project_dashboard_transfers_path }

  let(:account_token_record) { create(:account_token_record) }
  let(:account) { account_token_record.account }
  let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }
  subject { visit project_dashboard_accounts_path(project) }

  before do
    project.safe_add_interested(account)
  end

  context 'with eth security token' do
    context 'when not logged in' do
      it 'lists interested accounts which have eth wallet' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 1)
      end
    end

    context 'when logged in as a project admin' do
      before do
        login(project.account)
      end

      it 'lists interested accounts which have eth wallet' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 1)
      end
    end
  end

  context 'with algorand security token' do
    let(:account_token_record) { build(:algo_sec_dummy_restrictions) }
    let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }

    context 'when not logged in' do
      it 'lists interested accounts which have eth wallet' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 1)
      end
    end

    context 'when logged in as a project admin' do
      before do
        login(project.account)
      end

      it 'lists interested accounts which have eth wallet' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 1)
      end
    end
  end

  context 'without a non-security token' do
    let(:project) { create(:project, visibility: :public_listed) }

    context 'when not logged in' do
      it 'lists interested accounts' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 2)
      end
    end

    context 'when logged in as a project admin' do
      before do
        login(project.account)
      end

      it 'lists interested accounts' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 2)
      end
    end
  end

  context 'without a token' do
    before do
      project.update(token: nil)
    end

    context 'when not logged in' do
      it 'lists interested accounts' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 2)
      end
    end

    context 'when logged in as a project admin' do
      before do
        login(project.account)
      end

      it 'lists interested accounts' do
        subject
        expect(page).to have_css('.account-preview__info__name', count: 2)
      end
    end
  end
end
