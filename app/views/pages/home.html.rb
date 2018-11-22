class Views::Pages::Home < Views::Base
  def content
    content_for :pre_body do
      div(style: 'background-color: #4476ef') do
        header
      end
      div(style: 'margin-top: 20px; min-height: 570px') do
        render partial: 'form', locals: { email: current_account.email, first_name: current_account.first_name, last_name: current_account.last_name }
      end
      past_projects
      div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
        summary
      end
    end
  end

  def header
    div(class: 'landing-header') do
      div(class: 'show-for-large') do
        h1(style: 'margin-top: 160px;') { text 'BEGIN YOUR BLOCKCHAIN JOURNEY' }
        h2(style: 'margin-bottom: 8%') { text 'FILL OUT THE SHORT FORM BELOW TO GET STARTED' }
      end
      div(class: 'show-for-medium-only') do
        h1(style: 'margin-top: 90px; font-size: 20px') { text 'BEGIN YOUR BLOCKCHAIN JOURNEY' }
        h2(style: 'margin-bottom: 5%;font-size: 16px;') { text 'FILL OUT THE SHORT FORM BELOW TO GET STARTED' }
      end
      div(class: 'hide-for-medium') do
        h1(style: 'margin-top: 70px; font-size: 14px') { text 'BEGIN YOUR BLOCKCHAIN JOURNEY' }
        h2(style: 'margin-top: 10px; font-size: 10px; margin-bottom: 15px') { text 'FILL OUT THE SHORT FORM BELOW TO GET STARTED' }
      end
    end
    div(class: 'large-centered columns no-h-pad', style: 'max-width: 1535px') do
      image_tag 'home/header1.jpg', class: 'header-bg'
    end
  end

  def past_projects
    div(class: 'small-12 columns', style: 'background-color: #f9f9f9; padding: 20px;') do
      div(style: 'max-width: 1235px; margin-left: auto; margin-right: auto') do
        div(class: 'small-12 text-center projects-title') do
          text 'PAST PROJECTS'
        end
        div(class: 'small-12 columns', style: 'margin-top:30px') do
          div(class: 'small-6 columns hide-for-large', style: 'margin-top: 7px;') do
            image_tag 'home/vevue1.jpg', stlye: 'width: 100%'
          end
          div(class: 'small-6 columns show-for-large', style: 'margin-top: 7px;') do
            image_tag 'home/vevue.jpg', stlye: 'width: 100%'
          end
          div(class: 'small-6 columns') do
            div(class: 'past-project-title') do
              text 'Vevue Foundation'
            end
            div(class: 'past-project-meta') do
              text '+255 CONTRIBUTORS - 157,372 TOKENS AWARDED'
            end
            div(class: 'past-project-content') do
              text "Vevue is a simple way for anyone to earn Vevue Tokens in exchange for answering Vevue Requests (custom-created videos). Earn tokens for answering Vevue Requests pinned nearby; create your own media utilizing the blockchain. Show us who's at the party or how busy it is at your favorite restaurant."
            end
          end
        end

        div(class: 'small-12 columns', style: 'margin-top:30px; padding-bottom: 25px;') do
          div(class: 'small-6 columns') do
            div(class: 'past-project-title') do
              text 'Coinspace'
            end
            div(class: 'past-project-meta') do
              text '+60 CONTRIBUTORS - 1,157 TOKENS AWARDED'
            end
            div(class: 'past-project-content') do
              text 'Coinspace is a revolution in community and ownership. We are a community focused on making everyone the founder of their own space. You determine how Coinspace is run, all participation is rewarded and all financials are public. We meet, we vote, we do.'
            end
          end
          div(class: 'small-6 columns hide-for-large', style: 'margin-top: 7px;') do
            image_tag 'home/coinspace1.jpg', stlye: 'width: 100%'
          end
          div(class: 'small-6 columns show-for-large', style: 'margin-top: 7px;') do
            image_tag 'home/coinspace.jpg', stlye: 'width: 100%'
          end
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
