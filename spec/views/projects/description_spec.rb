require 'rails_helper'

describe "projects/_description.html.rb" do

  let(:project) { create(:project, description: 'markdown _rocks_: www.auto.link').decorate }
  let(:authentication) { create(:authentication).decorate }

  before do
    assign :project, project
    assign :can_award, false

    assign :award_data, {award_amounts: {my_project_coins: 0}}
    assign :current_auth, authentication

    allow(project).to receive(:total_awards_outstanding_pretty).and_return(20)

    allow(view).to receive(:policy).and_return(double("project policy", edit?: false))
  end

  it "renders mardown as HTML" do
    render
    assert_select '.description', html: %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
    assert_select '.description', html: %r{markdown <em>rocks</em>:}
  end

  describe 'revenue sharing project' do
    before do
      project.revenue_share!
      render
    end

    specify do
      expect(rendered).to have_selector('.revenue-percentage')
    end

    specify do
      expect(rendered).to_not have_content "This project does not offer royalties"
    end
  end

  describe 'project coin' do
    before do
      project.project_coin!
      render
    end

    specify { expect(rendered).to_not have_selector('.revenue-percentage') }

    specify { expect(rendered).to have_content "This project does not offer royalties" }

    specify do
      expect(rendered).to have_content "This project does not offer royalties"
    end
  end
end