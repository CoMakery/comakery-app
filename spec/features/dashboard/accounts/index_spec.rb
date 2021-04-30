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

  context 'with settings', js: true do
    let(:admin) { create(:account, comakery_admin: true) }
    let(:project) { create(:project, account: admin) }
    let(:account) { create(:account) }

    before { login(admin) }

    context 'change permissions' do
      it 'updates account role' do
        subject

        execute_script("document.querySelector('#project_#{project.id}_account_#{account.id} #changePermissionsBtn').click()")

        within('#accountPermissionModal') do
          select 'Admin', from: 'project_role[role]'

          execute_script("document.querySelector('#accountPermissionModal input[type=submit]').click()")
        end

        expect(find('.flash-message-container')).to have_content('Permissions successfully updated')

        expect(account.project_roles.last.reload.role).to eq('admin')
      end
    end
  end
end
