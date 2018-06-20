require 'rails_helper'

describe 'projects/transfer_tokens.html.rb' do
  let(:project) { create(:project).decorate }

  before do
    assign :project, project
    render
  end

  specify do
    expect(rendered).to have_content("Recipient Address")
    expect(rendered).to have_content("Amount")
    expect(rendered).to have_link("Transfer tokens")
  end
end
