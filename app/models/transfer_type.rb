class TransferType < ApplicationRecord
  belongs_to :project
  has_many :transfers, class_name: 'Award', dependent: :restrict_with_error

  validates :name, uniqueness: { scope: :project_id, case_sensitive: false }, length: { maximum: 20 }

  before_destroy :raise_if_default
  before_update :raise_if_default

  def self.create_defaults_for(project)
    defaults = %i[earned bought]
    defaults.concat(%i[mint burn]) if project.token&._token_type_comakery?

    defaults.each do |name|
      TransferType.create!(default: true, project: project, name: name)
    end
  end

  private

    def raise_if_default
      raise ActiveRecord::ReadOnlyRecord if default?
    end
end
