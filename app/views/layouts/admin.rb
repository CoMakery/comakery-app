class Views::Layouts::Admin < Views::Base
  def content
    render template: 'layouts/logged_in'
  end
end
