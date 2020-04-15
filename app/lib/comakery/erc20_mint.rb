class Comakery::Erc20Mint < Comakery::Erc20Transfer
  def valid_method_id?
    input && input[0...8] == '40c10f19'
  end
end
