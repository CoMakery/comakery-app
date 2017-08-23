class Views::Projects::AwardSend < Views::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :can_award

  def content
    div(id: 'award-send') do
      row(class: 'awarded-info-header') do
        if can_award
          h3 "Award #{project.payment_description}"
        else
          h3 "Earn #{project.payment_description}"
        end
      end
      row(class: 'help-text') do
        text 'The '
        a(href: project_licenses_path(project)) { text 'Contribution License' }
        text ' refers to this '
        strong "'Award Form' "
        text 'for calculating Contributor Royalties.'
      end
      br
      form_for [project, award] do |f|
        div(class: 'award-types') do
          project.award_types.order('amount asc').decorate.each do |award_type|
            row(class: 'award-type-row') do
              column('small-12') do
                with_errors(project, :account_id) do
                  label do
                    row do
                      if can_award
                        column('small-1') do
                          f.radio_button(:award_type_id, award_type.to_param, disabled: !awardable_types.include?(award_type))
                        end
                      end
                      column(can_award ? "small-10 end #{awardable_types.include?(award_type) ? '' : 'grayed-out'}" : 'small-12') do
                        row do
                          span(award_type.name)
                          span(class: ' financial') do
                            text " (#{award_type.amount_pretty})"
                          end
                          text ' (Community Awardable)' if award_type.community_awardable?
                          br
                          span(class: 'help-text') { text raw(award_type.description_markdown) }
                        end
                      end
                    end
                  end
                end
              end
            end
          end
          if can_award
            row do
              column('small-2') do
                label do
                  text 'Quantity'
                  f.text_field(:quantity, type: :text, default: 1, class: 'financial')
                end
              end
            end
            row do
              column('small-8') do
                label do
                  text 'User'
                  options = capture do
                    options_for_select([[nil, nil]].concat(awardable_authentications))
                  end
                  select_tag 'award[slack_user_id]', options, html: { id: 'award_slack_user_id' }
                end
              end
            end
            row do
              column('small-12') do
                with_errors(project, :description) do
                  label do
                    text 'Description'
                    f.text_area(:description)
                    link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text')
                  end
                end
              end
            end
            row do
              column('small-12') do
                f.submit('Send Award', class: buttonish)
              end
            end
          end
        end
      end
    end
  end
end
