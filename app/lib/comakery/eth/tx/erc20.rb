class Comakery::Eth::Tx::Erc20 < Comakery::Eth::Tx
  def to_object(**_args)
    super.merge({
      to: blockchain_transaction.token.contract_address,
      value: encode_value(0),
      contract: {
        abi: method_abi,
        method: method_name,
        parameters: encode_method_params_json
      }
    })
  end

  def method_name
    raise NotImplementedError, 'This method should be defined in a child class'
  end

  def method_params
    raise NotImplementedError, 'This method should be defined in a child class'
  end

  def method_abi
    [
      blockchain_transaction.token.abi.find do |func|
        func['name'] == method_name
      end
    ]
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

  def encode_method_params_json
    encode_method_params_json_recursive(method_params)
  end

  def encode_method_params_json_recursive(params)
    params.map do |param|
      case param
      when TrueClass, FalseClass
        param
      when Array
        encode_method_params_json_recursive(param)
      else
        param.to_s
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

  def valid?(_ = nil)
    super \
    && valid_method_id? \
    && valid_method_params?
  end
end
