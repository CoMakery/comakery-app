require 'rest-client'
class Comakery::Airtable
  def initialize
    @token = "Bearer #{ENV['AIRTABLE_API']}"
    @url = "https://api.airtable.com/v0/#{ENV['AIRTABLE_APP']}/SIGN%20UPS"
  end

  def list
    @url += '?maxRecords=10&view=Grid%20view'
    result
  end

  def add_record(params)
    @data = { fields: params }.to_json
    post_result
  end

  private

  def result
    res = RestClient.get(@url, Authorization: @token)
    JSON.parse(res)
  rescue RestClient::Forbidden => e
    { error: e.message }
  end

  def post_result(parse_json = true)
    header = { Authorization: @token, content_type: :json, accept: :json }
    res = RestClient.post(@url, @data, header)
    parse_json ? JSON.parse(res) : res
  end
end
