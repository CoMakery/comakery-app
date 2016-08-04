require 'rails_helper'

describe CreateEthereumContract do
  let!(:project) { create(:project) }

  it 'should trigger if transitioned_to_ethereum_enabled = true' do
    expect(project).to receive(:transitioned_to_ethereum_enabled?) { true }
    expect(EthereumTokenContractJob).to receive(:perform_async).with(project.id)
    CreateEthereumContract.call(project: project)
  end

  it 'should not trigger if transitioned_to_ethereum_enabled = false' do
    expect(project).to receive(:transitioned_to_ethereum_enabled?) { false }
    expect(EthereumTokenContractJob).not_to receive(:perform_async)
    CreateEthereumContract.call(project: project)
  end
end
