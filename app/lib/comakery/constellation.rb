class Comakery::Constellation
  attr_reader :network

  def initialize(network)
    @network = network
    explorer
  end

  def explorer
    @explorer ||= ENV.fetch(explorer_var_name)
  rescue KeyError
    raise "Please Set #{explorer_var_name}"
  end

  def tx(hash)
    JSON.parse(URI.open("https://#{explorer}/transactions/#{hash}").read)
  end

  private

    def explorer_var_name
      @explorer_var_name ||= "#{network.upcase}_BLOCK_EXPLORER_URL"
    end
end
