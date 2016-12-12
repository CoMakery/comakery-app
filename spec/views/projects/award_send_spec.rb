require 'rails_helper'

describe "projects/_award_send.html.rb" do

  let(:project) do
    create(
        :project,
        title: 'Mindful Inc',
        royalty_percentage: 8,
        legal_project_owner: "The Legal Owner",
        maximum_coins: 200_000,
        maximum_royalties_per_quarter: 27_000,
        minimum_revenue: 170,
        minimum_payment: 27,
        require_confidentiality: true,
        exclusive_contributions: true,
        description: 'markdown _rocks_: www.auto.link').decorate
  end

  before do
    assign :project, project
    assign :award, build(:award)
    assign :award_data, {award_amounts: {total_coins_issued: 0}}
    assign :awardable_authentications, []
    assign :awardable_types, []
    assign :can_award, false
    allow(view).to receive(:policy).and_return(double("project policy", edit?: false))
  end

  it 'renders all fields for royalty projects when present' do
    render
    expect(rendered).to have_content 'The Legal Owner'
    expect(rendered).to have_css '.royalty-terms'
    expect(rendered).to have_content "Revenue Reserved To Pay Contributor Royalties: 8.0%"
    expect(rendered).to have_content "Maximum Royalties: $200,000"
    expect(rendered).to have_content "Maximum Royalties Per Quarter: $27,000"
    expect(rendered).to have_content "Minimum Revenue: $170"
    expect(rendered).to have_content "Contributor Minimum Payment: $27"
    expect(rendered).to have_content "Contributions: are exclusive"
    expect(rendered).to have_content "Business Confidentiality: is required"
    expect(rendered).to have_content "Project Confidentiality: is required"
  end

  specify do
    project.update!(exclusive_contributions: false)
    render

    expect(rendered).to have_content "Contributions: are not exclusive"
  end

  specify do
    project.update!(require_confidentiality: false)
    render
    expect(rendered).to have_content "Business Confidentiality: is not required"
    expect(rendered).to have_content "Project Confidentiality: is not required"
  end
end
