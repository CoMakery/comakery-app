class Comakery::Auth::Eth
  attr_reader :nonce, :signature, :public_address

  def self.random_stamp(message = nil)
    "#{message}##{rand(999999999999)}-#{DateTime.current.strftime('%Q')}"
  end

  def initialize(nonce, signature, public_address)
    @nonce = nonce
    @signature = signature
    @public_address = public_address
  end

  def recovered_public_key
    @recovered_public_key ||= Eth::Key.personal_recover(nonce, signature)
  end

  def recovered_public_address
    @recovered_public_address ||= (recovered_public_key && Eth::Utils.public_key_to_address(recovered_public_key))
  end

  def valid?
    public_address == recovered_public_address
  end
end
