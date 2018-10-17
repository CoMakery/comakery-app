class Views::Pages::Featured < Views::Base
  def content
    content_for :pre_body do
      header
      featured_projects
    end
  end

  def header
    div(class: 'landing-header') do
      div(class: 'show-for-large') do
        h1(style: 'margin-top: 160px;') { text 'FIND THE PROJECTS THAT SPEAK TO YOU' }
        h2(style: 'margin-bottom: 8%') { text 'BUILD YOUR REPUTATION, APPLY TO PROJECTS & JOIN A GREAT TEAM' }
      end
      div(class: 'show-for-medium-only') do
        h1(style: 'margin-top: 90px; font-size: 20px') { text 'FIND THE PROJECTS THAT SPEAK TO YOU' }
        h2(style: 'margin-bottom: 5%;font-size: 16px;') { text 'BUILD YOUR REPUTATION, APPLY TO PROJECTS & JOIN A GREAT TEAM' }
      end
      div(class: 'hide-for-medium') do
        h1(style: 'margin-top: 70px; font-size: 14px') { text 'FIND THE PROJECTS THAT SPEAK TO YOU' }
        h2(style: 'margin-top: 10px; font-size: 10px; margin-bottom: 15px') { text 'BUILD YOUR REPUTATION, APPLY TO PROJECTS & JOIN A GREAT TEAM' }
      end
    end
    div(class: 'large-centered columns no-h-pad', style: 'max-width: 1535px') do
      image_tag 'home/header1.jpg', class: 'header-bg'
    end
  end

  def featured_projects
    div(class: 'small-12 columns', style: 'background-color: #f9f9f9; padding: 40px;') do
      div(class: 'small-12 text-center projects-title') do
        text 'CoMakery Hosts Projects That We Believe In'
      end
      div(class: 'small-12 columns', style: 'margin-top:30px') do
        div(class: 'small-8 columns') do
          div(class: 'past-project-title') do
            text 'HOLOCHAIN PROTOCAL (HOT)'
          end
          div(class: 'past-project-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: '') do
              text 'Why Holochain?'
            end
            text "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque."
          end
          div(class)
        end
        div(class: 'small-4 columns') do
          image_tag 'home/featured/holochain.jpg', stlye: 'width: 100%'
        end

      end
    end
  end

end
