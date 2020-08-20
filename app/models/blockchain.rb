class Blockchain
  attr_reader :name, :explorer_api_url, :explorer_human_url,
    :mainnet, :number_of_confirmations,
    :sync_period, :max_syncs, :sync_waiting

  def url_for_tx_human(hash)
    "#{explorer_human_url}/tx/#{hash}"
  end

  def url_for_tx_api(hash)
    "#{explorer_api_url}/tx/#{hash}"
  end

  def url_for_address_human(addr)
    "#{explorer_human_url}/addr/#{addr}"
  end

  def url_for_address_api(addr)
    "#{explorer_api_url}/addr/#{addr}"
  end

  def validate_tx_hash(hash)
    raise Blockchain::Tx::ValidationError if hash.blank?
  end

  def validate_addr(addr)
    raise Blockchain::Address::ValidationError if addr.blank?
  end
end
