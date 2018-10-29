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
    div(class: 'small-12 columns no-h-pad', style: 'background-color: #f9f9f9; padding: 40px;') do
      div(class: 'small-12 text-center projects-title') do
        text 'CoMakery Hosts Projects That We Believe In'
      end
      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px') do
        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'HOLOCHAIN PROTOCAL (HOT)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why Holochain?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/holochain.jpg', 'Holo', 'Exchange')
            end
          end
        end
        div(class: 'small-4 columns') do
          image_tag 'home/featured/holochain.jpg', stlye: 'width: 100%'
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgba(0, 137, 244, 0.02);') do
        div(class: 'small-4 columns no-h-pad') do
          image_tag 'home/featured/cardano.jpg', stlye: 'width: 100%'
        end

        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'CARDANO PROTOCOL (ADA)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why Cardano?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/cardano.jpg', 'Cardano', 'Exchange')
            end
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px') do
        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'ETHEREUM PROTOCOL (ETH)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why Ethereum?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/ethereum.jpg', 'Ethereum', 'Exchange')
            end
          end
        end
        div(class: 'small-4 columns') do
          image_tag 'home/featured/ethereum.jpg', stlye: 'width: 100%'
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgba(0, 137, 244, 0.02);') do
        div(class: 'small-4 columns no-h-pad') do
          image_tag 'home/featured/vevue.jpg', stlye: 'width: 100%'
        end

        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'VEVUE PROTOCOL (VUE)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why VEVUE?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/vevue.jpg', 'Vevue', 'Exchange')
            end
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px') do
        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'PROPS by YouNow (PROPS)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why PROPS?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/props.jpg', 'Props', 'Exchange')
            end
          end
        end
        div(class: 'small-4 columns') do
          image_tag 'home/featured/props.jpg', stlye: 'width: 100%'
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgba(0, 137, 244, 0.02);') do
        div(class: 'small-4 columns no-h-pad') do
          image_tag 'home/featured/glass.jpg', stlye: 'width: 100%'
        end

        div(class: 'small-8 columns') do
          div(class: 'protocol-title') do
            text 'SHARESPOST GLASS NETWORK (GLASS)'
          end
          div(class: 'protocol-meta') do
            text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
          end
          div(class: 'past-project-content') do
            div(class: 'protocol-sub-title') do
              text 'Why GLASS?'
            end
            div(class: 'protocol-desc') do
              text 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum cursus eget velit ac pharetra. Phasellus nec aliquam velit. Donec pretium mauris urna, non dignissim felis dictum sed. Nam tempus mattis augue, at tempus tellus laoreet sed. Maecenas quis odio vitae nunc elementum tristique quis vitae neque.'
            end
          end
          div(style: 'margin-top: 20px') do
            text 'Projects to Make an Impact On:'
            2.times do
              display_project('assets/home/featured/glass.jpg', 'Glass', 'Exchange')
            end
          end
        end
      end

      summary
    end
  end

  def display_project(bg_image, protocol, project)
    div(class: 'small-12 columns no-h-pad', style: 'margin-top:10px') do
      div(class: 'small-6 columns project-row', style: "background-image: url('#{bg_image}')") do
        div(class: 'protocol-project-name') do
          text 'Decentralized Exchange App'
        end
        div(class: 'project-descriptive') do
          text 'for everyone'
        end
      end
      div(class: 'small-6 columns text-right') do
        image_tag 'home/featured/lock.png', size: '18x18', style: 'margin-right: 10px'
        link_to "I'M INTERESTED!", add_interest_path(project: project, protocol_interest: protocol), class: 'button', remote: true
      end
    end
  end

  def summary
    div(class: 'small-12 columns', style: 'padding: 50px 0;') do
      div(class: 'small-4 columns text-center') do
        div(class: 'summary-count') do
          text '1,000+'
        end
        hr(class: 'stat')
        div(class: 'summary-label') do
          text 'CONTRIBUTORS'
        end
      end
      div(class: 'small-4 columns text-center') do
        div(class: 'summary-count') do
          text '50+'
        end
        hr(class: 'stat')
        div(class: 'summary-label') do
          text 'PROJECTS'
        end
      end
      div(class: 'small-4 columns text-center') do
        div(class: 'summary-count') do
          text '10,000,000+'
        end
        hr(class: 'stat')
        div(class: 'summary-label') do
          text 'TOKENS AWARDED'
        end
      end
    end
  end
end
