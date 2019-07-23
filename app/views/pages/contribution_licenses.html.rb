# Disable safety check to render raw html generated from a safe markdown file
# rubocop:disable Rails/OutputSafety

class Views::Pages::ContributionLicences < Views::Base
  needs :license_md

  def content
    column('license-markdown') do
      full_row do
        div(class: 'content-box') do
          text raw Comakery::Markdown.to_html(license_md)
        end
      end
    end
  end
end
