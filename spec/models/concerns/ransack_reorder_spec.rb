shared_examples 'ransack_reorder' do
  it { expect(described_class).to respond_to(:ransack_reorder) }
  it { expect(described_class).to respond_to(:add_special_orders) }
end
