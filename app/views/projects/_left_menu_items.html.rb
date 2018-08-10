class Views::Projects::LeftMenuItems < Views::Base
  def content
    ul(class: 'vertical menu scrollingBox') {
      li {
        a(href: '#general-info') {
          span 'General Info'
        }
      }
      li {
        a(href: '#communication-channels') {
          span 'Communication Channels'
        }
      }
      li {
        a(href: '#contribution-terms') {
          span 'Contribution Terms'
        }
      }
      li {
        a(href: '#awards-offered') {
          span 'Awards Offered'
        }
      }
      li {
        a(href: '#visibility') {
          span 'Visibility'
        }
      }
    }
  end
end
