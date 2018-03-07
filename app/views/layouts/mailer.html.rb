class Views::Layouts::Mailer < Views::Base
  def content
    html {
      body {
        yield
      }
    }
  end
end
