class AwardType < ApplicationRecord
  belongs_to :project, touch: true
  has_many :awards

  validates :project, :specialty, presence: true
  validates :name, length: { maximum: 100 }
  validates :goal, length: { maximum: 250 }
  validates :description, length: { maximum: 750 }

  enum specialty: {
    audio_video_production: 'Audio or Video Production',
    community_development: 'Community Development',
    data_gathering: 'Data Gathering',
    marketing_social: 'Marketing & Social Media',
    software_development: 'Software Development',
    design: 'UX / UI Design',
    writing: 'Writing'
  }
end
