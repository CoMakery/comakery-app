require 'rails_helper'

describe 'rake migration:update_project_images', type: :task do
  let!(:legacy_project) { create :project }

  before do
    legacy_project.update(square_image_id: nil, panoramic_image_id: nil)

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

  it 'rescues from image magick error' do
    project = create(:project)
    project.update(square_image_id: nil, panoramic_image_id: nil)

    Tempfile.create do |file|
      project.image = file
      project.save
    end

    task.execute
    expect(project.reload.square_image).to be_nil
    expect(project.reload.panoramic_image).to be_nil
  end
end
