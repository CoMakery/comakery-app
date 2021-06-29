shared_examples 'invitable' do
  it { is_expected.to have_one(:invite).dependent(:destroy) }

  context 'with accepted invite' do
    let(:invitable) { described_class.new }
    let(:invite) { FactoryBot.build :invite, :accepted, invitable: invitable }

    describe '#account' do
      subject { invitable.account }

      before do
        allow(invitable).to receive(:invite).and_return(invite)
        invitable.valid?
      end

      it { is_expected.to eq(invite.account) }
    end
  end

  describe '#invite_accepted' do
    let(:invitable) { described_class.new }

    subject { invitable.invite_accepted }

    specify do
      expect(invitable).to receive(:populate_account)
      expect(invitable).to receive(:save)

      subject
    end
  end
end
