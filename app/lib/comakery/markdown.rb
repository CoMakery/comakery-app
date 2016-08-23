module Comakery
  class  Markdown
    include Singleton

    def self.to_html(markdown)
      instance.redcarpet.render(markdown)
    end

    def redcarpet
      return @redcarpet if @redcarpet

      renderer ||= RenderHtmlWithoutWrap.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        safe_links_only: true,
        link_attributes: {rel: 'nofollow', target: '_blank'}
      )
      @redcarpet = Redcarpet::Markdown.new(renderer, autolink: true)
    end
  end

  class RenderHtmlWithoutWrap < Redcarpet::Render::HTML
    def postprocess(full_document)
      Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
    end
  end
end
