class Views::Pages::Featured < Views::Base
  def content
    content_for :pre_body do
      div(style: 'background-color: #4476ef') do
        header
      end
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
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'HOLOCHAIN PROTOCAL (HOT)'
            end
            div(class: 'protocol-meta') do
              text 'Think outside the blocks - scalable distributed computing'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why Holochain?'
              end
              div(class: 'protocol-desc') do
                text 'Holochain enables a distributed web with user autonomy built directly into its architecture and protocols. Data is about remembering our lived and shared experiences. Distributing the storage and processing of that data can change how we coordinate and interact. With digital integration under user control, Holochain liberates our online lives from corporate control.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/holochain.jpg', 'Holo', 'Market Research')
              display_project('home/featured/logos/holochain.jpg', 'Holo', 'Wallet Integrations')
              display_project('home/featured/logos/holochain.jpg', 'Holo', 'Decentralized Exchange Integrations')
            end
          end
          div(class: 'small-4 columns') do
            image_tag 'home/featured/holochain.jpg', stlye: 'width: 100%'
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgb(240,255,255);') do
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-4 columns no-h-pad') do
            image_tag 'home/featured/cardano.jpg', stlye: 'width: 100%'
          end

          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'CARDANO PROTOCOL (ADA)'
            end
            div(class: 'protocol-meta') do
              text 'A decentralised public blockchain and cryptocurrency project'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why Cardano?'
              end
              div(class: 'protocol-desc') do
                text 'Cardano is a technological platform that will be capable of running financial applications currently used every day by individuals, organisations and governments all around the world. The platform is being constructed in layers, which gives the system the flexibility to be more easily maintained.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/cardano.jpg', 'Cardano', 'dApp Developer Tools')
              display_project('home/featured/logos/cardano.jpg', 'Cardano', 'Educational Materials')
              display_project('home/featured/logos/cardano.jpg', 'Cardano', 'Security Audits')
            end
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px') do
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'ETHEREUM PROTOCOL (ETH)'
            end
            div(class: 'protocol-meta') do
              text 'A decentralized platform that runs smart contracts'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why Ethereum?'
              end
              div(class: 'protocol-desc') do
                text 'Ethereum enables developers to create markets, store registries of debts or promises, move funds in accordance with instructions given long in the past (like a will or a futures contract) and many other things that have not been invented yet, all without a middleman or counterparty risk.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/ethereum.jpg', 'Ethereum', 'dApp Developer Tools')
              display_project('home/featured/logos/ethereum.jpg', 'Ethereum', 'Educational Materials')
              display_project('home/featured/logos/ethereum.jpg', 'Ethereum', 'Security Audits')
            end
          end
          div(class: 'small-4 columns') do
            image_tag 'home/featured/ethereum.jpg', stlye: 'width: 100%'
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgb(240,255,255);') do
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-4 columns no-h-pad') do
            image_tag 'home/featured/vevue.jpg', stlye: 'width: 100%'
          end

          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'VEVUE PROTOCOL (VUE)'
            end
            div(class: 'protocol-meta') do
              text 'Specially designed to reward content creators'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why VEVUE?'
              end
              div(class: 'protocol-desc') do
                text 'Vevue believes in empowering creativity. Using the power of the blockchain, they are revolutionizing the way people interact with, distribute, watch, and appreciate video content. This means copyright protection, global accessibility and expediency for all.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/vevue.jpg', 'Vevue', 'Promotion')
              display_project('home/featured/logos/vevue.jpg', 'Vevue', 'Security Audits')
              display_project('home/featured/logos/vevue.jpg', 'Vevue', 'Wallet Integrations')
            end
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px') do
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'PROPS by YouNow (PROPS)'
            end
            div(class: 'protocol-meta') do
              text 'A Decentralized Network of Video Applications'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why PROPS?'
              end
              div(class: 'protocol-desc') do
                text 'PROPS is a decentralized ecosystem for digital video. Their motivation is to create a video application ecosystem built to empower users and to deliver on the internet’s original promise. The PROPS ecosystem will fairly reward developers, content creators, and consumers for their contribution to the growth of digital media networks.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/props.jpg', 'Props', 'Decentralized Exchange Integrations')
              display_project('home/featured/logos/props.jpg', 'Props', 'dApp Developer Tools')
              display_project('home/featured/logos/props.jpg', 'Props', 'Educational Materials')
            end
          end
          div(class: 'small-4 columns') do
            image_tag 'home/featured/props.jpg', stlye: 'width: 100%'
          end
        end
      end

      div(class: 'small-12 columns no-h-pad', style: 'margin-top:30px; background-color: rgb(240,255,255);') do
        div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
          div(class: 'small-4 columns no-h-pad') do
            image_tag 'home/featured/glass.jpg', stlye: 'width: 100%'
          end

          div(class: 'small-8 columns') do
            div(class: 'protocol-title') do
              text 'SHARESPOST GLASS NETWORK (GLASS)'
            end
            div(class: 'protocol-meta') do
              text 'A decentralized network of crypto trading platforms'
            end
            div(class: 'past-project-content') do
              div(class: 'protocol-sub-title') do
                text 'Why GLASS?'
              end
              div(class: 'protocol-desc') do
                text 'The Glass network will pool liquidity and enable compliant settlement of cross-border digital securities transactions. The network will route digital securities transactions from exchanges to licensed broker dealers in jurisdictions where their clients are resident for settlement.'
              end
            end
            div(style: 'margin-top: 20px') do
              text 'Projects to Make an Impact On:'
              display_project('home/featured/logos/glass.jpg', 'Glass', 'Wallet Integrations')
              display_project('home/featured/logos/glass.jpg', 'Glass', 'Community Moderation')
              display_project('home/featured/logos/glass.jpg', 'Glass', 'Promotion')
            end
          end
        end
      end

      summary
    end
  end

  def display_project(bg_image, protocol, project)
    div(class: 'small-12 columns no-h-pad', style: 'margin-top:10px') do
      div(class: 'small-6 columns project-row no-h-pad') do
        div(class: 'project-thumb') do
          image_tag bg_image, size: '100x53'
        end
        div(class: 'protocol-project-name') do
          text project
        end
        div(class: 'project-descriptive') do
          text 'for everyone'
        end
      end
      div(class: 'small-6 columns text-right') do
        image_tag 'home/featured/lock.png', size: '18x18', style: 'margin-right: 10px'
        if current_account.interested?(protocol, project)
          link_to 'INTEREST, NOTED!', 'javascript:;', class: 'button disabled'
        else
          link_to "I'M INTERESTED!", 'javascript:;', data: { protocol: protocol, project: project }, class: 'button interest', style: 'width: 151px'
          link_to 'INTEREST, NOTED!', 'javascript:;', class: 'button interest-done disabled', style: 'display: none'
        end
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
