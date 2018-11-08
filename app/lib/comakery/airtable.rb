require 'rest-client'
class Comakery::Airtable
  def initialize
    @token = "Bearer #{ENV['AIRTABLE_API']}"
    table_name = ENV['AIRTABLE_TABLE_NAME'].gsub(' ','%20')
    @url = "https://api.airtable.com/v0/#{ENV['AIRTABLE_APP']}/#{table_name}"
  end

  def add_record(params)
    @data = { fields: params }.to_json
    post_result
  end

  private

  def post_result(parse_json = true)
    header = { Authorization: @token, content_type: :json, accept: :json }
    res = RestClient.post(@url, @data, header)
    parse_json ? JSON.parse(res) : res
  end
end
