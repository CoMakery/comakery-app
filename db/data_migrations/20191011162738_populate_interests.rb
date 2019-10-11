class PopulateInterests < ActiveRecord::DataMigration
  def up
    Project.includes(:account, :admins, :interested, awards: [:account]).find_each do |project|
      project.interested << project.account unless project.interested.include?(project.account)

      project.admins.each do |admin|
        project.interested << admin unless project.interested.include?(admin)
      end

      project.awards.where.not(account: nil) do |award|
        project.interested << award.account unless project.interested.include?(award.account)
      end
    end
  end
end
