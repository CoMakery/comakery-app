class Views::Projects::LeftMenuItems < Views::Base
  def content
    ul(class: 'vertical menu', id: 'left-menu') do
      li do
        a(href: 'javascript:;', class: 'switcher active', data: { target: '#general' }) do
          text 'General Info'
        end
      end
      li do
        a(href: 'javascript:;', class: 'switcher', data: { target: '#channel' }) do
          text 'Communication Channels'
        end
      end
      li do
        a(href: 'javascript:;', class: 'switcher', data: { target: '#contribution' }) do
          text 'Contribution Terms'
        end
      end
      li do
        a(href: 'javascript:;', class: 'switcher', data: { target: '#award' }) do
          text 'Awards Offered'
        end
      end
      li do
        a(href: 'javascript:;', class: 'switcher', data: { target: '#visibility' }) do
          text 'Visibility'
        end
      end
    end
  end
end
