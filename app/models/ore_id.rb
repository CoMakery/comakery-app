class OreId < ApplicationRecord
  belongs_to :account
  has_many :wallets, dependent: :destroy
  after_create :schedule_create_remote_ore_id

  def create_remote_ore_id
    # To be called from OreIdJobs::CreateJob

    # Calls Aikon endpoint to create ore_id and sets account_name on success
  end

  def sync_remote_wallets
    # To be called from OreIdJobs::SyncWalletsJob

    # Raises an error if account_name is not present
    # Calls Aikon endpoint to pull list of wallets and creates/populates local ones with addresses, marking them unclaimed
  end

  def reset_password_url
    # Returns password_reset url
  end

  private

    def schedule_create_remote_ore_id
      OreIdJobs::CreateJob.perform_later(self)
    end
end
