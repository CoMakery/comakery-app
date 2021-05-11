require 'rails_helper'

RSpec.describe ProjectRole, type: :model do
  subject { build(:project_role) }

  it { is_expected.to belong_to(:account) }

  it { is_expected.to belong_to(:project) }

  it { is_expected.to define_enum_for(:role).with_values({ interested: 0, admin: 1, observer: 2 }) }

  it { expect(subject).to validate_uniqueness_of(:account_id).scoped_to(:project_id).with_message('already has a role in project') }
end
