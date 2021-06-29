class ProjectRole < ApplicationRecord
  include Invitable

  HUMANIZED_ROLE_NAMES = {
    interested: 'Project Member',
    admin: 'Admin',
    observer: 'Read Only Admin'
  }.freeze

  belongs_to :account, optional: true
  belongs_to :project, counter_cache: true

  validates :account_id, presence: true, if: -> { invite&.accepted? }
  validates :account_id, uniqueness: { scope: %i[project_id], message: 'already has a role in project' }, if: -> { account.present? }

  after_update_commit :broadcast_update, if: :saved_change_to_role?
  after_create_commit :broadcast_create
  after_destroy_commit :broadcast_destroy

  enum role: { interested: 0, admin: 1, observer: 2 }

  private

    def broadcast_update
      broadcast_replace_to "project_#{project.id}_accounts",
                           target: "project_#{project.id}_account_#{account.id}",
                           partial: 'dashboard/accounts/account',
                           locals: { project_role: self }
    end

    def broadcast_create
      broadcast_append_later_to "project_#{project.id}_accounts",
                                target: "project_#{project.id}_accounts",
                                partial: 'dashboard/accounts/account',
                                locals: { project_role: self }
    end

    def broadcast_destroy
      Turbo::StreamsChannel.broadcast_remove_to(
        "project_#{project.id}_accounts",
        target: "project_#{project.id}_account_#{account.id}"
      )
    end
end
