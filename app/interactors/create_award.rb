class CreateAward
  include Interactor

  def call
    award = context.award_type.awards.new(context.award_params)

    award.issuer = context.account

    attach_image_from_source(award) if award.image.blank?

    context.award = award

    context.fail!(errors: award.errors) unless award.save
  end

  private

    def attach_image_from_source(award)
      return unless context.image_from_id

      source_award = Award.find(context.image_from_id.to_i)

      if AwardPolicy.new(context.account, source_award).edit?
        award.image.attach(source_award.image.blob) if source_award.image.attached?
      end
    end
end
