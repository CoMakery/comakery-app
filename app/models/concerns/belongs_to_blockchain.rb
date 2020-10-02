module BelongsToBlockchain
  extend ActiveSupport::Concern

  class BlockchainAddressValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.blockchain&.validate_addr(value) if value.present?
    rescue Blockchain::Address::ValidationError => e
      record.errors.add(attribute, e.message)
    end
  end

  included do
    validates :_blockchain, presence: true
    enum _blockchain: Blockchain.list, _prefix: :_blockchain

    def self.blockchain_for(name)
      "Blockchain::#{name.camelize}".constantize.new
    end

    def blockchain
      @blockchain ||= "Blockchain::#{_blockchain.camelize}".constantize.new if _blockchain
    end

    def tokens_on_same_blockchain
      Token.where(_blockchain: _blockchain)
    end
  end
end
