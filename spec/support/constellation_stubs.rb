module ConstellationStubs
  def stub_constellation_request(network, tx, data) # rubocop:todo Naming/MethodParameterName
    explorer_var_name = "BLOCK_EXPLORER_URL_#{network.upcase}"
    host = (ENV[explorer_var_name] ||= 'dummyhost') && ENV[explorer_var_name]

    stub_request(:get, "https://#{host}/transactions/#{tx}").to_return(
      body: {
        hash: tx
      }.merge(data).to_json
    )
  end
end
