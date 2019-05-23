# Allow usage of update_column to update even invalid records:
# rubocop:disable Rails/SkipsModelValidations

class SetAllAcceptedAwardsToPaidForProjectsWithNoToken < ActiveRecord::DataMigration
  def up
    Award.accepted.where(
      award_type_id: AwardType.where(
        project_id: Project.where(
          token: nil
        ).pluck(:id)
      ).pluck(:id)
    ).each { |a| a.update_column(:status, :paid) }
  end
end
