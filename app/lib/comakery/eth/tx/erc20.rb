class Comakery::Eth::Tx::Erc20 < Comakery::Eth::Tx
  def method_id
    '00000000'
  end

  def valid_method_id?
    input && input[0...8] == method_id
  end

  def lookup_method_arg(n, length = 32, offset = 8)
    valid_method_id? && input[(offset + n * (2 * length))...(offset + (n + 1) * (2 * length))]&.to_i(16)
  end
end
