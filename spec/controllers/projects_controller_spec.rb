require 'rails_helper'

describe ProjectsController do
  let!(:account) { create(:account, email: 'account@example.com').tap { |a| create(:authentication, account: a, slack_team_id: 'foo', slack_user_name: 'account', slack_user_id: 'account slack_user_id', slack_team_domain: 'foobar') } }

  before { login(account) }

  describe '#landing' do
    let!(:other_public_project) { create(:project, slack_team_id: 'somebody else', public: true, title: 'other_public_project') }
    let!(:other_private_project) { create(:project, slack_team_id: 'somebody else', public: false, title: 'other_private_project') }
    let!(:my_private_project) { create(:project, slack_team_id: 'foo', title: 'my_private_project') }
    let!(:my_public_project) { create(:project, slack_team_id: 'foo', public: true, title: 'my_public_project') }

    before do
      expect(TopContributors).to receive(:call).twice.and_return(double(success?: true, contributors: {}))
    end

    it 'returns your private projects, and public projects that *do not* belong to you' do
      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:private_projects].map(&:title)).to match_array(%w[my_private_project my_public_project])
      expect(assigns[:public_projects].map(&:title)).to match_array(['other_public_project'])
      expect(assigns[:private_project_contributors].keys).to eq([])
      expect(assigns[:public_project_contributors].keys).to eq([])
    end

    it 'renders nicely even if you are not logged in' do
      logout

      get :landing

      expect(response.status).to eq(200)
      expect(assigns[:private_projects].map(&:title)).to eq([])
      expect(assigns[:public_projects].map(&:title)).to match_array(%w[my_public_project other_public_project])
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

    context 'when slack returns successful api calls' do
      render_views

      before do
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: %w[foo bar]))
      end

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

        expect(assigns[:slack_channels]).to eq(%w[foo bar])
      end
    end
  end

  describe '#create' do
    render_views

    it 'when valid, creates a project and associates it with the current account' do
      expect do
        expect do
          post :create, project: {
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
      expect(project.owner_account_id).to eq(account.id)
      expect(project.slack_channel).to eq('slack_channel')
      expect(project.slack_team_id).to eq(account.authentications.first.slack_team_id)
      expect(project.slack_team_name).to eq(account.authentications.first.slack_team_name)
    end

    it 'when valid, re-renders with errors' do
      expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: %w[foo bar]))

      expect do
        expect do
          post :create, project: {
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
      expect(project.owner_account_id).to eq(account.id)

      account_slack_auth = account.authentications.first

      expect(project.slack_team_id).to eq(account_slack_auth.slack_team_id)
      expect(project.slack_team_name).to eq(account_slack_auth.slack_team_name)
      expect(project.slack_team_domain).to eq('foobar')
      expect(project.award_types.size).to eq(3) # 2 + 1 template
    end
  end

  context 'with a project' do
    let!(:cat_project) { create(:project, title: 'Cats', description: 'Cats with lazers', owner_account: account, slack_team_id: 'foo') }
    let!(:dog_project) { create(:project, title: 'Dogs', description: 'Dogs with donuts', owner_account: account, slack_team_id: 'foo') }
    let!(:yak_project) { create(:project, title: 'Yaks', description: 'Yaks with parser generaters', owner_account: account, slack_team_id: 'foo') }
    let!(:fox_project) { create(:project, title: 'Foxes', description: 'Foxes with boxes', owner_account: account, slack_team_id: 'foo') }

    describe '#index' do
      let!(:cat_project_award) { create(:award, authentication: create(:authentication, slack_team_id: 'foo', slack_team_image_132_url: 'http://auth_avatar_2.jpg'), award_type: create(:award_type, project: cat_project, amount: 200), created_at: 2.days.ago) }
      let!(:dog_project_award) { create(:award, authentication: create(:authentication, slack_team_id: 'foo', slack_team_image_132_url: 'http://auth_avatar_1.jpg'), award_type: create(:award_type, project: dog_project, amount: 100), created_at: 1.day.ago) }
      let!(:yak_project_award) { create(:award, authentication: create(:authentication, slack_team_id: 'foo', slack_team_image_132_url: 'http://auth_avatar_3.jpg'), award_type: create(:award_type, project: yak_project, amount: 300), created_at: 3.days.ago) }

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
        get :index, query: 'cats'

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(['Cats'])
      end

      it 'allows querying based on the title or description of the project, ignoring case' do
        get :index, query: 'o'

        expect(response.status).to eq(200)
        expect(assigns[:projects].map(&:title)).to eq(%w[Dogs Foxes])
      end
    end

    describe '#edit' do
      before do
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: %w[foo bar]))
      end

      it 'works' do
        get :edit, id: cat_project.to_param

        expect(response.status).to eq(200)
        expect(assigns[:project]).to eq(cat_project)
        expect(assigns[:slack_channels]).to eq(%w[foo bar])
      end
    end

    describe '#update' do
      it 'updates a project' do
        small_award_type = cat_project.award_types.create!(name: 'Small Award', amount: 100, community_awardable: false)
        medium_award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300)
        destroy_me_award_type = cat_project.award_types.create!(name: 'Destroy Me Award', amount: 300)

        expect do
          expect do
            put :update, id: cat_project.to_param,
                         project: {
                           title: 'updated Project title here',
                           description: 'updated Project description here',
                           tracker: 'http://github.com/here/is/my/tracker/updated',
                           award_types_attributes: [
                             { id: small_award_type.to_param, name: 'Small Award', amount: 150, community_awardable: true },
                             { id: destroy_me_award_type.to_param, _destroy: true },
                             { name: 'Big Award', amount: 500 }
                           ]
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
          expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: %w[foo bar]))

          small_award_type = cat_project.award_types.create!(name: 'Small Award', amount: 100)
          medium_award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300)
          destroy_me_award_type = cat_project.award_types.create!(name: 'Destroy Me Award', amount: 400)

          expect do
            expect do
              put :update, id: cat_project.to_param,
                           project: {
                             title: '',
                             description: 'updated Project description here',
                             tracker: 'http://github.com/here/is/my/tracker/updated',
                             legal_project_owner: 'legal project owner',
                             payment_type: 'project_token',
                             award_types_attributes: [
                               { id: small_award_type.to_param, name: 'Small Award', amount: 150 },
                               { id: destroy_me_award_type.to_param, _destroy: true },
                               { name: 'Big Award', amount: 500 }
                             ]
                           }
              expect(response.status).to eq(200)
            end.not_to change { Project.count }
          end.not_to change { AwardType.count }

          project = assigns[:project]
          expect(flash[:error]).to eq('Project update failed, please correct the errors below')
          expect(project.title).to eq('')
          expect(project.description).to eq('updated Project description here')
          expect(project.tracker).to eq('http://github.com/here/is/my/tracker/updated')
          expect(assigns[:slack_channels]).to eq(%w[foo bar])

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
        expect(GetSlackChannels).to receive(:call).and_return(double(success?: true, channels: %w[foo bar]))

        award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300).tap do |award_type|
          create(:award, award_type: award_type)
        end

        expect do
          expect do
            put :update, id: cat_project.to_param,
                         project: {
                           legal_project_owner: 'legal project owner',
                           payment_type: 'project_token',
                           award_types_attributes: [
                             { id: award_type.to_param, name: 'Bigger Award', amount: 500 }
                           ]
                         }
            expect(response.status).to eq(200)
            expect(flash[:error]).to eq('Project update failed, please correct the errors below')
          end.not_to change { Project.count }
        end.not_to change { AwardType.count }
      end

      it "does allow modification of award_types' non-amount attributes when the award_type has awards already sent" do
        award_type = cat_project.award_types.create!(name: 'Medium Award', amount: 300, community_awardable: false).tap do |award_type|
          create(:award, award_type: award_type)
        end

        expect do
          expect do
            put :update, id: cat_project.to_param,
                         project: {
                           award_types_attributes: [
                             { id: award_type.to_param, name: 'Bigger Award', community_awardable: true, amount: award_type.amount }
                           ]
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
      let!(:awardable_auth) { create(:authentication, slack_team_id: 'foo', slack_user_name: 'account2') }

      context 'when on team' do
        before do
          expect(GetAwardableAuthentications).to receive(:call).and_return(double(awardable_authentications: [awardable_auth]))
          expect(GetAwardData).to receive(:call).and_return(double(award_data: { contributions: [], award_amounts: { my_project_tokens: 0, total_tokens_issued: 0 } }))
          expect(GetAwardableTypes).to receive(:call).and_return(double(awardable_types: [cat_award_type, cat_award_type_community], can_award: true))
        end

        it 'allows team members to view projects and assigns awardable accounts from slack api and db and de-dups' do
          get :show, id: cat_project.to_param

          expect(response.code).to eq '200'
          expect(assigns(:project)).to eq cat_project
          expect(assigns[:award]).to be_new_record
          expect(assigns[:awardable_authentications]).to eq([awardable_auth])
          expect(assigns[:can_award]).to eq(true)
          expect(assigns[:awardable_types].map(&:name).sort).to eq(['cat award type', 'cat award type community'])
          expect(assigns[:award_data]).to eq(contributions: [], award_amounts: { my_project_tokens: 0, total_tokens_issued: 0 })
        end
      end

      it 'only denies non-owners to view projects' do
        cat_project.update(slack_team_id: 'some other team')

        get :show, id: cat_project.to_param

        expect(response.status).to eq(302)
        expect(assigns(:project)).to eq(cat_project)
      end
    end
  end
end
