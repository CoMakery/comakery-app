require 'rails_helper'

RSpec.describe Invite, type: :model do
  subject { FactoryBot.build :invite }

  it { is_expected.to have_secure_token }
  it { is_expected.to belong_to(:invitable) }
  it { is_expected.to belong_to(:account).optional }
  it { is_expected.to validate_uniqueness_of(:email).scoped_to(%i[invitable_id invitable_type]).case_insensitive }

  context 'when invite is created' do
    subject { FactoryBot.create :invite }

    it { expect(subject.token).to be_present }
  end

  context 'when accepted' do
    subject { FactoryBot.build :invite, :accepted }

    it { is_expected.to validate_presence_of(:account) }

    describe '#validate_account_email' do
      context 'when !#force_email' do
        context 'and account email doesnt match' do
          it { is_expected.to be_valid }
        end
      end

      context 'when #force_email' do
        context 'and account email doesnt match' do
          subject { FactoryBot.build :invite, :accepted, force_email: true }

          it { is_expected.not_to be_valid }
        end

        context 'and account email matches' do
          subject { FactoryBot.build :invite, :accepted_with_forced_email }

          it { is_expected.to be_valid }
        end
      end
    end

    describe '#invite_accepted' do
      context 'when saved' do
        specify do
          expect_any_instance_of(ProjectRole).to receive(:invite_accepted)
          subject.save
        end
      end
    end
  end

  describe '#pending' do
    subject { described_class.pending }

    let(:invite_accepted) { FactoryBot.create :invite, :accepted }
    let(:invite_pending) { FactoryBot.create :invite }

    it { is_expected.to include(invite_pending) }
    it { is_expected.not_to include(invite_accepted) }
  end

  describe '#generate_unique_secure_token' do
    subject(:token) { described_class.generate_unique_secure_token }

    it { expect(token.length).to eq(Invite::TOKEN_LENGTH) }
  end
end
