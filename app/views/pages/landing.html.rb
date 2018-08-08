class Views::Pages::Landing < Views::Base
  def content
    content_for :pre_body do
      header
      whois
      workonblockchain
      howitwork
      signup_to_learn
    end
  end

  def header
    div(class: 'landing-header') do
      image_tag 'Labyrinth-White-Small.png', size: '52x52', class: 'show-for-medium header-icon'
      div(class: 'show-for-large') do
        h1(style: 'margin-top: 90px;') { text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS' }
        h2(style: 'margin-bottom: 8%') { text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS' }
      end
      div(class: 'show-for-medium-only') do
        h1(style: 'margin-top: 4%; font-size: 20px') { text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS' }
        h2(style: 'margin-bottom: 5%;font-size: 16px;') { text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS' }
      end
      div(class: 'hide-for-medium') do
        h1(style: 'margin-top: 20px; font-size: 14px') { text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS' }
        h2(style: 'margin-top: 10px; font-size: 10px; margin-bottom: 15px') { text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS' }
      end
      link_to new_account_path do
        image_tag 'Header-Button.png', style: 'width: 150px'
      end
    end
    div(class: 'large-centered columns no-h-pad', style: 'max-width: 1535px') do
      image_tag 'Header-Background.jpg', class: 'header-bg'
    end
  end

  def whois
    div(class: 'large-10 medium-11 small-12 small-centered columns', style: 'max-width: 1044px;') do
      column('medium-12 no-h-pad whois-bg', style: 'text-align: center; margin-top: 20px;') do
        image_tag 'whois/header-front.png', class: 'whois-header'
      end

      column('medium-12') do
        column('medium-12 no-v-pad', style: 'margin-top: 30px;') do
          column('medium-7 show-for-large') do
            column('medium-7 no-h-pad', style: 'position: relative; z-index: 2') do
              div(style: 'float: right; padding-right: 35px') do
                column('medium-3 no-h-pad', style: 'text-align: right;') do
                  h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') { text '&' }
                end
                column('medium-9 no-h-pad', style: 'height: 108px;') do
                  h1(style: 'line-height: 30px; margin-top: 20px;') do
                    text 'Engineers'
                    br
                    text 'Developers'
                  end
                end
              end
              column('medium-12 text-right', style: 'margin-top: -10px') do
                text 'Ethereum Solidity, Javascript, Elixir, GO, Ruby on Rails, Truffle... we match your specialty with projects to push your boundaries.'
              end
            end
            column('medium-5') do
              image_tag 'whois/developers-engineers.jpg', size: '220x220'
            end
          end
          column('medium-12 hide-for-large') do
            column('small-4 text-right') do
              image_tag 'whois/developers-engineers.jpg', size: '220x220'
            end
            column('small-8 no-h-pad') do
              h1(style: 'margin-top: 20px;') { text 'Engineers & Developers' }
              text 'Ethereum Solidity, Javascript, Elixir, GO, Ruby on Rails, Truffle... we match your specialty with projects to push your boundaries.'
            end
          end
        end
        column('medium-12 no-v-pad', style: 'margin-top: 20px;') do
          column('medium-5 show-for-large', style: 'color: #fff;') { text '.' }
          column('medium-7 show-for-large', style: 'padding-left: 0; padding-right: 40px') do
            column('medium-5', style: 'max-width: 250px; padding-left: 0;') do
              image_tag 'whois/community-manager.jpg', size: '220x220'
            end
            column('medium-7 no-h-pad', style: 'float: left') do
              column('medium-12 no-h-pad', style: 'height: 108px;') do
                h1(style: 'line-height: 30px; margin-top: 20px;') do
                  text 'Community'
                  br
                  text 'Managers'
                end
              end
              column('medium-12 no-h-pad', style: 'margin-top: -10px') do
                text 'Organize, guide and build communities shaped by the desire to contribute to projects and earn tokens.'
              end
            end
          end

          column('medium-12 hide-for-large') do
            column('small-4 text-right') do
              image_tag 'whois/community-manager.jpg', size: '220x220'
            end
            column('small-8 no-h-pad') do
              h1(style: 'margin-top: 20px;') { text 'Community Managers' }
              text 'Organize, guide and build communities shaped by the desire to contribute to projects and earn tokens.'
            end
          end
        end

        column('medium-12 no-v-pad', style: 'margin-top: 20px;') do
          column('medium-7 show-for-large') do
            column('medium-7 no-h-pad', style: 'position: relative; z-index: 2') do
              div(style: 'float: right; padding-right: 35px') do
                column('medium-3 no-h-pad', style: 'text-align: right;') do
                  h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') { text '&' }
                end
                column('medium-9 no-h-pad', style: 'height: 108px;') do
                  h1(style: 'line-height: 30px; margin-top: 20px;') do
                    text 'Designers'
                    br
                    text 'Marketers'
                  end
                end
              end
              column('medium-12 text-right', style: 'margin-top: -10px') do
                text 'The world of blockchain is evolving at light speed, and so too are the creative and marketing needs of blockchain projects.'
              end
            end
            column('medium-5') do
              image_tag 'whois/designers-marketers.jpg', size: '220x220'
            end
          end
          column('medium-12 hide-for-large') do
            column('small-4 text-right') do
              image_tag 'whois/designers-marketers.jpg', size: '220x220'
            end
            column('small-8 no-h-pad') do
              h1(style: 'margin-top: 20px;') { text 'Designers & Marketers' }
              text 'The world of blockchain is evolving at light speed, and so too are the creative and marketing needs of blockchain projects.'
            end
          end
        end
        column('medium-12 no-v-pad', style: 'margin-top: 20px;') do
          column('medium-5 show-for-large', style: 'color: #fff;') { text '.' }
          column('medium-7 show-for-large', style: 'padding-left: 0; padding-right: 40px') do
            column('medium-5', style: 'max-width: 250px; padding-left: 0;') do
              image_tag 'whois/project-visionary.jpg', size: '220x220'
            end
            column('medium-7 no-h-pad', style: 'float: left') do
              column('medium-12 no-h-pad', style: 'height: 108px;') do
                h1(style: 'line-height: 36px; margin-top: 20px;') do
                  text 'Project'
                  br
                  text 'Visionaries'
                end
              end
              column('medium-12 no-h-pad', style: 'margin-top: -10px') do
                text 'Discover unique projects, join their teams, and work with world-class talent to set and execute the product roadmap.'
              end
            end
          end
          column('medium-12 hide-for-large') do
            column('small-4 text-right') do
              image_tag 'whois/project-visionary.jpg', size: '220x220'
            end
            column('small-8 no-h-pad') do
              h1(style: 'margin-top: 20px;') { text 'Project Visionaries' }
              text 'Discover unique projects, join their teams, and work with world-class talent to set and execute the product roadmap.'
            end
          end
        end
      end
    end
  end

  def workonblockchain
    column('medium-12', style: 'color: #fff;margin-top: 10px') { text '.' }
    div(class: 'large-12 small-centered columns no-h-pad', style: 'max-width: 900px;') do
      div(class: 'work-blockchain') do
        image_tag 'workonblockchain/header.jpg', style: 'width: 100%'
      end

      column('large-12 show-for-large blue-box') do
        column('large-6') do
          column('medium-8') do
            h2(style: 'margin-top: 6px;') { text 'Featured Project' }
          end
          column('medium-4 text-right') do
            image_tag 'workonblockchain/vevue-logo.png', style: 'width: 205px'
          end
          column('medium-12', style: 'margin-top: 30px') do
            p do
              text 'Vevue is revolutionizing the way people interact with distribute, watch, and appreciate video content using blockchain technology.'
            end
            p do
              text 'The CoMakery platform connected talented developer and community managers to Vevue, each of them earning tokens while helping accelerate the project to bootstrap towards a successful $2.5 Million ICO.'
            end
          end
        end
        column('large-6') do
          image_tag 'workonblockchain/vevue-picture.jpg'
        end
      end

      column('small-12 hide-for-large', style: 'margin-top: 10px;') do
        column('small-12 no-h-pad', style: 'margin-bottom: 10px; text-align: center;') do
          column('small-6 text-right') do
            h2(style: 'margin-top: 10px; font-size:22px;') { text 'Featured Project' }
          end
          column('small-6') do
            image_tag 'workonblockchain/vevue-logo.png', style: 'width: 133px;'
          end
          image_tag 'workonblockchain/vevue-picture.jpg'
        end

        column('medium-12') do
          p do
            text 'Vevue is revolutionizing the way people interact with distribute, watch, and appreciate video content using blockchain technology.'
          end
          p do
            text 'The CoMakery platform connected talented developer and community managers to Vevue, each of them earning tokens while helping accelerate the project to bootstrap towards a successful $2.5 Million ICO.'
          end
        end
      end
    end
  end

  def howitwork
    div(class: 'small-12 small-centered columns', style: 'max-width: 1044px;') do
      column('medium-12', style: 'text-align: center; margin-top: 30px;margin-bottom: 40px;') do
        image_tag 'howitwork/H1-text.png', class: 'hiw-header'
      end
      column('medium-12 show-for-large') do
        column('medium-2', style: 'color: #fff') { text '.' }
        column('medium-4 text-right no-h-pad', style: 'margin-top: -13px') do
          column('medium-12 no-h-pad') do
            h2 do
              image_tag 'howitwork/blue1.jpg', size: '72x72'
              text 'Sign Up'
            end
            div(style: 'height: 62px;') do
              text 'Share your email address or join our Slack / Telegram channels, and let us know about your area of expertise.'
            end
          end
          column('medium-12 no-h-pad', style: 'margin-top: 216px') do
            h2 do
              image_tag 'howitwork/pink1.jpg', size: '72x72'
              text 'Earn Tokens'
            end
            text 'See a project and task your interested in working on? Apply to the project, start working on the tasks, and get paid in tokens.'
          end
        end
        column('medium-5 hiw-bg no-h-pad', style: 'float: left') do
          column('medium-12', style: 'margin-top: 155px; padding-left: 56px;') do
            h2(class: 'hiw-discover-bg') { text 'Discover Opportunities' }
            div(style: 'padding: 10px') do
              text 'Use the Comakery platform to discover unique blockchain projects and the tasks they need strong leadership to own and execute upon.'
            end
          end
        end
      end
      column('medium-12 hide-for-large') do
        column('small-2 text-right') do
          image_tag 'howitwork/blue1.jpg', size: '52x52'
        end
        column('small-10 no-h-pad') do
          h2(style: 'margin-bottom: 0') { text 'Sign Up' }
          text 'Share your email address or join our Slack / Telegram channels, and let us know about your area of expertise.'
        end
        column('small-2 text-right', style: 'margin-top: 15px;') do
          image_tag 'howitwork/pink1.jpg', size: '52x52'
        end
        column('small-10 no-h-pad', style: 'margin-top: 15px;') do
          h2(style: 'margin-bottom: 0') { text 'Earn Tokens' }
          text 'See a project and task your interested in working on? Apply to the project, start working on the tasks, and get paid in tokens.'
        end
        column('small-2 text-right', style: 'margin-top: 15px;') do
          image_tag 'howitwork/purple1.jpg', size: '52x52'
        end
        column('small-10 no-h-pad', style: 'margin-top: 15px;') do
          h2(style: 'margin-bottom: 0') { text 'Discover Opportunities' }
          text 'Use the Comakery platform to discover unique blockchain projects and the tasks they need strong leadership to own and execute upon.'
        end
      end
    end
  end

  def signup_to_learn
    div(class: 'large-10 medium-12 no-h-pad medium-centered columns', style: 'max-width: 900px;') do
      column('medium-12 no-h-pad home-signup-bg') do
        column('medium-12') do
          div(class: 'show-for-large') do
            h1 'Sign Up To Learn More'
            p { text 'Be the first to hear about new projects and announcements' }
            br
            form_for Account.new do |f|
              column('medium-12 no-h-pad') do
                column('medium-5 small-9 no-h-pad') do
                  f.text_field :email
                end
                column('medium-2 small-3') do
                  button(type: 'submit', class: 'signup-btn') do
                    text 'SIGN UP'
                  end
                end
                column('medium-5') {}
              end
            end
          end

          div(class: 'show-for-medium-only', style: 'text-align: center') do
            h1 'Sign Up To Learn More'
            p { text 'Be the first to hear about new projects and announcements' }
            br
            form_for Account.new do |f|
              column('medium-12 no-h-pad') do
                f.text_field :email, style: 'display: inline; width: 400px;'
                button(type: 'submit', class: 'signup-btn') { text 'SIGN UP' }
              end
            end
          end

          div(class: 'hide-for-medium', style: 'text-align: center') do
            h1(style: 'font-size: 28px;') { text 'Sign Up To Learn More' }
            p { text 'Be the first to hear about new projects and announcements' }
            br
            form_for Account.new do |f|
              column('medium-12 no-h-pad') do
                f.text_field :email, style: 'display: inline; width: 200px'
                button(type: 'submit', class: 'signup-btn') { text 'SIGN UP' }
              end
            end
          end
        end
      end
    end
  end
end
