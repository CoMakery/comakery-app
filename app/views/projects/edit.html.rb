class Views::Projects::Edit < Views::Base
  needs :project

  def content
    content_for(:title) { "Editing: #{project.title.strip}" }
    content_for(:description) { project.decorate.description_text(150) }
    full_row { h3 'Project Settings' }
    div(class: 'row') {
      div(class: 'columns large-2') {
        ul(class: 'vertical menu') {
          li { a(href: '#basics') {
              span 'Basics'
            }
          }
          li { a(href: '#communication-channels') {
              span 'Communication Channels'
            }
          }
          li { a(href: '#contribution-license') {
              span 'Contribution License'
            }
          }
          li { a(href: '#awards') {
              span 'Awards'
            }
          }
        }
      }
      div(class: 'columns large-10') {
        render partial: 'settings_form', locals: { project: project.decorate }
      }
    }
  end
end
