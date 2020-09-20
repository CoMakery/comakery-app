class Comakery::Constellation
  attr_reader :host

  def initialize(host)
    @host = host
  end

  def tx(hash)
    JSON.parse(URI.open("https://#{host}/transactions/#{hash}").read)
  end
end
