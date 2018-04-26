class Views::Projects::LeftMenuItems < Views::Base
  def content
    ul(class: 'vertical menu scrollingBox') {
      li {
        a(href: '#basics') {
          span 'Basics'
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
        a(href: '#awards') {
          span 'Awards'
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
