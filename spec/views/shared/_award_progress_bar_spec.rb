require 'rails_helper'

describe 'shared/_award_progress_bar.html.rb' do
  let!(:team) { create :team }
  let(:account) { create(:account, first_name: 'Glenn', last_name: 'Spanky', email: 'gleenn@example.com').tap { |a| create(:authentication, account_id: a.id) } }

  let(:other_team_account) { create(:account, first_name: 'Bob', last_name: 'Junior', email: 'bob@example.com').tap { |a| create(:authentication, account_id: a.id) } }

  let(:project) do
    create(:project,
           title: 'Cats with Lazers Project',
           description: 'cats with lazers',
           account: account,
           public: false)
  end

  before do
    team.build_authentication_team account.authentications.first
  end

  describe 'with no auth' do
    before do
      assign :current_user, nil
      assign :project, project.decorate
      assign :current_account_deco, nil
      render
    end

    specify { expect(rendered).to have_css('.meter-box') }
  end

  describe 'with current auth from the project slack team' do
    before do
      view.stub(:current_user) { account }

      assign :project, project.decorate
      assign :current_account_deco, account.decorate
      render
    end

    specify { expect(rendered).to have_css('.meter-box') }
  end
end
