require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  it 'access joinus' do
    get :join_us
    expect(response).to render_template('pages/join_us')
  end

  it 'access e-sign disclosure' do
    get :e_sign_disclosure
    expect(response).to render_template('pages/e_sign_disclosure')
  end

  it 'access privacy policy' do
    get :privacy_policy
    expect(response).to render_template('pages/privacy_policy')
  end

  it 'access prohibited use policy' do
    get :prohibited_use
    expect(response).to render_template('pages/prohibited_use')
  end

  it 'access user agreement' do
    # allow(ENV).to receive(:[]).with('BASIC_AUTH').and_return('test:test')
    get :user_agreement
    expect(response).to render_template('pages/user_agreement')
  end

  it 'access featured page' do
    get :featured
    expect(response.status).to eq(200)
  end

  it 'create interest' do
    account = create :account
    project = create :project
    login account
    stub_airtable
    post :add_interest, params: { project_id: project.id, protocol: 'Vevue', format: :json }
    interest = assigns['interest']
    expect(interest.project).to eq project
    expect(interest.protocol).to eq 'Vevue'
  end

  it 'basic auth' do
    ENV.stub(:key?) { 'test:test' }
    ENV.stub(:fetch) { 'test:test' }
    get :featured
  end

  it 'redirects from styleguide page' do
    get :styleguide
    expect(response.status).to eq(302)
  end

  it 'returns styleguide page in dev env' do
    env_backup = Rails.env
    Rails.env  = 'development'
    get :styleguide
    Rails.env = env_backup
    expect(response.status).to eq(200)
  end
end
