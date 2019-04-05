class Mission < ApplicationRecord
  default_scope { order(display_order: :asc) }

  attachment :logo
  attachment :image

  has_many :projects, inverse_of: :mission
  enum status: %i[active passive]

  after_create :assign_display_order
  validates :name, :subtitle, :description, :logo, :image, presence: true
  validates :name, length: { maximum: 100 }
  validates :subtitle, length: { maximum: 140 }
  validates :description, length: { maximum: 375 }

  def serialize
    as_json(only: %i[id name token_id subtitle description status display_order]).merge(
      logo_preview: logo.present? ? Refile.attachment_url(self, :logo, :fill, 150, 100) : nil,
      image_preview: image.present? ? Refile.attachment_url(self, :image, :fill, 100, 100) : nil
    )
  end

  def project_leaders
    leaders = projects.public_listed.select('accounts.id').joins('left join accounts on projects.account_id=accounts.id')
    project_counts = leaders.group(:account_id).count

    Account.where(id: leaders).limit(4).select('id, first_name, last_name, image_id').map do |account|
      account.as_json.merge(
        count: project_counts[account.id],
        project_name: projects.public_listed.find_by(account_id: account.id).title,
        image_url: account.image.present? ? Refile.attachment_url(account, :image, :fill, 240, 240) : nil
      )
    end
  end

  def project_tokens
    tokens = projects.public_listed.select('tokens.id').joins('left join tokens on projects.token_id=tokens.id')
    project_counts = tokens.group(:token_id).count

    {
      tokens:
        Token.where(id: tokens).limit(4).select('id, name, symbol, coin_type, logo_image_id, ethereum_contract_address, ethereum_network, blockchain_network, contract_address').map do |token|
          token.as_json.merge(
            count: project_counts[token.id],
            project_name: projects.public_listed.find_by(token_id: token.id).title,
            logo_url: token.logo_image.present? ? Refile.attachment_url(token, :logo_image, :fill, 30, 30) : nil,
            contract_url: token.decorate.ethereum_contract_explorer_url
          )
        end,
      token_count: tokens.size
    }
  end

  private

  def assign_display_order
    self.display_order = id
    save
  end
end
