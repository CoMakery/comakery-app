class Views::Licenses::Index < Views::Projects::Base
  needs :project

  def content
    render partial: 'shared/project_header'
    column('license-markdown') do
      full_row do
        div(class: 'content-box') do
          h1 'Project Terms'
          render 'shared/award_form_terms'
        end

        div(class: 'content-box') do
          license = File.read(Rails.root + 'lib/assets/license.md')
          text raw markdown_to_legal_doc_html(license)
        end
      end
    end
  end
end
