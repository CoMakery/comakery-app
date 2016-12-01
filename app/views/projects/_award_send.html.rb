class Views::Projects::AwardSend < Views::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :can_award

  def content
    form_for [project, award] do |f|
      row(class: "award-types") {
        if can_award
          h3 "Award #{project.payment_description}"
        else
          h3 "Awards"
        end
        project.award_types.order("amount asc").each do |award_type|
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
                    column(can_award ? "small-10 end #{awardable_types.include?(award_type) ? '' : 'grayed-out'}" : "small-12") {
                      span(award_type.name)
                      text " (#{project.currency_denomination}#{number_with_precision(award_type.amount, precision: 0, delimiter: ',')})"
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
                  options_for_select([[nil, nil]].concat(awardable_authentications))
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
                  link_to("Styling with Markdown is Supported", "https://guides.github.com/features/mastering-markdown/", class: "help-text")
                }
              }
            }
          }
          row {
            column("small-12") {
              f.submit("Send Award", class: buttonish)
            }
          }
        end
      }

      row(class: 'project-terms') {
        h4 "Terms"

        ul {
          li_if(project.legal_project_owner) { text "#{project.legal_project_owner} is the project owner" }
          li_if(project.exclusive_contributions) { text "Contributions are exclusive" }
          li_if(project.business_confidentiality) { text "Business confidentiality is required" }
          li_if(project.project_confidentiality) { text "Project confidentiality is required" }
        }
        unless project.project_coin?
          div(class: 'royalty-terms'){
            h6 "Contributor Royalties"
            ul {
              li { text "#{project.royalty_percentage_pretty} of revenue is reserved to pay contributor royalties" }
              li { text "#{project.maximum_coins_pretty} maximum royalty awards" }
              li { text "#{project.maximum_royalties_per_quarter_pretty} maximum royalties can be awarded each quarter" }
              li { text "#{project.minimum_revenue_pretty} minimum revenue accumulated before paying the first royalty payment" }
              li { text "#{project.minimum_payment_pretty} minimum payment per contributor" }

            }
            div(class: 'help-text') {
              text "This is the 'Award Form' that the contribution license references for calculating 'Contributor Royalties'."
            }
          }
        end
      }
    end
  end

  def li_if(variable)
    if variable.present?
      li { yield }
    end
  end
end
