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

  def abi
    JSON.parse(File.read(Rails.root.join('vendor/abi/coin_types/comakery.json')))
  end

  def method
    @method ||= Ethereum::Abi.parse_abi(abi).second.find { |f| f.name == method_name }
  end

  def method_id
    method.signature
  end

  def encode_method_params
    method_params.map do |pr|
      case pr
      when TrueClass, FalseClass
        pr
      when Array
        pr.map(&:to_s)
      else
        pr.to_s
      end
    end
  end

  def encode_method_params_hex
    Ethereum::Encoder.new.encode_arguments(method.inputs, method_params).downcase
  end

  def valid_to?
    to == blockchain_transaction.contract_address.downcase
  end

  def valid_amount?
    value&.zero?
  end

  def valid_method_id?
    input && input[0...8] == method_id
  end

  def valid_method_params?
    input[8..] == encode_method_params_hex
  end

  def valid?(_)
    super \
    && valid_method_id? \
    && valid_method_params?
  end
end
