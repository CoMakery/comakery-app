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
      pre_body = Nokogiri::HTML(view.content_for(:pre_body))
      descriptions = pre_body.css('.description')
      expect(descriptions.count).to eq 1
      description = descriptions.first.inner_html
      expect(description).to match %r{markdown <em>rocks</em>:}
      expect(description).to match %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
    end
  end
end
