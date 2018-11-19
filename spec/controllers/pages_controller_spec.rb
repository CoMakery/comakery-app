require 'rails_helper'

RSpec.describe PagesController, type: :controller do
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

  it 'access landing page' do
    get :landing
    expect(response).to render_template('pages/landing')
  end

  it 'access home page' do
    account = create :account
    login account
    get :landing
    expect(response).to render_template 'pages/home'
  end

  it 'access featured page' do
    account = create :account, contributor_form: true
    login account
    get :landing
    expect(response).to render_template 'pages/featured'
  end

  it 'access featured page - set contributor form' do
    account = create :account
    login account
    get :featured
    expect(account.reload.finished_contributor_form?).to be_truthy
  end

  it 'create interest' do
    ENV['AIRTABLE_SIGNUPS_TABLE_ID'] = '123qwer'
    account = create :account
    login account
    stub_airtable
    post :add_interest, params: { project: 'Promotion', protocol: 'Vevue', format: :json }
    interest = assigns['interest']
    expect(interest.project).to eq 'Promotion'
    expect(interest.protocol).to eq 'Vevue'
  end

  it 'basic auth' do
    ENV.stub(:key?) { 'test:test' }
    ENV.stub(:fetch) { 'test:test' }
    get :landing
  end
end
