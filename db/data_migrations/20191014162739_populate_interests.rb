# Allow increased cyclomatic complexity for the migration:
# rubocop:disable Metrics/CyclomaticComplexity

class PopulateInterests < ActiveRecord::DataMigration
  def up
    Project.includes(:account, :admins, :interested, awards: [:account]).find_each do |project|
      if project.account && !project.interested.include?(project.account)
        project.interests.create(account: project.account)
      end

      project.admins.each do |admin|
        if admin && !project.interested.include?(admin)
          project.interests.create(account: admin)
        end
      end

      project.awards.where.not(account: nil).each do |award|
        if award.account && !project.interested.include?(award.account)
          project.interests.create(account: award.account)
        end
      end
    end
  end
end
