class Views::Layouts::LoggedIn < Views::Base
  def content
    content_for :navigation do
      render partial: 'shared/navigation'
    end

    content_for :body do
      div(class: "app-container row") {
        div(class: "app-content-wide") { yield }
      }
    end

    render template: "layouts/raw"
  end
end
