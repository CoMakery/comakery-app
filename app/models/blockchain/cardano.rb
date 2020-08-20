class Blockchain::Cardano < Blockchain
  # Template for implementing a new blockchain
  # See parent class at `app/models/blockchain.rb` for details

  def initialize
    super

    # Name of the blockchain for UI purposes
    @name = 'Cardano'

    # Hostname of block explorer API
    @explorer_api_url = 'https://example.org'

    # Hostname of block explorer website
    @explorer_human_url = 'https://example.org'

    # Is mainnet?
    @mainnet = true

    # Number of confirmations to wait before marking transaction as successful
    @number_of_confirmations = 1

    # Seconds to wait between syncs with block explorer API
    @sync_period = 60

    # Maximum number of syncs with block explorer API
    @max_syncs = 10

    # Seconds to wait when transaction is created
    @sync_waiting = 600
  end
end
