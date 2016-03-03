class Views::Layouts::Admin < Views::Base
  def content
    render template: 'layouts/raw'
  end
end
