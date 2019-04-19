require 'rails_helper'

describe 'contributors/index.html.rb' do
  let!(:project) { create(:project) }

  before do
    assign :current_account, create(:account)
    assign :project, project.decorate
    create(:award, project: project, account: create(:account))
    create(:award, project: project, account: create(:account))
    assign :contributors, project.decorate.contributors_by_award_amount.page(nil)
    assign :table_data, {}
    assign :chart_data, {}
    render
  end

  specify do
    expect(rendered).to have_css 'div[data-react-class="layouts/ProjectSetupHeader"]'
    expect(rendered).to have_css 'div[data-react-class="ContributorsSummaryPieChart"]'
  end
end
