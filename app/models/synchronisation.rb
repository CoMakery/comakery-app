class Synchronisation < ApplicationRecord
  belongs_to :synchronisable, polymorphic: true

  enum status: { in_progress: 0, ok: 1, failed: 2 }
end
