class Interest < ApplicationRecord
  belongs_to :account
  after_save :add_airtable

  def add_airtable
    params = { "ID": id.to_s, "Account ID": account_id.to_s, "Protocol Interest": protocol.to_s, "Project Interest": project.to_s, "Email Address": account.email.to_s, "First Name": account.first_name.to_s, "Last Name": account.last_name.to_s }
    airtable = Comakery::Airtable.new
    airtable.add_record(params)
  end
end
