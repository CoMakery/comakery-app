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

    def full_row_right
      row { column('text-right') { yield } }
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

    def inline_errors(object, field)
      errors = object.errors[field]
      if errors.any?
        div(class: :error) do
          text("#{field.to_s.humanize} #{errors.to_sentence}")
        end
      end
    end

    def add_classes(args, classes)
      classes += Array(args.fetch(:class, []))
      args.merge(class: classes)
    end

    def question_tooltip(text, options = {})
      tooltip(text, options) do
        i class: 'fa fa-question'
      end
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

    def markdown_to_legal_doc_html(markdown)
      Comakery::Markdown.to_legal_doc_html(markdown)
    end

    def li_if(variable, **opts)
      li(**opts) { yield } if variable.present?
    end

    def required_label_text(label_text)
      span(class: 'required') do
        text label_text
      end
    end
  end
end
