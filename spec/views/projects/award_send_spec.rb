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
    expect(rendered).to include('The Legal Owner')
    expect(rendered).to include('royalty-terms')
    expect(rendered).to include "8.0% of revenue is reserved to pay contributor"
    expect(rendered).to include "$200,000 maximum royalty awards"
    expect(rendered).to include "$27,000 maximum royalties can be awarded each quarter"
    expect(rendered).to include "$170 minimum revenue"
    expect(rendered).to include "$27 minimum payment"
    expect(rendered).to include "Contributions are exclusive"
    expect(rendered).to include "Confidentiality is required"
  end

  specify do
    project.update!(exclusive_contributions: false)
    render
    expect(rendered).to_not include "exclusive"
  end

  specify do
    project.update!(require_confidentiality: false)
    render
    expect(rendered).to_not include "Confidentiality is required"
  end
end
