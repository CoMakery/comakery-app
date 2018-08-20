class Views::Layouts::Mailer < Views::Base
  def content
    html do
      body do
        yield
      end
    end
  end
end
