require 'rails_helper'

RSpec.describe TransferType, type: :model do
  let!(:transfer_type) { create(:transfer_type) }

  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to have_many(:transfers) }
  end

  describe 'validations' do
    context 'when name length is more than 20 characters' do
      it 'adds an error' do
        t = build(:transfer_type, name: 'a' * 21)

        expect(t).not_to be_valid
      end
    end

    context 'when name is not unique in context of a project' do
      it 'adds an error' do
        t = build(:transfer_type, name: transfer_type.name, project: transfer_type.project)

        expect(t).not_to be_valid
      end
    end
  end

  describe 'hooks' do
    context 'when trying to destroy a default record' do
      it 'raises an error' do
        t = create(:transfer_type, default: true)
        expect { t.destroy }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end

    context 'when trying to update a default record' do
      it 'raises an error' do
        t = create(:transfer_type, default: true)
        expect { t.update(name: 'a') }.to raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end

  describe 'create_defaults_for' do
    let!(:project) { create(:project) }

    it 'creates default records for a given project' do
      expect(project.reload.transfer_types.size).to eq(2)
    end

    context 'when project uses security token' do
      let!(:project) { create(:project, token: create(:token, _token_type: :comakery_security_token, _blockchain: :ethereum_ropsten)) }

      it 'creates additional default records' do
        expect(project.reload.transfer_types.size).to eq(4)
      end
    end
  end
end
