# Destroy all awards which have award_type_id but got the associated award_type deleted, before according validations were implemented.
# Missing award_type brokes award->award_type->project association.

class DestroyAwardsWithBrokenAwardTypeAssociation < ActiveRecord::DataMigration
  def up
    Award.all.reject(&:award_type).each(&:delete)
  end
end
