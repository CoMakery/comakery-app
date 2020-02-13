require 'web3/eth'

class Comakery::Web3
  def initialize(network)
    host = case network
           when 'main'
             'mainnet.infura.io'
           else
             "#{network}.infura.io"
    end
    @web3 = Web3::Eth::Rpc.new(
      host: host,
      port: 443,
      connect_options: {
        open_timeout: 20,
        read_timeout: 140,
        use_ssl: true,
        rpc_path: ENV['INFURA_PROJECT_ID'] ? "/v3/#{ENV.fetch('INFURA_PROJECT_ID')}" : nil
      }
    )
  end

  def contract(address, abi = nil)
    @web3.eth.contract(abi || default_abi).at(address)
  end

  def fetch_symbol_and_decimals(address, abi = nil)
    contract = contract(address, abi)
    [
      contract.symbol,
      contract.decimals
    ]
  rescue
    [
      nil,
      nil
    ]
  end

  private

  def default_abi
    [{ 'constant' => true, 'inputs' => [], 'name' => 'supply', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'name', 'outputs' => [{ 'name' => '', 'type' => 'string' }], 'payable' => false, 'type' => 'function' }, { 'constant' => false, 'inputs' => [{ 'name' => '_spender', 'type' => 'address' }, { 'name' => '_value', 'type' => 'uint256' }], 'name' => 'approve', 'outputs' => [{ 'name' => 'success', 'type' => 'bool' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'creationBlock', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'totalSupply', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => false, 'inputs' => [{ 'name' => '_from', 'type' => 'address' }, { 'name' => '_to', 'type' => 'address' }, { 'name' => '_value', 'type' => 'uint256' }], 'name' => 'transferFrom', 'outputs' => [{ 'name' => '', 'type' => 'bool' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'initialOwner', 'outputs' => [{ 'name' => '', 'type' => 'address' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'decimals', 'outputs' => [{ 'name' => '', 'type' => 'uint8' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'version', 'outputs' => [{ 'name' => '', 'type' => 'string' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [{ 'name' => '_account', 'type' => 'address' }], 'name' => 'balanceOf', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'symbol', 'outputs' => [{ 'name' => '', 'type' => 'string' }], 'payable' => false, 'type' => 'function' }, { 'constant' => false, 'inputs' => [{ 'name' => '_to', 'type' => 'address' }, { 'name' => '_value', 'type' => 'uint256' }], 'name' => 'transfer', 'outputs' => [{ 'name' => 'success', 'type' => 'bool' }], 'payable' => false, 'type' => 'function' }, { 'constant' => false, 'inputs' => [{ 'name' => '_target', 'type' => 'address' }, { 'name' => '_timestamp', 'type' => 'uint256' }], 'name' => 'catchYou', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'transfersEnabled', 'outputs' => [{ 'name' => '', 'type' => 'bool' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [], 'name' => 'creationTime', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => true, 'inputs' => [{ 'name' => '_owner', 'type' => 'address' }, { 'name' => '_spender', 'type' => 'address' }], 'name' => 'allowance', 'outputs' => [{ 'name' => '', 'type' => 'uint256' }], 'payable' => false, 'type' => 'function' }, { 'constant' => false, 'inputs' => [{ 'name' => '_transfersEnabled', 'type' => 'bool' }], 'name' => 'enableTransfers', 'outputs' => [{ 'name' => '', 'type' => 'bool' }], 'payable' => false, 'type' => 'function' }, { 'inputs' => [], 'payable' => false, 'type' => 'constructor' }, { 'anonymous' => false, 'inputs' => [{ 'indexed' => true, 'name' => '_from', 'type' => 'address' }, { 'indexed' => true, 'name' => '_to', 'type' => 'address' }, { 'indexed' => false, 'name' => '_value', 'type' => 'uint256' }], 'name' => 'Transfer', 'type' => 'event' }, { 'anonymous' => false, 'inputs' => [{ 'indexed' => true, 'name' => '_owner', 'type' => 'address' }, { 'indexed' => true, 'name' => '_spender', 'type' => 'address' }, { 'indexed' => false, 'name' => '_value', 'type' => 'uint256' }], 'name' => 'Approval', 'type' => 'event' }]
  end
end
