class Views::Licenses::Index < Views::Projects::Base
  needs :project

  def content
    render partial: 'shared/project_header'
    column('license-markdown') {
      full_row {
        div(class: 'content-box') {
          h1 "Project Terms"
          render 'shared/award_form_terms'
        }

        div(class: 'content-box') {
          license = File.read(Rails.root + 'lib/assets/license.md')
          text raw markdown_to_legal_doc_html(license)


        }
      }
    }
  end
end