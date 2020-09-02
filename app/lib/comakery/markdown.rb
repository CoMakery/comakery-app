require 'redcarpet/render_strip'

module Comakery
  class Markdown
    def self.to_html(markdown)
      return '' if markdown.blank?

      new.html.render(markdown)
    end

    def self.to_text(markdown)
      return '' if markdown.blank?

      text = new.text.render(markdown)
      text.gsub(/<.+?>/, '') # remove HTML tags
    end

    def self.to_legal_doc_html(markdown)
      return '' if markdown.blank?

      markdown = markdown.gsub(/\[(.+?)\]\(.+?\)/, '\1') # strip markdown links
      new.legal_doc_html.render(markdown)
    end

    def html
      html_renderer = RenderHtmlWithoutWrap.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        safe_links_only: true,
        link_attributes: { rel: 'nofollow', target: '_blank' }
      )
      Redcarpet::Markdown.new(html_renderer, autolink: true)
    end

    def legal_doc_html
      html_renderer = RenderHtmlWithoutWrap.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        no_links: true
      )
      Redcarpet::Markdown.new(html_renderer, no_links: true)
    end

    def text
      Redcarpet::Markdown.new(Redcarpet::Render::StripDown.new)
    end
  end

  class RenderHtmlWithoutWrap < Redcarpet::Render::HTML
    def postprocess(full_document)
      Regexp.new(%r{\A<p>(.*)</p>\Z}m).match(full_document)[1]
    rescue StandardError
      full_document
    end
  end
end
