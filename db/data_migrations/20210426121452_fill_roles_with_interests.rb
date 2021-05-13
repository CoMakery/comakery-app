class FillRolesWithInterests < ActiveRecord::DataMigration
  def up
    result = []
    Project.find_each do |project|
      Interest.where(project: project).find_each do |interest|
        result << {
          project_id: interest.project_id,
          account_id: interest.account_id,
          created_at: Time.zone.now,
          updated_at: Time.zone.now
        }
      end
    end
    # we don't care about valdiations here, because records will be unique
    # rubocop:disable Rails/SkipsModelValidations
    ProjectRole.insert_all(result.uniq { |s| s.values_at(:account_id, :project_id) })
    # rubocop:enable Rails/SkipsModelValidations
  end
end
