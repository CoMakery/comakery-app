class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :award_data, :can_award

  def content
    render partial: 'shared/project_header'

    div(class: "project-head content") {
      render partial: 'description'
    }

    div(class: "project-body content-box") {
      row {
        column("large-6 medium-12") {
          render partial: "award_send"
        }
        column("large-6 medium-12") {

          row(class: 'project-terms') {
            h4 "Project Terms"
            render 'shared/award_form_terms'

          }
          # render partial: 'activity'
        }
      }
      row {
        text "The "
        a(href: project_licenses_path(project)) { text "Contribution License" }
        text " refers to this "
        strong "'Award Form' "
        text "for calculating Contributor Royalties."
      }
    }
  end
end