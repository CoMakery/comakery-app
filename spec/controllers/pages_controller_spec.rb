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
    get :user_agreement
    expect(response).to render_template('pages/user_agreement')
  end
end
