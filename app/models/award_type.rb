class AwardType < ActiveRecord::Base
  belongs_to :project
  has_many :awards, dependent: :restrict_with_exception

  validates_presence_of :project, :name, :amount

  def self.invalid_params(attributes)
    attributes['name'].blank? || attributes['amount'].blank?
  end
end
