require 'rails_helper'

describe 'rake migration:update_project_images', type: :task do
  let!(:legacy_project) { create :project }

  before do
    open(Rails.root.join('spec', 'fixtures', '800.png'), 'rb') do |file|
      legacy_project.image = file
    end
    legacy_project.save
  end

  it 'preloads the Rails environment' do
    expect(task.prerequisites).to include 'environment'
  end

  it 'runs gracefully with no subscribers' do
    expect { task.execute }.not_to raise_error
  end

  it 'migrate data' do
    task.execute
    expect(legacy_project.reload.square_image).not_to be_nil
    expect(legacy_project.reload.panoramic_image).not_to be_nil
  end
end
