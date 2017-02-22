require 'rails_helper'

describe "projects/_award_send.html.rb" do

  let(:project) { create(:project).decorate }
  let!(:award_type) { create :award_type, description: 'markdown _rocks_: www.auto.link', project: project }
  let(:award) { build :award }

  before do
    assign :project, project
    assign :award, award
    assign :awardable_authentications, project.authentications
    assign :awardable_types, project.award_types
    assign :can_award, true

    allow(view).to receive(:policy).and_return(double("project policy", edit?: false))
  end

  describe 'when can award is true' do
    before { assign :can_award, true }
    it "award-types description markdown as HTML" do
      render
      assert_select '.award-types .help-text', html: %r{markdown <em>rocks</em>:}
      assert_select '.award-types .help-text', html: %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
    end
  end

  describe 'when can award is false' do
    before { assign :can_award, false }
    it "award-types description markdown as HTML" do
      render
      assert_select '.award-types .help-text', html: %r{markdown <em>rocks</em>:}
      assert_select '.award-types .help-text', html: %r{<a href="http://www.auto.link"[^>]*>www.auto.link</a>}
    end
  end
end