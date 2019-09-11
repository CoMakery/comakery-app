require 'rails_helper'

describe 'meta_tags' do
  let(:project) { create(:project, visibility: :public_listed) }
  let(:mission) { create(:mission) }

  it 'includes default meta tags' do
    visit root_path

    title = 'CoMakery - Achieve Big Missions'
    description = 'Built from a belief in the power of people, together. With CoMakery, you can gather or join a tribe and work to achieve big missions.'
    image = '/comakery.jpg'

    expect(page).to have_title(title)

    expect(page.has_css?("meta[name='title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[name='description'][content='#{description}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='og:type'][content='website']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:image'][content='#{image}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='twitter:card'][content='summary_large_image']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:image'][content='#{image}']", visible: false)).to be_truthy
  end

  it 'includes custom meta tags for projects landing' do
    visit projects_path

    title = 'CoMakery Projects - Work at the Cutting Edge'
    description = 'Projects from around the world are looking to achieve great things, often leveraging the blockchain to do so. At CoMakery, you can search and find projects to work on and earn tokens or USDC, or even start your own project.'
    image = '/comakery-projects.jpg'

    expect(page).to have_title(title)

    expect(page.has_css?("meta[name='title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[name='description'][content='#{description}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='og:type'][content='website']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:image'][content='#{image}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='twitter:card'][content='summary_large_image']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:image'][content='#{image}']", visible: false)).to be_truthy
  end

  it 'includes custom meta tags for project index' do
    visit project_path(project)

    title = 'CoMakery Project'
    description = "#{project.title}: #{Comakery::Markdown.to_text(project.description)}"
    image = Refile.attachment_url(project, :square_image)

    expect(page).to have_title(title)

    expect(page.has_css?("meta[name='title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[name='description'][content='#{description}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='og:type'][content='website']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:image'][content='#{image}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='twitter:card'][content='summary_large_image']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:image'][content='#{image}']", visible: false)).to be_truthy
  end

  it 'includes custom meta tags for mission page' do
    visit mission_path(mission)

    title = 'CoMakery Mission'
    description = "#{mission.name}: #{mission.description}"
    image = Refile.attachment_url(mission, :image)

    expect(page).to have_title(title)

    expect(page.has_css?("meta[name='title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[name='description'][content='#{description}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='og:type'][content='website']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='og:image'][content='#{image}']", visible: false)).to be_truthy

    expect(page.has_css?("meta[property='twitter:card'][content='summary_large_image']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:url']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:title'][content='#{title}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:description'][content='#{description}']", visible: false)).to be_truthy
    expect(page.has_css?("meta[property='twitter:image'][content='#{image}']", visible: false)).to be_truthy
  end
end
