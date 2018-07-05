class Views::Pages::Landing < Views::Base
  def content
    content_for :pre_body do
      div(class: 'landing-header'){
        h1{
          text 'JOIN INCREDIABLE BLOCKCHAIN PROJECTS'
        }
        h3{
          text 'DISCOVER PROJECTS | LIST YOUR OWN | GET PAID IN TOKENS'
        }
      }
      div(class: 'whois'){
        image_tag 'whois/H1-TEXT.png'
      }
    end
  end
end
