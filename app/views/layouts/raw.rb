class Views::Layouts::Raw < Views::Base
  def content
    doctype!
    html(lang: "en") {
      head {
        meta(:content => "text/html; charset=UTF-8", "http-equiv" => "Content-Type")
        meta(charset: "utf-8")
        meta(content: "width=device-width, initial-scale=1.0", name: "viewport")
        meta(content: Rails.application.config.project_description, name: "description")

        title(content_for?(:title) ? yield(:title) : Rails.application.config.project_name)

        stylesheet_link_tag 'application', media: 'all'
        stylesheet_link_tag '//fonts.googleapis.com/css?family=Lato|Slabo+27px'
        javascript_include_tag :modernizr
        javascript_include_tag 'application'
        if ENV['AIRBRAKE_API_KEY'].present? && ENV['AIRBRAKE_PROJECT_ID'].present?
          javascript_include_tag "airbrake-shim",
                                 "data-airbrake-project-id" => ENV['AIRBRAKE_PROJECT_ID'],
                                 "data-airbrake-project-key" => ENV['AIRBRAKE_API_KEY'],
                                 "data-airbrake-environment-name" => ENV['APP_NAME']
        end
        favicon_link_tag "favicon/apple-icon-57x57.png", rel:"apple-touch-icon", sizes:"57x57", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-60x60.png", rel:"apple-touch-icon", sizes:"60x60", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-72x72.png", rel:"apple-touch-icon", sizes:"72x72", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-76x76.png", rel:"apple-touch-icon", sizes:"76x76", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-114x114.png", rel:"apple-touch-icon", sizes:"114x114", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-120x120.png", rel:"apple-touch-icon", sizes:"120x120", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-144x144.png", rel:"apple-touch-icon", sizes:"144x144", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-152x152.png", rel:"apple-touch-icon", sizes:"152x152", type: 'image/png'
        favicon_link_tag "favicon/apple-icon-180x180.png", rel:"apple-touch-icon", sizes:"180x180", type: 'image/png'
        favicon_link_tag "favicon/android-icon-192x192.png", rel:"icon", sizes:"192x192", type: "image/png"
        favicon_link_tag "favicon/favicon-32x32.png", rel:"icon", sizes:"32x32", type: "image/png"
        favicon_link_tag "favicon/favicon-96x96.png", rel:"icon", sizes:"96x96", type: "image/png"
        favicon_link_tag "favicon/favicon-16x16.png", rel:"icon", sizes:"16x16", type: "image/png"
        favicon_link_tag "favicon/manifest.json", rel:"manifest", type: "application/json"
        meta(name: "msapplication-TileColor", content: "#ffffff")
        meta(name: "msapplication-TileImage", content: "/assets/favicon/ms-icon-144x144.png")
        meta(name: "theme-color", content: "#ffffff")
        csrf_meta_tags
      }

      body(class: "#{controller_name}-#{action_name} #{current_account&.slack_auth ? '' : 'signed-out'}") {
        div(class: "contain-to-grid top-bar-container") {
          div(class: "top-bar large-10 medium-11 small-12 small-centered columns", "data-topbar" => "", role: "navigation") {
            div(class: "top-bar-title") {
              span("data-hide-for" => "medium", "data-responsive-toggle" => "responsive-menu") {
                span(class: "menu-icon dark", "data-toggle" => "")
              }
              a(class: "name", href: root_path) {
                image_tag("comakery-logo.svg", class: "logo")
              }
            }
            render partial: 'shared/navigation'
          }
        }

        div(class: "app-container row") {
          div(class: "large-10 medium-11 small-12 small-centered columns") {
            flash.each do |name, msg|
              div("aria-labelledby" => "flash-msg-#{name}", "aria-role" => "dialog", class: ['callout', 'flash-msg', name], "data-alert" => "", "data-closable" => "") {
                button("class" => "close-button float-right", "aria-label" => "Close alert", "data-close" => "") {
                  span("aria-hidden" => true) { text raw '&times;' }
                }
                p(msg, id: "flash-msg-#{name}")
              }
            end
          }

          content_for?(:pre_body) ? yield(:pre_body) : ''

          div(class: "main") {
            div(class: "large-10 medium-11 small-12 small-centered columns") {
              content_for?(:body) ? yield(:body) : yield
            }
          }
        }
        javascript_tag("
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-75985416-1', 'auto');
          ga('send', 'pageview');
        ")

        if content_for?(:footer)
          footer(class: 'fat-footer') {
            yield(:footer)
          }
        end

        if content_for?(:js)
          script {
            yield(:js)
          }
        end
      }
    }
  end
end
