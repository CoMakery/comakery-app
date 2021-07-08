shared_examples 'unavailable_for_lockup_token' do
  context 'with a lockup token' do
    before do
      allow_any_instance_of(Token).to receive(:token_type).and_return(TokenType::TokenReleaseSchedule.new)
    end

    it { is_expected.to redirect_to(project_url(project)) }
  end
end
