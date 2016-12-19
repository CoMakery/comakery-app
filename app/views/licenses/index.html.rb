class Views::Licenses::Index < Views::Projects::Base
  needs :project

  def content
    render partial: 'shared/project_header'
    column {
      full_row {
        license = File.read(Rails.root + 'lib/assets/license.md')
        text raw markdown_to_html(license)

        h2 "Project Terms"
        render 'shared/award_form_terms'
      }
    }
  end
end