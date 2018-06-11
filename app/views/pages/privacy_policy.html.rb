class Views::Pages::PrivacyPolicy < Views::Base
  # rubocop:disable Rails/OutputSafety
  def content
    column('license-markdown') {
      full_row {
        div(class: 'content-box') {
          raw_text = File.read(Rails.root + 'lib/assets/privacy-policy.md')
          text raw Comakery::Markdown.to_html(raw_text)
        }
      }
    }
  end
end
