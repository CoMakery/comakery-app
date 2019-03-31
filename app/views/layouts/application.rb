class Views::Layouts::Application < Views::Base
  def content
    doctype!
    html(lang: 'en') do
      head do
        render partial: 'layouts/google_tag_manager.html'
        render partial: 'shared/unbounce.html'
        meta :content => 'text/html; charset=UTF-8', 'http-equiv' => 'Content-Type'
        meta charset: 'utf-8'
        meta name: 'viewport', content: 'width=device-width, initial-scale=1.0'
        description = content_for?(:description) ? capture { yield(:description) } : I18n.t('project_description')
        meta name: 'description', content: description
        meta name: 'robots', content: 'NOODP' # don't use Open Director Project in search listing
        meta name: 'theme-color', content: '#ffffff'
        meta name: 'msapplication-TileColor', content: '#ffffff'
        meta name: 'msapplication-TileImage', content: '/assets/favicon/ms-icon-144x144.png'

        title content_for?(:title) ? capture { yield(:title) } : I18n.t('project_name')

        stylesheet_link_tag 'application', media: 'all'
        stylesheet_link_tag '//fonts.googleapis.com/css?family=Lato|Slabo+27px'
        stylesheet_link_tag '//fonts.googleapis.com/css?family=Montserrat:400,400i,500,500i,700&amp;subset=cyrillic,cyrillic-ext,latin-ext,vietnamese', defer: true
        stylesheet_link_tag '//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.css'
        javascript_include_tag '//cdnjs.cloudflare.com/ajax/libs/cookieconsent2/3.1.0/cookieconsent.min.js'
        javascript_include_tag :modernizr
        javascript_include_tag 'application'

        javascript_include_tag Webpacker.manifest.lookup!('application.js')

        javascript_include_tag 'jquery.visible' if Rails.env.test?

        if ENV['AIRBRAKE_API_KEY'].present? && ENV['AIRBRAKE_PROJECT_ID'].present?
          javascript_include_tag 'airbrake-shim',
            'data-airbrake-project-id' => ENV['AIRBRAKE_PROJECT_ID'],
            'data-airbrake-project-key' => ENV['AIRBRAKE_API_KEY'],
            'data-airbrake-environment-name' => ENV['APP_NAME']
        end
        favicon_link_tag 'favicon/favicon.ico'
        favicon_link_tag 'favicon/apple-icon-57x57.png', rel: 'apple-touch-icon', sizes: '57x57', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-60x60.png', rel: 'apple-touch-icon', sizes: '60x60', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-72x72.png', rel: 'apple-touch-icon', sizes: '72x72', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-76x76.png', rel: 'apple-touch-icon', sizes: '76x76', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-114x114.png', rel: 'apple-touch-icon', sizes: '114x114', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-120x120.png', rel: 'apple-touch-icon', sizes: '120x120', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-144x144.png', rel: 'apple-touch-icon', sizes: '144x144', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-152x152.png', rel: 'apple-touch-icon', sizes: '152x152', type: 'image/png'
        favicon_link_tag 'favicon/apple-icon-180x180.png', rel: 'apple-touch-icon', sizes: '180x180', type: 'image/png'
        favicon_link_tag 'favicon/android-icon-192x192.png', rel: 'icon', sizes: '192x192', type: 'image/png'
        favicon_link_tag 'favicon/favicon-32x32.png', rel: 'icon', sizes: '32x32', type: 'image/png'
        favicon_link_tag 'favicon/favicon-96x96.png', rel: 'icon', sizes: '96x96', type: 'image/png'
        favicon_link_tag 'favicon/favicon-16x16.png', rel: 'icon', sizes: '16x16', type: 'image/png'
        favicon_link_tag 'favicon/manifest.json', rel: 'manifest', type: 'application/json'
        csrf_meta_tags
      end

      body(class: "#{controller_name}-#{action_name} #{current_account&.slack_auth ? '' : 'signed-out'}") do
        render partial: 'layouts/google_tag_no_script.html'

        text react_component(
          'layouts/Header',
          {
            is_admin: current_account&.comakery_admin?,
            is_logged_in: (current_account ? true : false),
            current_path: request.fullpath
          },
          prerender: true
        )

        div(class: "app-container row#{' home' if current_account && action_name == 'join_us'}") do
          message
          content_for?(:pre_body) ? yield(:pre_body) : ''
          div(class: 'main') do
            div(class: 'large-10 medium-11 small-12 small-centered columns no-h-pad', style: 'max-width: 1535px;') do
              content_for?(:body) ? yield(:body) : yield
            end
          end
        end

        text react_component(
          'layouts/Footer',
          {
            is_logged_in: (current_account ? true : false)
          },
          prerender: true
        )

        javascript_tag("
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

          ga('create', 'UA-75985416-1', 'auto');
          ga('send', 'pageview');
        ")

        if content_for?(:footer)
          footer(class: 'fat-footer') do
            yield(:footer)
          end
        end

        if content_for?(:js)
          script do
            yield(:js)
          end
        end
      end
    end
  end

  def message
    div(class: 'large-12 medium-12 small-12 small-centered') do
      if error
        div('aria-labelledby' => 'flash-msg-error', 'aria-role' => 'dialog', class: ['callout', 'flash-msg', 'error'], 'data-alert' => '', 'data-closable' => '', style: 'padding-right: 30px;') do
          button('class' => 'close-button float-right', 'aria-label' => 'Close alert', 'data-close' => '') do
            span('aria-hidden' => true) { text 'x' }
          end
          span(id: 'flash-msg-error') do
            text ActiveSupport::SafeBuffer.new(error)
          end
        end
      elsif notice
        div('aria-labelledby' => 'flash-msg-notice', 'aria-role' => 'dialog', class: ['callout', 'flash-msg', 'notice'], 'data-alert' => '', 'data-closable' => '', style: 'padding-right: 30px;') do
          button('class' => 'close-button float-right', 'aria-label' => 'Close alert', 'data-close' => '') do
            span('aria-hidden' => true) { text 'x' }
          end
          span(id: 'flash-msg-error') do
            text ActiveSupport::SafeBuffer.new(notice)
          end
        end
      else
        flash.each do |name, msg|
          div('aria-labelledby' => "flash-msg-#{name}", 'aria-role' => 'dialog', class: ['callout', 'flash-msg', name], 'data-alert' => '', 'data-closable' => '', style: 'padding-right: 30px;') do
            button('class' => 'close-button float-right', 'aria-label' => 'Close alert', 'data-close' => '') do
              span('aria-hidden' => true) { text 'x' }
            end
            span(id: "flash-msg-#{name}") do
              text ActiveSupport::SafeBuffer.new(msg)
            end
          end
        end
      end
      flash.clear
    end
  end
end
