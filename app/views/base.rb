module Views
  class Base < Fortitude::Widget
    doctype :html5

    helper :attachment_field, transform: :output_return_value

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
        div(class: :error) do
          yield
          small(errors.to_sentence, class: :error)
        end
      else
        yield
      end
    end

    def add_classes(args, classes)
      classes += Array(args.fetch(:class, []))
      args.merge(class: classes)
    end

    def tooltip(text, options = {}, &block)
      span('data-tooltip': '',
           'aria-haspopup': 'true',
           'class': "has-tip #{options[:class]}",
           'data-options': 'show_on:large',
           title: text) do
        block.yield
      end
    end

    def markdown_to_html(markdown)
      Comakery::Markdown.to_html(markdown)
    end
  end
end
