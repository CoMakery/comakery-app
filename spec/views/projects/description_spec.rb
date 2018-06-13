require 'rails_helper'

describe 'projects/_description.html.rb' do
  let(:project) { create(:project, description: 'markdown _rocks_: www.auto.link').decorate }
  let(:authentication) { create(:authentication).decorate }

  before do
    assign :project, project
    assign :can_award, false

    assign :award_data, award_amounts: { my_project_tokens: 0 }
    assign :current_auth, authentication
    assign :current_account_deco, authentication.account.decorate

    allow(project).to receive(:total_awards_outstanding_pretty).and_return(20)

    allow(view).to receive(:policy).and_return(double('project policy', edit?: false))
  end

  it 'renders mardown as HTML' do
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
      expect(rendered).not_to have_content 'This project does not offer royalties'
    end

    specify do
      expect(rendered).not_to have_content('until')
    end
  end

  describe 'revenue sharing with an end date' do
    before do
      project.revenue_share!
      project.update revenue_sharing_end_date: '2123-01-02'
      render
    end

    specify do
      expect(rendered).to have_content("Until #{project.revenue_sharing_end_date_pretty}")
    end
  end

  describe 'project token' do
    before do
      project.project_token!
      render
    end

    specify { expect(rendered).not_to have_selector('.revenue-percentage') }

    specify { expect(rendered).to have_content 'This project does not offer royalties' }

    specify do
      expect(rendered).to have_content 'This project does not offer royalties'
    end
  end
end
