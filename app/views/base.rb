module Views
  class Base < Fortitude::Widget
    doctype :html5

    helper :attachment_field, :transform => :output_return_value

    private

    def row(args = {}, &block)
      div(add_classes(args, [:row]), &block)
    end

    def column(size = 'small-12', args = {}, &block)
      div(add_classes(args, [:columns, size]), &block)
    end

    def full_row
      row { column { yield } }
    end

    def buttonish(size = :small, *extras)
      result = %i[button radius]
      result << size
      result.concat extras
    end

    def with_errors(object, field)
      errors = object.errors[field]
      if errors.any?
        div(class: :error) {
          yield
          small(errors.to_sentence, class: :error)
        }
      else
        yield
      end
    end

    def to_json(*args)
      as_json(*args).to_json
    end

    def add_classes(args, classes)
      classes += Array(args.fetch(:class, []))
      args.merge(class: classes)
    end

    def question_tooltip(text, options={})
      tooltip(text, options) {
        i class: "fa fa-question"
      }
    end

    def tooltip(text, options={}, &block)
      span('data-tooltip': '',
           'aria-haspopup': "true",
           'class': "has-tip #{options[:class]}",
           'data-options': "show_on:large",
           title: text) {
        block.yield
      }
    end

    def markdown_to_html(markdown)
      redcarpet.render(markdown)
    end

    def redcarpet
      @@redcarpet_renderer ||= RenderHtmlWithoutWrap.new(
        filter_html: true,
        no_images: true,
        no_styles: true,
        safe_links_only: true,
        link_attributes: {rel: 'nofollow', target: '_blank'}
      )
      @@redcarpet ||= Redcarpet::Markdown.new(@@redcarpet_renderer, autolink: true)
    end
  end
end

class RenderHtmlWithoutWrap < Redcarpet::Render::HTML
  def postprocess(full_document)
    Regexp.new(/\A<p>(.*)<\/p>\Z/m).match(full_document)[1] rescue full_document
  end
end
