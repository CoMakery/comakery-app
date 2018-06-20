class Views::Pages::ProhibitedUse < Views::Base
  # rubocop:disable Rails/OutputSafety
  def content
    column('license-markdown') {
      full_row {
        div(class: 'content-box') {
          raw_text = File.read(Rails.root + 'lib/assets/prohibited-use.md')
          text raw Comakery::Markdown.to_html(raw_text)
        }
      }
    }
  end
end
