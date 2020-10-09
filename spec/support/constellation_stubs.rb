module ConstellationStubs
  def stub_constellation_request(host, tx, data) # rubocop:todo Naming/MethodParameterName
    stub_request(:get, "https://#{host}/transactions/#{tx}").to_return(
      body: {
        hash: tx
      }.merge(data).to_json
    )
  end
end
