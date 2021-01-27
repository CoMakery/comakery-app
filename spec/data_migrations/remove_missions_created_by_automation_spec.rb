require 'rails_helper'
require Rails.root.join('db/data_migrations/20210121113148_remove_missions_created_by_automation')

describe RemoveMissionsCreatedByAutomation do
  subject { described_class.new.up }

  before do
    allow(Rails.env).to receive(:production?) { true }
    names = ['Automation 1', 'Automation 2', '1 Automation', 'automation', 'Mission name']
    names.each do |name|
      create(:mission, name: name)
    end
  end

  it 'removes only missions with name that contain `Automation`' do
    expect(Mission.count).to eq(5)

    subject

    expect(Mission.count).to eq(1)
  end
end
