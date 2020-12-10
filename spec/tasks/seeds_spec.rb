require 'rails_helper'

describe 'rake db:seed', type: :task do
  it 'works' do
    expect { task.invoke }.to_not raise_error
    expect(Account.count).to be_positive
    expect(Project.count).to be_positive
    expect(Mission.count).to be_positive
  end
end
