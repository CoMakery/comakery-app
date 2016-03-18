class Views::Projects::AwardSend < Views::Base
  needs :project, :award, :awardable_accounts, :awardable_types

  def content
    form_for [project, award] do |f|
      row(class: "award-types") {
        if project.owner_account == current_user
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
                    column("small-1") {
                      f.radio_button(:award_type_id, award_type.to_param, disabled: !awardable_types.include?(award_type))
                    }
                    column("small-11") {
                      span(award_type.name)
                      text " (#{award_type.amount})"
                      text " (Community Awardable)" if award_type.community_awardable?
                    }
                  }
                }
              }
            }
          }
        end
        if awardable_types.any? { |awardable_type| awardable_type.community_awardable? } || project.owner_account == current_user
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
              f.submit("Send Award", class: buttonish(:tiny, :round))
            }
          }
        end
      }
    end
  end
end