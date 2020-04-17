class Comakery::Auth::Eth
  attr_reader :nonce, :signature, :public_address

  def self.random_stamp(message)
    "#{messsage} ##{rand(999999999999)}-#{Time.current.in_milliseconds}"
  end

  def initialize(nonce, signature, public_address)
    @nonce = nonce
    @signature = signature
    @public_address = public_address
  end

  def valid?
    public_address == Eth::Utils.public_key_to_address(Eth::Key.personal_recover(nonce, signature))
  end
end
