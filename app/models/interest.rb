class Interest < ApplicationRecord
  belongs_to :account
  belongs_to :project

  after_create :add_airtable
  validates :project, :protocol, presence: true
  validates :project, uniqueness: { scope: %i[account_id protocol] }

  def add_airtable
    airtable = Comakery::Airtable.new
    airtable.add_record(air_params)
  end

  def air_params
    { "ID": id, "Account ID": account_id, "Protocol Interest": [protocol], "Project Interest": [project], "Email Address": account.email, "First Name": account.first_name, "Last Name": account.last_name }
  end
end
