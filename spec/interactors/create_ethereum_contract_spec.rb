require 'rails_helper'

describe CreateEthereumContract do
  let!(:project) { create(:project) }
  let!(:award_type) { create(:award_type, project: project) }
  let!(:award1) { create(:award, award_type: award_type) }
  let!(:award2) { create(:award, award_type: award_type) }

  it 'should trigger if transitioned_to_ethereum_enabled = true' do
    expect(project).to receive(:transitioned_to_ethereum_enabled?) { true }
    expect(EthereumTokenContractJob).to receive(:perform_async).with(project.id)
    expect(CreateEthereumAwards).to receive(:call).with(awards: [award1, award2])
    CreateEthereumContract.call(project: project)
  end

  it 'should not trigger if transitioned_to_ethereum_enabled = false' do
    expect(project).to receive(:transitioned_to_ethereum_enabled?) { false }
    expect(EthereumTokenContractJob).not_to receive(:perform_async)
    expect(CreateEthereumAwards).not_to receive(:call)
    CreateEthereumContract.call(project: project)
  end
end
