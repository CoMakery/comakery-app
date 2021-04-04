class Comakery::Eth::Tx::Erc20 < Comakery::Eth::Tx
  def to_object(**_args)
    super.merge({
      to: blockchain_transaction.token.contract_address,
      value: encode_value(0),
      contract: {
        abi: blockchain_transaction.token.abi,
        method: method_name,
        parameters: encode_method_params
      }
    })
  end

  def method_name
    ''
  end

  def method_params
    []
  end

  def method_id
    @method_id ||= Ethereum::Abi.parse_abi(
      JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/comakery.json')))
    ).second.find { |f| f.name == method_name }.signature
  end

  def encode_method_params
    method_params.map do |pr|
      case pr
      when TrueClass, FalseClass
        pr
      else
        pr.to_s
      end
    end
  end

  def valid_method_id?
    input && input[0...8] == method_id
  end

  def lookup_method_arg(n, length = 32, offset = 8) # rubocop:todo Naming/MethodParameterName
    valid_method_id? && input[(offset + n * (2 * length))...(offset + (n + 1) * (2 * length))]&.to_i(16)
  end
end
