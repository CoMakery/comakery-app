require 'rails_helper'

describe AuthenticationDecorator do
  it 'get provider' do
    authentication = create :authentication
    expect(authentication.decorate.provider).to eq 'slack'
  end
end
