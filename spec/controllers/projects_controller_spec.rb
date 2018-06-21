require 'rails_helper'

describe ProjectsController do
  let!(:team) { create :team }
  let!(:authentication) { create(:authentication) }
  let!(:account) { authentication.account }

  let!(:account1) { create :account }
  let!(:authentication1) { create(:authentication, account: account) }

  before do
    team.build_authentication_team authentication
    team.build_authentication_team authentication1
    login(account)
  end

  describe '#unlisted' do
    let!(:public_unlisted_project) { create(:project, account: account, visibility: 'public_unlisted', title: 'Unlisted Project') }
    let!(:member_unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'Unlisted Project') }
    let!(:normal_project) { create :project, account: account }
    let!(:account2) { create :account }
    let!(:authentication2) { create(:authentication, account: account2) }

    it 'everyone can access public unlisted project via long id' do
      get :unlisted, params: { long_id: public_unlisted_project.long_id }
      expect(response.code).to eq '200'
      expect(assigns(:project)).to eq public_unlisted_project
    end

    it 'other team member cannot access member unlisted project' do
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response).to redirect_to(root_url)
    end

    it 'team member can access member unlisted project' do
      team.build_authentication_team authentication2
      login account2
      get :unlisted, params: { long_id: member_unlisted_project.long_id }
      expect(response.code).to eq '302'
      expect(assigns(:project)).to eq member_unlisted_project
    end

    it 'redirect_to project/id page for normal project' do
      login account
      get :unlisted, params: { long_id: normal_project.long_id }
      expect(response).to redirect_to(project_path(normal_project))
    end

    it 'cannot access unlisted project by id' do
      get :show, params: { id: public_unlisted_project.id }
      expect(response).to redirect_to('/404.html')
    end
  end

  describe '#landing' do
    let!(:public_project) { create(:project, visibility: 'public_listed', title: 'public project', account: account) }
    let!(:archived_project) { create(:project, visibility: 'archived', title: 'archived project', account: account) }
    let!(:unlisted_project) { create(:project, account: account, visibility: 'member_unlisted', title: 'unlisted project') }
    let!(:member_project) { create(:project, account: account, visibility: 'member', title: 'member project') }
    let!(:other_member_project) { create(:project, account: account1, visibility: 'member', title: 'other member project') }

    before do
      expect(TopContributors).to receive(:call).exactly(3).times.and_return(double(success?: true, contributors: {}))
      other_member_project.channels.create(team: team, channel_id: 'general')
    end

    it 'returns your private projects, and public projects that *do not* belong to you' do
      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:my_projects].map(&:title)).to match_array(['public project', 'unlisted project', 'member project'])
      expect(assigns[:archived_projects].map(&:title)).to match_array(['archived project'])
      expect(assigns[:team_projects].map(&:title)).to match_array(['other member project'])
    end

    it 'renders nicely even if you are not logged in' do
      logout

      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:archived_projects].map(&:title)).to eq([])
      expect(assigns[:team_projects].map(&:title)).to eq []
      expect(assigns[:my_projects].map(&:title)).to match_array(['public project'])
    end
  end

  describe '#new' do
    context 'when not logged in' do
      it 'redirects you somewhere pretty' do
        session[:account_id] = nil

        get :new

        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when logged in with unconfirmed account' do
      let!(:account1) { create :account, email_confirm_token: '123' }

      it 'redirects to home page' do
        login account1
        get :new
        expect(response.status).to eq(302)
        expect(response).to redirect_to(root_url)
      end
    end

    context 'when slack returns successful api calls' do
      render_views

      it 'works' do
        get :new

        expect(response.status).to eq(200)
        expect(assigns[:project]).to be_a_new_record
        expect(assigns[:project]).not_to be_public
        expect(assigns[:project].maximum_tokens).to eq(1_000_000)
        expect(assigns[:project].award_types.size).to be > 4

        expect(assigns[:project].award_types.first).to be_a_new_record
        expect(assigns[:project].award_types.first.name).to eq('Thanks')
        expect(assigns[:project].award_types.first.amount).to eq(10)
      end
    end
  end

  describe '#create' do
    render_views

    it 'when valid, creates a project and associates it with the current account' do
      expect do
        expect do
          post :create, params: {
            project: {
              title: 'Project title here',
              description: 'Project description here',
              image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              tracker: 'http://github.com/here/is/my/tracker',
              contributor_agreement_url: 'http://docusign.com/here/is/my/signature',
              video_url: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0',
              slack_channel: 'slack_channel',
              maximum_tokens: '150',
              legal_project_owner: 'legal project owner',
              payment_type: 'project_token',
              award_types_attributes: [
                { name: 'Community Award', amount: 10, community_awardable: true },
                { name: 'Small Award', amount: 1000 },
                { name: 'Big Award', amount: 2000 },
                { name: '', amount: '' }
              ]
            }
          }
          expect(response.status).to eq(302)
        end.to change { Project.count }.by(1)
      end.to change { AwardType.count }.by(3)

      project = Project.last
      expect(project.title).to eq('Project title here')
      expect(project.description).to eq('Project description here')
      expect(project.image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.contributor_agreement_url).to eq('http://docusign.com/here/is/my/signature')
      expect(project.video_url).to eq('https://www.youtube.com/watch?v=Dn3ZMhmmzK0')
      expect(project.maximum_tokens).to eq(150)
      expect(project.award_types.first.name).to eq('Community Award')
      expect(project.award_types.first.community_awardable).to eq(true)
      expect(project.award_types.second.name).to eq('Small Award')
      expect(project.award_types.second.community_awardable).to eq(false)
      expect(project.account_id).to eq(account.id)
    end

    it 'when valid, re-renders with errors' do
      expect do
        expect do
          post :create, params: {
            project: {
              # title: "Project title here",
              description: 'Project description here',
              image: fixture_file_upload('helmet_cat.png', 'image/png', :binary),
              tracker: 'http://github.com/here/is/my/tracker',
              award_types_attributes: [
                { name: 'Small Award', amount: 1000, community_awardable: true },
                { name: 'Big Award', amount: 2000 },
                { name: '', amount: '' }
              ]
            }
          }
          expect(response.status).to eq(200)
        end.not_to change { Project.count }
      end.not_to change { AwardType.count }

      expect(flash[:error]).to eq('Project saving failed, please correct the errors below')
      project = assigns[:project]

      expect(project.description).to eq('Project description here')
      expect(project.image).to be_a(Refile::File)
      expect(project.tracker).to eq('http://github.com/here/is/my/tracker')
      expect(project.award_types.first.name).to eq('Small Award')
      expect(project.award_types.first.community_awardable).to eq(true)
      expect(project.account_id).to eq(account.id)
      expect(project.award_types.size).to eq(3) # 2 + 1 template
    end
  end

  context 'with a project' do
    let!(:cat_project) { create(:project, title: 'Cats', description: 'Cats with lazers', account: account) }
    let!(:dog_project) { create(:project, title: 'Dogs', description: 'Dogs with donuts', account: account) }
    let!(:yak_project) { create(:project, title: 'Yaks', description: 'Yaks with parser generaters', account: account) }
    let!(:fox_project) { create(:project, title: 'Foxes', description: 'Foxes with boxes', account: account) }

    describe '#index' do
      let!(:cat_project_award) { create(:award, account: create(:account), award_type: create(:award_type, project: cat_project, amount: 200), created_at: 2.days.ago) }
      let!(:dog_project_award) { create(:award, account: create(:account), award_type: create(:award_type, project: dog_project, amount: 100), created_at: 1.day.ago) }
      let!(:yak_project_award) { create(:award, account: create(:account), award_type: create(:award_type, project: yak_project, amount: 300), created_at: 3.days.ago) }

      before do
        expect(TopContributors).to receive(:call).and_return(double(success?: true, contributors: { cat_project => [], dog_project => [], yak_project => [] }))
      end

      include ActionView::Helpers::DateHelper
      it 'lists the projects ordered by most recent award date desc' do
        get :index

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Dogs Cats Yaks Foxes])
        expect(assigns[:projects].map { |p| time_ago_in_words(p.last_award_created_at) if p.last_award_created_at }).to eq(['1 day', '2 days', '3 days', nil])
        expect(assigns[:project_contributors].keys).to eq([cat_project, dog_project, yak_project])
      end

      it 'allows querying based on the title of the project, ignoring case' do
        get :index, params: { query: 'cats' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(['Cats'])
      end

      it 'allows querying based on the title or description of the project, ignoring case' do
        get :index, params: { query: 'o' }

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Dogs Foxes])
      end

      it 'only show public projects for not login user' do
        logout
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end

      it 'dont show archived projects for not login user' do
        logout
        cat_project.archived!
        fox_project.public_listed!
        get :index
        expect(assigns[:projects].map(&:title)).to eq(['Foxes'])
      end
    end

    describe '#edit' do
      it 'works' do
        get :edit, params: { id: cat_project.to_param }

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
      end
    end

    describe '#update' do
      it 'updates a project' do
        small_award_type = cat_project.award_types.create!(name: 'Small Award', amount: 100, community_awardable: false)
        medium_award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300)
        destroy_me_award_type = cat_project.award_types.create!(name: 'Destroy Me Award', amount: 300)

        expect do
          expect do
            put :update, params: {
              id: cat_project.to_param,
              project: {
                title: 'updated Project title here',
                description: 'updated Project description here',
                tracker: 'http://github.com/here/is/my/tracker/updated',
                award_types_attributes: [
                  { id: small_award_type.to_param, name: 'Small Award', amount: 150, community_awardable: true, _destroy: 'false' },
                  { id: destroy_me_award_type.to_param, _destroy: '1' },
                  { name: 'Big Award', amount: 500, _destroy: 'false' }
                ]
              }
            }
            expect(response.status).to eq(302)
          end.to change { Project.count }.by(0)
        end.to change { AwardType.count }.by(0) # +1 and -1

        expect(flash[:notice]).to eq('Project updated')
        cat_project.reload
        expect(cat_project.title).to eq('updated Project title here')
        expect(cat_project.description).to eq('updated Project description here')
        expect(cat_project.tracker).to eq('http://github.com/here/is/my/tracker/updated')

        award_types = cat_project.award_types.order(:amount)
        expect(award_types.size).to eq(3)
        expect(award_types.first.name).to eq('Small Award')
        expect(award_types.first.amount).to eq(150)
        expect(award_types.first.community_awardable).to eq(true)
        expect(award_types.second.name).to eq('Medium Award')
        expect(award_types.second.amount).to eq(300)
        expect(award_types.third.name).to eq('Big Award')
        expect(award_types.third.amount).to eq(500)
      end

      context 'with rendered views' do
        render_views
        it 're-renders with errors when updating fails' do
          small_award_type = cat_project.award_types.create!(name: 'Small Award', amount: 100)
          medium_award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300)
          destroy_me_award_type = cat_project.award_types.create!(name: 'Destroy Me Award', amount: 400)

          expect do
            expect do
              put :update, params: {
                id: cat_project.to_param,
                project: {
                  title: '',
                  description: 'updated Project description here',
                  tracker: 'http://github.com/here/is/my/tracker/updated',
                  legal_project_owner: 'legal project owner',
                  payment_type: 'project_token',
                  award_types_attributes: [
                    { id: small_award_type.to_param, name: 'Small Award', amount: 150, _destroy: 'false' },
                    { id: destroy_me_award_type.to_param, _destroy: '1' },
                    { name: 'Big Award', amount: 500, _destroy: 'false' }
                  ]
                }
              }
              expect(response.status).to eq(200)
            end.not_to change { Project.count }
          end.not_to change { AwardType.count }

          project = assigns[:project]
          expect(flash[:error]).to eq('Project update failed, please correct the errors below')
          expect(project.title).to eq('')
          expect(project.description).to eq('updated Project description here')
          expect(project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
          award_types = project.award_types.sort_by(&:amount)
          expect(award_types.size).to eq((expected_rows = 4) + (expected_template_rows = 1))

          expect(award_types.first.name).to be_nil
          expect(award_types.first.amount).to eq(0)

          expect(award_types.second.name).to eq('Small Award')
          expect(award_types.second.amount).to eq(150)
          expect(award_types.third.name).to eq('Medium Award')
          expect(award_types.third.amount).to eq(300)
          expect(award_types.fourth.name).to eq('Destroy Me Award')
          expect(award_types.fourth.amount).to eq(400)
          expect(award_types.fifth.name).to eq('Big Award')
          expect(award_types.fifth.amount).to eq(500)
        end
      end

      it "doesn't allow modification of award_types' amounts when the award_type has awards already sent" do
        award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300).tap do |award_type|
          create(:award, award_type: award_type)
        end

        expect do
          expect do
            put :update, params: {
              id: cat_project.to_param,
              project: {
                legal_project_owner: 'legal project owner',
                payment_type: 'project_token',
                award_types_attributes: [
                  { id: award_type.to_param, name: 'Bigger Award', amount: 500 }
                ]
              }
            }
            expect(response.status).to eq(200)
            expect(flash[:error]).to eq('Project update failed, please correct the errors below')
          end.not_to change { Project.count }
        end.not_to change { AwardType.count }
      end

      it "does allow modification of award_types' non-amount attributes when the award_type has awards already sent" do
        award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300, community_awardable: false)
        create(:award, award_type: award_type)

        expect do
          expect do
            put :update, params: {
              id: cat_project.to_param,
              project: {
                award_types_attributes: [
                  { id: award_type.to_param, name: 'Bigger Award', community_awardable: true, amount: award_type.amount }
                ]
              }
            }
            expect(response.status).to eq(302)
          end.not_to change { Project.count }
        end.not_to change { AwardType.count }

        expect(flash[:notice]).to eq('Project updated')
        award_type.reload
        expect(award_type.name).to eq('Bigger Award')
        expect(award_type).to be_community_awardable
      end
    end

    describe '#show' do
      let!(:cat_award_type) { create(:award_type, name: 'cat award type', project: cat_project, community_awardable: false) }
      let!(:cat_award_type_community) { create(:award_type, name: 'cat award type community', project: cat_project, community_awardable: true) }
      let!(:awardable_auth) { create(:authentication) }

      before do
        expect(GetAwardData).to receive(:call).and_return(double(award_data: { contributions: [], award_amounts: { my_project_tokens: 0, total_tokens_issued: 0 } }))
        expect(GetAwardableTypes).to receive(:call).and_return(double(awardable_types: [cat_award_type, cat_award_type_community], can_award: true))
      end

      context 'when on team' do
        it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
          login(account)
          get :show, params: { id: cat_project.to_param }

          # expect(response.code).to eq '200'
          expect(assigns(:project)).to eq cat_project
          expect(assigns[:award]).to be_new_record
          expect(assigns[:can_award]).to eq(true)
          expect(assigns[:awardable_types].map(&:name).sort).to eq(['cat award type', 'cat award type community'])
          expect(assigns[:award_data]).to eq(contributions: [], award_amounts: { my_project_tokens: 0, total_tokens_issued: 0 })
        end
      end
    end
  end
end
