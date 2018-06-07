class Views::Pages::ProhibitedUsePolicy < Views::Base
  # rubocop:disable Rails/OutputSafety
  def content
    column('license-markdown') {
      full_row {
        div(class: 'content-box') {
          text = File.read(Rails.root + 'lib/assets/prohibited-use-policy.md')
          text raw markdown_to_legal_doc_html(text)
        }
      }
    }
  end
end
