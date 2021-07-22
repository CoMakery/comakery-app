require 'rails_helper'
require 'features/dashboard/wallet_connect_spec'

describe 'project accounts page' do
  it_behaves_like 'having wallet connect button', { path_helper: :project_dashboard_transfers_path }

  let(:account_token_record) { create(:account_token_record) }
  let(:account) { account_token_record.account }
  let(:project) { create(:project, visibility: :public_listed, token: account_token_record.token) }
  subject { visit project_dashboard_accounts_path(project) }

  before { project.add_account(account) }

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

  context 'when navigate to three dots menu settings', js: true do
    let(:project) { create(:project) }

    let(:project_admin) { create(:account) }

    let(:account) { create(:account) }

    before do
      project.project_admins << project_admin

      login(project_admin)

      subject
    end

    context 'and change project participant role' do
      let(:role_cell) { find("#project_#{project.id}_account_#{account.id} .transfers-table__transfer__role") }

      it 'successfully updates permissions' do
        expect(role_cell).to have_text('Project Member')

        find("#project_#{project.id}_account_#{account.id} a.dropdown").click()

        find("#project_#{project.id}_account_#{account.id} #change_permissions_btn").click()

        within('#account_permissions_modal') do
          select 'Admin', from: 'project_role[role]'

          find('.btn-primary').click()
        end

        expect(find('.flash-message-container')).to have_content('Permissions successfully updated')

        expect(role_cell).to have_text('Admin')
      end
    end

    context 'and change own role' do
      let(:project_role) { project.project_roles.find_by(account: project_admin) }

      let(:role_cell) { find("#project_#{project.id}_account_#{project_admin.id} .transfers-table__transfer__role") }

      it 'denies action' do
        expect(role_cell).to have_text('Admin')

        find("#project_#{project.id}_account_#{project_admin.id} a.dropdown").click()

        find("#project_#{project.id}_account_#{project_admin.id} #change_permissions_btn").click()

        within('#account_permissions_modal') do
          select 'Read Only Admin', from: 'project_role[role]'

          find('.btn-primary').click()
        end

        expect(find('.flash-message-container')).to have_content('You are not authorized to perform this action')

        expect(role_cell).to have_text('Admin')
      end
    end
  end
end
