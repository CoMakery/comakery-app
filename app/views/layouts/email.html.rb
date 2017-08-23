class Views::Layouts::Email < Views::EmailBase
  def content
    doctype!
    html(xmlns: 'http://www.w3.org/1999/xhtml') do
      head do
        meta(content: 'text/html; charset=utf-8', 'http-equiv' => 'Content-Type')
        meta(content: 'width=device-width', name: :viewport)
        # These cannot be stylesheet_link_tags, see https://github.com/fphilipe/premailer-rails/issues/108
        style Rails.application.assets.find_asset('email_ink.css').body
        style Rails.application.assets.find_asset('email_custom.css').body
      end

      body do
        table(class: :body) do
          tr do
            center_td(valign: :top) do
              wide_row(class: :header) do
                last_column do
                  td do
                    span Rails.application.config.project_name, class: :logoType
                  end
                end
              end

              yield

              render 'shared/email_footer'
            end
          end
        end
      end
    end
  end
end
