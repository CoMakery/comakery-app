# Allow increased cyclomatic complexity for the migration:
# rubocop:disable Metrics/CyclomaticComplexity

class PopulateInterests < ActiveRecord::DataMigration
  def up
    Project.includes(:account, :admins, :interested, awards: [:account]).find_each do |project|
      project.interests.create(account: project.account) if project.account && !project.interested.include?(project.account)

      project.admins.each do |admin|
        project.interests.create(account: admin) if admin && !project.interested.include?(admin)
      end

      project.awards.where.not(account: nil).each do |award|
        project.interests.create(account: award.account) if award.account && !project.interested.include?(award.account)
      end
    end
  end
end
