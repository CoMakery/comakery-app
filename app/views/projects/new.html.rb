module Views
  module Projects
    class New < Views::Base
      needs :project

      def content
        render partial: "form", locals: {project: project}
      end
    end
  end
end

