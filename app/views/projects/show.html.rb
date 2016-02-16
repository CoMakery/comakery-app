class Views::Projects::Show < Views::Base
  needs :project

  def content
    full_row {
      h1("New account")
    }
  end
end
