# frozen_string_literal: true

module Transfers
  class Update
    include Interactor

    def call
      transfer = context.project.awards.find(context.award_id)

      if transfer.update(context.transfer_params)
        context.transfer = transfer
      else
        context.fail!(error: transfer.errors.full_messages.join(', '))
      end
    end
  end
end
