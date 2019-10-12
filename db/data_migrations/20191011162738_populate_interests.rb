# Allow increased cyclomatic complexity for the migration:
# rubocop:disable Metrics/CyclomaticComplexity

class PopulateInterests < ActiveRecord::DataMigration
  def up
    Project.includes(:account, :admins, :interested, awards: [:account]).find_each do |project|
      if project.account && !project.interested.include?(project.account)
        project.interested << project.account
      end

      project.admins.each do |admin|
        if admin && !project.interested.include?(admin)
          project.interested << admin
        end
      end

      project.awards.where.not(account: nil) do |award|
        if award.account && !project.interested.include?(award.account)
          project.interested << award.account
        end
      end
    end
  end
end
