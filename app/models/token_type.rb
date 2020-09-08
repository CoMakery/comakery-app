class TokenType
  # See `app/models/token_type/*`

  # List of available types as an attribute for enum definition
  def self.list
    {
      btc: 0,
      ada: 1,
      qtum: 2,
      qrc20: 3,
      eos: 4,
      xtz: 5,
      dag: 6,
      eth: 7,
      erc20: 8,
      comakery: 9
    }
  end
end
