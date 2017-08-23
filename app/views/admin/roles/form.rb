class Views::Admin::Roles::Form < Views::Base
  needs :role

  def content
    form_for([:admin, role]) do |f|
      with_errors(role, :name) do
        label do
          text 'Name: '
          f.text_field :name
        end
      end

      with_errors(role, :key) do
        label do
          text 'Key: '
          f.text_field :key
        end
      end

      div(class: 'actions') do
        f.submit class: buttonish
      end
    end
  end
end
