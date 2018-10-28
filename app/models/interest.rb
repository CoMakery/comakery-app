class Interest < ApplicationRecord
  belongs_to :account
  after_save :add_airtable

  def add_airtable
    params = {"ID": id, "Acount ID": account_id, "Protocol Interest": protocol, "Project Interest", "Email Address": account.email, "First Name": account.first_name, "Last Name": account.last_name}
    airtable = Comakery::Airtable.new
    airtable.add_record(params)
  end
end
