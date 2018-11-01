class Views::Projects::LeftMenuItems < Views::Base
  needs :current_section
  def content
    ul(class: 'vertical menu', id: 'left-menu') do
      li do
        a(href: 'javascript:;', class: "switcher#{' active' if current_section == '#general'}", data: { target: '#general' }) do
          text 'General Info'
        end
      end
      li do
        a(href: 'javascript:;', class: "switcher#{' active' if current_section == '#channel'}", data: { target: '#channel' }) do
          text 'Communication Channels'
        end
      end
      li do
        a(href: 'javascript:;', class: "switcher#{' active' if current_section == '#contribution'}", data: { target: '#contribution' }) do
          text 'Blockchain Settings'
        end
      end
      li do
        a(href: 'javascript:;', class: "switcher#{' active' if current_section == '#award'}", data: { target: '#award' }) do
          text 'Awards Offered'
        end
      end
      li do
        a(href: 'javascript:;', class: "switcher#{' active' if current_section == '#visibility'}", data: { target: '#visibility' }) do
          text 'Visibility'
        end
      end
    end
  end
end
