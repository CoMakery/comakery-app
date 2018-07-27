class Views::Projects::LeftMenuItems < Views::Base
  def content
    ul(class: 'vertical menu scrollingBox') do
      li do
        a(href: '#general-info') do
          span 'General Info'
        end
      end
      li do
        a(href: '#communication-channels') do
          span 'Communication Channels'
        end
      end
      li do
        a(href: '#contribution-terms') do
          span 'Contribution Terms'
        end
      end
      li do
        a(href: '#awards-offered') do
          span 'Awards Offered'
        end
      end
      li do
        a(href: '#visibility') do
          span 'Visibility'
        end
      end
    end
  end
end
