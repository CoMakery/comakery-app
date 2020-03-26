class Comakery::Erc20Burn < Comakery::Erc20Transfer
  def valid_method_id?
    input && input[0...8] == '9dc29fac'
  end
end
