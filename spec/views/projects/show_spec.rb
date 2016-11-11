require 'rails_helper'

describe "projects/show.html.rb" do

  let(:project) { create(:project, description: 'markdown _rocks_: www.auto.link').decorate }

  before do
    assign :project, project
    assign :award, build(:award)
    assign :award_data, { award_amounts: {total_coins_issued: 0} }
    assign :awardable_authentications, []
    assign :awardable_types, []
    assign :can_award, false

    allow(view).to receive(:policy).and_return(double("project policy", edit?: false))
  end

  describe "Project description" do
    it "renders mardown as HTML" do
      render
      assert_select '.description', html: %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
      assert_select '.description', html: %r{markdown <em>rocks</em>:}
    end
  end
end
