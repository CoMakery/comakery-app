require 'rails_helper'

# NOTE: this test is intended to be an integration test for the ProjectPolicy.
# For comprehensive authorization tests see the project_policy_spec.rb

shared_examples 'can see revenue data' do
  it 'has a revenues link' do
    visit project_path(project)
    expect(page).to have_link 'Revenues'
  end

  it 'can access the revenues page' do
    visit project_revenues_path(project)
    expect(page).to have_current_path(project_revenues_path(project))
  end

  it 'has a contributors link' do
    visit project_path(project)
    expect(page).to have_link 'Contributors'
  end

  it 'can access the contributors page' do
    visit project_contributors_path(project)
    expect(page).to have_current_path(project_contributors_path(project))
  end

  it 'does show revenue data on the overview page' do
    visit project_path(project)
    expect(page).to have_css('.my-share')
    expect(page).to have_css('.my-balance')
  end
end

shared_examples "can't see revenue data" do
  it "doesn't have a revenues link" do
    visit project_path(project)
    expect(page).not_to have_link 'Revenues'
  end
  it "can't access the revenues page" do
    visit project_revenues_path(project)
    expect(page).to have_current_path('/404.html')
  end
  it "doesn't have a contributors link" do
    visit project_path(project)
    expect(page).not_to have_link 'Contributors'
  end
  it "can't access the contributors page" do
    visit project_contributors_path(project)
    expect(page).to have_current_path('/404.html')
  end

  it "doesn't show revenue data on the overview page" do
    visit project_path(project)

    expect(page).not_to have_css('.my-share')
    expect(page).not_to have_css('.my-balance')
  end

  it "doesn't have the awards link" do
    visit project_path(project)
    expect(page).not_to have_link 'Awards'
  end

  it "can't access the awards page" do
    visit project_awards_path(project)
    expect(page).to have_current_path('/404.html')
  end
end

describe 'project confidentiality for the logged in project owner', :js do
  let!(:owner) { create(:account) }
  let!(:owner_auth) { create(:authentication, account: owner, slack_team_id: 'foo', slack_image_32_url: 'http://avatar.com/owner.jpg') }
  let!(:project) { create(:project, public: true, account: owner, slack_team_id: 'foo', require_confidentiality: false, payment_type: :revenue_share, royalty_percentage: 10) }

  before do
    stub_slack_user_list
    stub_slack_channel_list
    login owner
  end
  describe 'public project that requires confidentiality' do
    before do
      project.update_attribute(:public, true)
      project.update_attribute(:require_confidentiality, true)
    end

    it_behaves_like 'can see revenue data'
  end

  describe 'public project that does not require confidentiality' do
    before do
      project.update_attribute(:public, true)
      project.update_attribute(:require_confidentiality, false)
    end

    it_behaves_like 'can see revenue data'
  end

  describe 'private project that requires confidentiality' do
    before do
      project.update_attribute(:public, false)
      project.update_attribute(:require_confidentiality, true)
    end

    it_behaves_like 'can see revenue data'
  end

  describe 'private project that does not require confidentiality' do
    before do
      project.update_attribute(:public, false)
      project.update_attribute(:require_confidentiality, true)
    end

    it_behaves_like 'can see revenue data'
  end
end

describe 'project confidentiality for logged out users', :js do
  let!(:project) { create(:project, public: true, slack_team_id: 'foo', require_confidentiality: false, payment_type: :revenue_share, royalty_percentage: 10) }

  describe 'public project that requires confidentiality' do
    before do
      project.update_attribute(:public, true)
      project.update_attribute(:require_confidentiality, true)
    end

    it "doesn't have a revenues link" do
      visit project_path(project)
      expect(page).not_to have_link 'Revenues'
    end
    it "can't access the revenues page" do
      visit project_revenues_path(project)
      expect(page).to have_current_path(root_path)
    end
    it "doesn't have a contributors link" do
      visit project_path(project)
      expect(page).not_to have_link 'Contributors'
    end
    it "can't access the contributors page" do
      visit project_contributors_path(project)
      expect(page).to have_current_path(root_path)
    end

    it "doesn't show revenue data on the overview page" do
      visit project_path(project)

      expect(page).not_to have_css('.my-share')
      expect(page).not_to have_css('.my-balance')
    end

    it "doesn't have the awards link" do
      visit project_path(project)
      expect(page).not_to have_link 'Awards'
    end

    it "can't access the awards page" do
      visit project_awards_path(project)
      expect(page).to have_current_path(root_path)
    end
  end

    describe 'public project that does not require confidentiality' do
      before do
        project.update_attribute(:public, true)
        project.update_attribute(:require_confidentiality, false)
      end

      it 'has a revenues link' do
        visit project_path(project)
        expect(page).to have_link 'Revenues'
      end

      it 'can access the revenues page' do
        visit project_revenues_path(project)
        expect(page).to have_current_path(project_revenues_path(project))
      end

      it 'has a contributors link' do
        visit project_path(project)
        expect(page).to have_link 'Contributors'
      end

      it 'can access the contributors page' do
        visit project_contributors_path(project)
        expect(page).to have_current_path(project_contributors_path(project))
      end

      it 'does show revenue data on the overview page' do
        visit project_path(project)

        expect(page).not_to have_css('.my-share')
        expect(page).not_to have_css('.my-balance')
      end
    end

  describe 'private project that requires confidentiality' do
    before do
      project.update_attribute(:public, false)
      project.update_attribute(:require_confidentiality, true)
    end

    it_behaves_like "can't see revenue data"
  end

  describe 'private project that does not require confidentiality' do
    before do
      project.update_attribute(:public, false)
      project.update_attribute(:require_confidentiality, true)
    end

    it_behaves_like "can't see revenue data"
  end
end
