class Views::Projects::AwardSend < Views::Base
  needs :project, :award, :awardable_accounts, :awardable_types, :can_award

  def content
    form_for [project, award] do |f|
      row(class: "award-types") {
        if can_award
          h3 "Send awards"
        else
          h3 "Awards"
        end
        project.award_types.each do |award_type|
          row(class: "award-type-row") {
            column("small-12") {
              with_errors(project, :account_id) {
                label {
                  row {
                    if can_award
                      column("small-1") {
                        f.radio_button(:award_type_id, award_type.to_param, disabled: !awardable_types.include?(award_type))
                      }
                    end
                    column(can_award ? "small-11 #{awardable_types.include?(award_type) ? '' : 'grayed-out'}" : "small-12") {
                      span(award_type.name)
                      text " (#{number_with_precision(award_type.amount, precision: 0, delimiter: ',')})"
                      text " (Community Awardable)" if award_type.community_awardable?
                    }
                  }
                }
              }
            }
          }
        end
        if can_award
          row {
            column("small-8") {
              label {
                text "User"
                options = capture do
                  options_for_select([[nil, nil]].concat(awardable_accounts))
                end
                select_tag "award[slack_user_id]", options, html: {id: "award_slack_user_id"}
              }
            }
          }
          row {
            column("small-12") {
              with_errors(project, :description) {
                label {
                  text "Description"
                  f.text_area(:description)
                }
              }
            }
          }
          row {
            column("small-12") {
              f.submit("Send Award", class: buttonish())
            }
          }
        end
      }
    end
  end
end