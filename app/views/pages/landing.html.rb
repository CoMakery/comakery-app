class Views::Pages::Landing < Views::Base
  def content
    content_for :pre_body do
      div(class: 'landing-header') {
        h1 {
          text 'JOIN INCREDIABLE BLOCKCHAIN PROJECTS'
        }
        h3 {
          text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS'
        }
      }
    end
    div(class: 'whois') {
      image_tag 'whois/H1-TEXT.png'
      row(style: 'margin-top: 30px') {
        column('large-7') {
          column('large-7 no-h-pad') {
            column('large-6 no-h-pad', style: 'text-align: right;') {
              h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') {
                text '&'
              }
            }
            column('large-6 no-h-pad', style: 'height: 108px;') {
              h3(style: 'line-height: 30px; margin-top: 20px;') {
                text 'Engineers'
                br
                text 'Developer'
              }
            }

            column('large-12 text-right no-h-pad', style: 'margin-top: -10px') {
              text 'Ethereum Solidity, Javascript, Elixir, GO, Ruby on Rails, Truffle... we match your specialty with projects to push your boundaries.'
            }
          }
          column('large-5') {
            image_tag 'whois/developers-engineers.jpg', size: '220x220'
          }
        }
      }
      row(style: 'margin-top: 20px') {
        column('large-5') {}
        column('large-7') {
          column('large-5') {
            image_tag 'whois/community-manager.jpg', size: '220x220'
          }
          column('large-7 no-h-pad') {
            column('large-12 no-h-pad', style: 'height: 108px;') {
              h3(style: 'line-height: 30px; margin-top: 20px;') {
                text 'Community'
                br
                text 'Manager'
              }
            }

            column('large-12 no-h-pad', style: 'margin-top: -10px') {
              text 'Organize, guide and build communities shaped by the desire to contribute to projects and earn tokens.'
            }
          }
        }
      }

      row(style: 'margin-top: 20px') {
        column('large-7') {
          column('large-7 no-h-pad') {
            column('large-6 no-h-pad', style: 'text-align: right;') {
              h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') {
                text '&'
              }
            }
            column('large-6 no-h-pad', style: 'height: 108px;') {
              h3(style: 'line-height: 30px; margin-top: 20px;') {
                text 'Designers'
                br
                text 'Marketers'
              }
            }

            column('large-12 text-right no-h-pad', style: 'margin-top: -10px') {
              text 'The world of blockchain is evolving at light speed, and so too are the creative and marketing needs of blockchain projects.'
            }
          }
          column('large-5') {
            image_tag 'whois/designers-marketers.jpg', size: '220x220'
          }
        }
      }
      row(style: 'margin-top: 20px') {
        column('large-5') {}
        column('large-7') {
          column('large-5') {
            image_tag 'whois/project-visionary.jpg', size: '220x220'
          }
          column('large-7 no-h-pad') {
            column('large-12 no-h-pad', style: 'height: 108px;') {
              h3(style: 'line-height: 30px; margin-top: 20px;') {
                text 'Project'
                br
                text 'Visionaries'
              }
            }

            column('large-12 no-h-pad', style: 'margin-top: -10px') {
              text 'Discover unique projects, join their teams, and work with world-class talent to set and execute the product roadmap.'
            }
          }
        }
      }
    }
  end
end
