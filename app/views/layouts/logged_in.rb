class Views::Layouts::LoggedIn < Views::Base
  def content
    content_for :navigation do
      render partial: 'shared/navigation'
    end

    content_for :body do
      div(class: "app-container row") {
        div(class: "large-8 large-centered columns") { yield }
      }
    end

    render template: "layouts/raw"
  end
end
