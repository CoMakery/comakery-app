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
    div(class: 'landing-header') {
      image_tag 'Labyrinth-White-Small.png', size: '52x52', class: 'show-for-medium header-icon'
      div(class: 'show-for-large') {
        h1(style: 'margin-top: 90px;') {
          text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS'
        }
        h2(style: 'margin-bottom: 8%') {
          text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS'
        }
      }
      div(class: 'show-for-medium-only') {
        h1(style: 'margin-top: 4%; font-size: 20px') {
          text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS'
        }
        h2(style: 'margin-bottom: 6%;font-size: 16px;') {
          text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS'
        }
      }
      div(class: 'hide-for-medium') {
        h1(style: 'margin-top: 30px; font-size: 14px') {
          text 'JOIN INCREDIBLE BLOCKCHAIN PROJECTS'
        }
        h2(style: 'margin-top: 10px; font-size: 10px; margin-bottom: 10px') {
          text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS'
        }
      }
      link_to new_account_path do
        image_tag 'Header-Button.png', style: 'width: 15%'
      end
    }

    image_tag 'Header-Background.jpg', class: 'header-bg'
  end

  def whois
    div(class: 'large-10 medium-11 small-12 small-centered columns') {
      column('medium-12', style: 'text-align: center') {
        image_tag 'whois/H1-TEXT.png', style: 'margin-left: 15%'
      }
      column('medium-12') {
        column('medium-12 no-v-pad', style: 'margin-top: 30px;') {
          column('medium-7 show-for-large') {
            column('medium-7 no-h-pad') {
              column('medium-5 no-h-pad', style: 'text-align: right;') {
                h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') {
                  text '&'
                }
              }
              column('medium-7 no-h-pad', style: 'height: 108px;') {
                h1(style: 'line-height: 30px; margin-top: 20px;') {
                  text 'Engineers'
                  br
                  text 'Developers'
                }
              }
              column('medium-12 text-right no-h-pad', style: 'margin-top: -10px') {
                text 'Ethereum Solidity, Javascript, Elixir, GO, Ruby on Rails, Truffle... we match your specialty with projects to push your boundaries.'
              }
            }
            column('medium-5') {
              image_tag 'whois/developers-engineers.jpg', size: '220x220'
            }
          }
          column('medium-12 hide-for-large') {
            column('small-4 text-right') {
              image_tag 'whois/developers-engineers.jpg', size: '220x220'
            }
            column('small-8 no-h-pad') {
              h1(style: 'margin-top: 20px;') {
                text 'Engineers & Developers'
              }
              text 'Ethereum Solidity, Javascript, Elixir, GO, Ruby on Rails, Truffle... we match your specialty with projects to push your boundaries.'
            }
          }
        }
        column('medium-12 no-v-pad', style: 'margin-top: 20px;') {
          column('medium-5 show-for-large', style: 'color: #fff;') {
            text '.'
          }
          column('medium-7 show-for-large') {
            column('medium-5') {
              image_tag 'whois/community-manager.jpg', size: '220x220'
            }
            column('medium-7 no-h-pad') {
              column('medium-12 no-h-pad', style: 'height: 108px;') {
                h1(style: 'line-height: 30px; margin-top: 20px;') {
                  text 'Community'
                  br
                  text 'Managers'
                }
              }
              column('medium-12 no-h-pad', style: 'margin-top: -10px') {
                text 'Organize, guide and build communities shaped by the desire to contribute to projects and earn tokens.'
              }
            }
          }

          column('medium-12 hide-for-large') {
            column('small-4 text-right') {
              image_tag 'whois/community-manager.jpg', size: '220x220'
            }
            column('small-8 no-h-pad') {
              h1(style: 'margin-top: 20px;') {
                text 'Community Managers'
              }
              text 'Organize, guide and build communities shaped by the desire to contribute to projects and earn tokens.'
            }
          }
        }

        column('medium-12 no-v-pad', style: 'margin-top: 20px;') {
          column('medium-7 show-for-large') {
            column('medium-7 no-h-pad') {
              column('medium-5 no-h-pad', style: 'text-align: right;') {
                h2(style: 'font-size: 72px; color: #8A8A8A; margin-right: -13px;') {
                  text '&'
                }
              }
              column('medium-7 no-h-pad', style: 'height: 108px;') {
                h1(style: 'line-height: 30px; margin-top: 20px;') {
                  text 'Designers'
                  br
                  text 'Marketers'
                }
              }
              column('medium-12 text-right no-h-pad', style: 'margin-top: -10px') {
                text 'The world of blockchain is evolving at light speed, and so too are the creative and marketing needs of blockchain projects.'
              }
            }
            column('medium-5') {
              image_tag 'whois/designers-marketers.jpg', size: '220x220'
            }
          }
          column('medium-12 hide-for-large') {
            column('small-4 text-right') {
              image_tag 'whois/designers-marketers.jpg', size: '220x220'
            }
            column('small-8 no-h-pad') {
              h1(style: 'margin-top: 20px;') {
                text 'Designers & Marketers'
              }
              text 'The world of blockchain is evolving at light speed, and so too are the creative and marketing needs of blockchain projects.'
            }
          }
        }
        column('medium-12 no-v-pad', style: 'margin-top: 20px;') {
          column('medium-5 show-for-large', style: 'color: #fff;') {
            text '.'
          }
          column('medium-7 show-for-large') {
            column('medium-5') {
              image_tag 'whois/project-visionary.jpg', size: '220x220'
            }
            column('medium-7 no-h-pad') {
              column('medium-12 no-h-pad', style: 'height: 108px;') {
                h1(style: 'line-height: 30px; margin-top: 20px;') {
                  text 'Project'
                  br
                  text 'Visionaries'
                }
              }
              column('medium-12 no-h-pad', style: 'margin-top: -10px') {
                text 'Discover unique projects, join their teams, and work with world-class talent to set and execute the product roadmap.'
              }
            }
          }
          column('medium-12 hide-for-large') {
            column('small-4 text-right') {
              image_tag 'whois/project-visionary.jpg', size: '220x220'
            }
            column('small-8 no-h-pad') {
              h1(style: 'margin-top: 20px;') {
                text 'Project Visionaries'
              }
              text 'Discover unique projects, join their teams, and work with world-class talent to set and execute the product roadmap.'
            }
          }
        }
      }
    }
  end

  def workonblockchain
    column('medium-12', style: 'color: #fff;margin-top: 10px') {
      text '.'
    }
    div(class: 'large-10 medium-11 small-12 small-centered columns no-h-pad') {
      div(class: 'work-blockchain') {
        image_tag 'workonblockchain/header.png', style: 'width: 100%'
      }

      column('large-12 show-for-large blue-box') {
        column('large-6') {
          column('medium-8') {
            h2(style: 'margin-top: 30px;') {
              text 'Featured Project'
            }
          }
          column('medium-4 text-right') {
            image_tag 'workonblockchain/vevue-logo.png', style: 'width: 205px'
          }
          column('medium-12', style: 'margin-top: 30px') {
            p {
              text 'Vevue is revolutionizing the way people interact with distribute, watch, and appreciate video content using blockchain technology.'
            }
            p {
              text 'The CoMakery platform connected talented developer and community managers to Vevue, each of them earning tokens while helping accelerate the project to bootstrap towards a successful $2.5 Million ICO.'
            }
          }
        }
        column('large-6') {
          image_tag 'workonblockchain/vevue-picture.jpg'
        }
      }

      column('small-12 hide-for-large', style: 'margin-top: 10px;') {
        column('small-12 no-h-pad', style: 'margin-bottom: 10px;') {
          image_tag 'workonblockchain/vevue-picture.jpg'
        }
        column('small-9') {
          h2 {
            text 'Featured Project'
          }
        }
        column('small-3 text-right') {
          image_tag 'workonblockchain/vevue-logo.png', style: 'width: 100%;'
        }
        column('medium-12') {
          p {
            text 'Vevue is revolutionizing the way people interact with distribute, watch, and appreciate video content using blockchain technology.'
          }
          p {
            text 'The CoMakery platform connected talented developer and community managers to Vevue, each of them earning tokens while helping accelerate the project to bootstrap towards a successful $2.5 Million ICO.'
          }
        }
      }
    }
  end

  def howitwork
    div(class: 'large-10 medium-11 small-12 small-centered columns') {
      column('medium-12', style: 'text-align: center; margin-top: 30px;margin-bottom: 40px;') {
        image_tag 'howitwork/H1-text.png', style: 'height: 38px; margin-left: 15%'
      }
      column('medium-12 show-for-large') {
        column('medium-2', style: 'color: #fff') {
          text '.'
        }
        column('medium-4 text-right no-h-pad', style: 'margin-top: -13px') {
          column('medium-12 no-h-pad hiw-signup-bg') {
            h2 'Sign Up'
            text 'Share your email address or join our Slack / Telegram channels, and let us know about your area of expertise.'
          }
          column('medium-12 no-h-pad hiw-earn-bg', style: 'margin-top: 255px') {
            h2 'Earn Tokens'
            text 'See a project and task your interested in working on? Apply to the project, start working on the tasks, and get paid in tokens.'
          }
        }
        column('medium-5 hiw-bg no-h-pad', style: 'float: left') {
          column('medium-12 hiw-discover-bg', style: 'margin-top: 155px; padding-left: 90px;') {
            h2 'Discover Opportunities'
            text 'Use the Comakery platform to discover unique blockchain projects and the tasks they need strong leadership to own and execute upon.'
          }
        }
      }
      column('medium-12 hide-for-large') {
        column('small-2 text-right') {
          image_tag 'howitwork/blue1.jpg', size: '52x52'
        }
        column('small-10 no-h-pad') {
          h2 'Sign Up'
          text 'Share your email address or join our Slack / Telegram channels, and let us know about your area of expertise.'
        }
        column('small-2 text-right') {
          image_tag 'howitwork/pink1.jpg', size: '52x52'
        }
        column('small-10 no-h-pad') {
          h2 'Earn Tokens'
          text 'See a project and task your interested in working on? Apply to the project, start working on the tasks, and get paid in tokens.'
        }
        column('small-2 text-right') {
          image_tag 'howitwork/purple1.jpg', size: '52x52'
        }
        column('small-10 no-h-pad') {
          h2 'Discover Opportunities'
          text 'Use the Comakery platform to discover unique blockchain projects and the tasks they need strong leadership to own and execute upon.'
        }
      }
    }
  end

  def signup_to_learn
    div(class: 'large-10 medium-12 no-h-pad small-centered columns') {
      column('medium-12 no-h-pad home-signup-bg') {
        column('medium-12') {
          div(class: 'show-for-medium') {
            h1 'Sign Up To Learn More'
            p {
              text 'Be the first to hear about new projects and announcements'
            }
          }

          div(class: 'hide-for-medium', style: 'text-align: center') {
            h1 'Sign Up To Learn More'
            p {
              text 'Be the first to hear about new projects and announcements'
            }
          }
          br
          form_for Account.new do |f|
            column('medium-12 no-h-pad') {
              column('medium-5 small-9 no-h-pad') {
                f.text_field :email
              }
              column('medium-2 small-3') {
                f.submit 'SIGN UP', class: 'signup-btn'
              }
              column('medium-5') {}
            }
          end
        }
      }
    }
  end
end
