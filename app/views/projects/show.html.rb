class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :award_data, :can_award

  def content
    render partial: 'shared/project_header'

    div(class: "project-head") {
      render partial: 'description'
    }

    div(class: "project-body") {
      row {
        column("large-6 medium-12") {
          render partial: "award_send"
        }
        column("large-6 medium-12") {
          render partial: 'activity'
        }
      }
    }
  end
end