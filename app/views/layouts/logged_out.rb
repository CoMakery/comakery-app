class Views::Layouts::LoggedOut < Views::Base
  def content
    content_for :body do
      div(class: "app-container row") {
        div(class: "large-8 large-centered columns") { yield }
      }
    end

    render template: "layouts/raw"
  end
end
