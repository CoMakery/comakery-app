module Views
  module Projects
    class New < Views::Base
      needs :project

      def content
        full_row { h1 "Create a Project" }
        render partial: "form", locals: {project: project}
      end
    end
  end
end

