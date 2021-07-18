require 'rails_helper'

describe ProjectRoleDecorator do
  describe '.roles_pretty' do
    subject { described_class.roles_pretty }

    it { is_expected.to be_a(Hash) }
  end

  describe '.role_options_for_select' do
    subject { described_class.role_options_for_select }

    it { is_expected.to be_an(Array) }
  end

  describe '#role_pretty' do
    subject { project_role.decorate.role_pretty }

    context 'for an interested role' do
      let(:project_role) { FactoryBot.build(:project_role, :interested) }

      it { is_expected.to eq('Project Member') }
    end

    context 'for an admin role' do
      let(:project_role) { FactoryBot.build(:project_role, :admin) }

      it { is_expected.to eq('Admin') }
    end

    context 'for an observer role' do
      let(:project_role) { FactoryBot.build(:project_role, :observer) }

      it { is_expected.to eq('Read Only Admin') }
    end
  end
end
