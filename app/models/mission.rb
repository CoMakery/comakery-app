class Mission < ApplicationRecord
  default_scope { order(display_order: :asc) }

  attachment :logo
  attachment :image
  attachment :whitelabel_logo
  attachment :whitelabel_logo_dark
  attachment :whitelabel_favicon

  has_many :projects, inverse_of: :mission
  has_many :unarchived_projects, -> { where.not visibility: :archived }, source: :projects, class_name: 'Project'
  has_many :public_projects, -> { public_listed }, class_name: 'Project'
  has_many :leaders, through: :public_projects, source: :account
  has_many :tokens, through: :public_projects, source: :token
  has_many :award_types, through: :projects
  has_many :ready_award_types, -> { where state: :ready }, through: :unarchived_projects, source: :award_types, class_name: 'AwardType'
  has_many :published_awards, through: :ready_award_types, source: :awards, class_name: 'Award'
  has_many :awards, through: :award_types
  has_many :interests, through: :public_projects

  enum status: %i[active passive]

  after_create :assign_display_order
  after_save :set_whitelabel_for_projects

  validates :name, :subtitle, :description, :logo, :image, presence: true
  validates :name, length: { maximum: 100 }
  validates :subtitle, length: { maximum: 140 }
  validates :description, length: { maximum: 500 }

  def serialize
    as_json(only: %i[id name token_id subtitle description status display_order]).merge(
      logo_preview: logo.present? ? Refile.attachment_url(self, :logo, :fill, 150, 100) : nil,
      image_preview: image.present? ? Refile.attachment_url(self, :image, :fill, 100, 100) : nil,
      stats: stats
    )
  end

  def stats
    {
      projects: unarchived_projects.size,
      batches: ready_award_types.size,
      tasks: published_awards.in_progress.size,
      interests: interests.size
    }
  end

  private

  def assign_display_order
    self.display_order = id
    save
  end

  def set_whitelabel_for_projects
    projects.update(whitelabel: whitelabel)
  end
end
