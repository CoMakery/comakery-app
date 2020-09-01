shared_examples 'api_authorizable' do
  it { is_expected.to have_one(:api_key).dependent(:destroy) }
end
