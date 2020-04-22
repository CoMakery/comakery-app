class Comakery::Auth::Eth
  attr_reader :nonce, :signature, :public_address

  def self.random_stamp(message = nil)
    "#{message}##{DateTime.current.strftime('%Q')}-#{SecureRandom.hex(6)}"
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

  def timestamp
    @timestamp ||= nonce.match(/#(\d+)\-.{12}$/)&.to_a&.fetch(1)&.to_i
  end

  def timestamp_valid?
    timestamp && timestamp > (1.hour.ago.to_i * 1000)
  end

  def valid?
    timestamp_valid? && public_address.casecmp?(recovered_public_address)
  end
end
