class Views::Shared::AwardFormTerms < Views::Base
  needs :project

  def content
    ul do
      term 'Status', project.status_description
      term 'Project Name', project.title
      term 'Project Owner', project.legal_project_owner
      term 'Contributions', project.exclusive_contributions_text
      term 'Business Confidentiality', project.require_confidentiality_text
      term 'Project confidentiality', project.require_confidentiality_text
      numeric_term "Maximum #{project.payment_description}", project.maximum_tokens_pretty
      numeric_term "Maximum #{project.payment_description} Awarded Per Month", project.maximum_royalties_per_month_pretty
      if project.revenue_share?
        span(class: 'revenue-sharing-only') do
          numeric_term 'Revenue reserved to pay Contributors', project.royalty_percentage_pretty
          numeric_term 'Minimum Revenue Before Revenue Sharing', project.minimum_revenue
          numeric_term 'Minimum Payment to Contributors', project.minimum_payment
          term 'Revenue Sharing End Date', project.revenue_sharing_end_date_pretty
        end
      end
    end

    if project.project_token?
      p do
        text 'Contributors are awarded Project Tokens for contributions. Contributors do not receive Contributor Royalties or Revenue Sharing awards. The value of Project Tokens is not defined by the CoMakery Contributor License, CoMakery Inc, or the CoMakery platform.'
      end
    end
  end

  def term(term_name, trailing_text = '')
    return if trailing_text.blank?
    li do
      strong "#{term_name.titleize}: "
      text trailing_text
    end
  end

  def numeric_term(term_name, trailing_text = '')
    return if trailing_text.blank?
    li do
      strong { text "#{term_name.titleize}: " }
      span(class: 'financial') { text trailing_text }
    end
  end
end
