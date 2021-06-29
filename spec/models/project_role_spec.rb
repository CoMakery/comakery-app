require 'rails_helper'
require 'models/concerns/invitable_spec'

RSpec.describe ProjectRole, type: :model do
  it_behaves_like 'invitable'

  subject { build(:project_role) }

  it { is_expected.to belong_to(:account).optional }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to define_enum_for(:role).with_values({ interested: 0, admin: 1, observer: 2 }) }
  it { is_expected.to validate_uniqueness_of(:account_id).scoped_to(:project_id).with_message('already has a role in project') }

  context 'with a pending invite' do
    subject { FactoryBot.create(:invite).invitable }

    it { is_expected.not_to validate_presence_of(:account_id) }
    it { is_expected.not_to validate_uniqueness_of(:account_id) }
  end
end
