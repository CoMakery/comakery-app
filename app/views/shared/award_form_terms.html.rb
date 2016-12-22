class Views::Shared::AwardFormTerms < Views::Base
  needs :project

  def content
    ul {
      term "Project Name", project.title
      term "Project Owner", project.legal_project_owner, condition: project.legal_project_owner.present?
      term "Contributions", project.exclusive_contributions_text
      term "Business Confidentiality", project.require_confidentiality_text
      term "Project confidentiality", project.require_confidentiality_text
      term "Maximum Unpaid #{project.payment_description} Balance", project.maximum_coins_pretty
      unless project.project_coin?
        div(class: 'royalty-terms') {
          term "Revenue reserved to pay Contributor Royalties", project.royalty_percentage_pretty
          term "Maximum royalties per quarter", project.maximum_royalties_per_quarter_pretty
          term "Minimum Revenue", project.minimum_revenue_pretty
          term "Contributor Minimum Payment", project.minimum_payment_pretty
        }
      end
    }
  end

  def term(term_name, trailing_text = "", condition: true)
    return unless condition
    li {
      strong "#{term_name.titleize}: "
      text trailing_text
    }
  end
end