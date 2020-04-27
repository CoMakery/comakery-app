require 'rails_helper'

RSpec.describe Interest, type: :model do
  let!(:account) { create(:account) }
  let!(:project) { create(:project, visibility: :public_listed) }
  let!(:specialty) { create(:specialty) }

  describe 'associations' do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:specialty) }
  end

  describe 'validations' do
    context 'when creating interest with the same project, account and specialty' do
      before do
        create(:interest, account: account, project: project, specialty: specialty)
      end

      it 'adds an error' do
        i = build(:interest, account: account, project: project, specialty: specialty)

        expect(i).not_to be_valid
        expect(i.errors.full_messages).to eq(['Project has already been followed'])
      end
    end
  end

  describe 'hooks' do
    context 'when account is project owner or admin' do
      it 'aborts destroy' do
        i = project.interests.where(account: project.account).first
        i.destroy

        expect(i).not_to be_destroyed
        expect(i.errors.full_messages).to eq(['Project cannot be unfollowed by an admin'])
      end
    end
  end
end
