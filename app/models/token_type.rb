class TokenType
  # See `app/models/token_type/*`

  attr_reader :attrs

  def initialize(**attrs)
    @attrs = attrs
  end

  # List of available types as an attribute for enum definition
  def self.list
    h = { btc: 0, ada: 1, qtum: 2, qrc20: 3, eos: 4, xtz: 5, dag: 6, eth: 7, erc20: 8, comakery: 9 } # Populated automatically by TokenTypeGenerator

    h.values.uniq.size == h.values.size ? h : raise('Invalid list of token types')
  end

  def self.append_to_list(token_type)
    list.merge(token_type => (list.values.max + 1))
  end
end
