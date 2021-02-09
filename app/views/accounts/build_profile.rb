class Views::Accounts::BuildProfile < Views::Base
  needs :account, :skip_validation

  def content
    row do
      column(%i[small-12 large-6], class: 'large-centered build-profile') do
        h1('Setup Your Account')

        form_for account, url: update_profile_accounts_path do |f|
          row do
            column('large-12') do
              if skip_validation
                label do
                  text 'First Name'
                  f.text_field :first_name
                end
              else
                with_errors(account, :first_name) do
                  label do
                    text 'First Name'
                    f.text_field :first_name
                  end
                end
              end
            end

            column('large-12') do
              if skip_validation
                label do
                  text 'Last Name'
                  f.text_field :last_name
                end
              else
                with_errors(account, :last_name) do
                  label do
                    text 'Last Name'
                    f.text_field :last_name
                  end
                end
              end
            end

            if account.email.blank?
              column('large-12') do
                if skip_validation
                  label do
                    text 'Email'
                    f.text_field :email
                  end
                else
                  with_errors(account, :email) do
                    label do
                      text 'Email'
                      f.text_field :email
                    end
                  end
                end
              end
            end

            column('large-12') do
              if skip_validation
                label do
                  text 'Date of Birth'
                  f.text_field :date_of_birth, placeholder: 'mm/dd/yyyy', class: 'datepicker'
                end
              else
                with_errors(account, :date_of_birth) do
                  label do
                    text 'Date of Birth'
                    f.text_field :date_of_birth, placeholder: 'mm/dd/yyyy', class: 'datepicker'
                  end
                end
              end
            end

            column('large-12') do
              f.object.country ||= 'United States of America'
              if skip_validation
                label do
                  text 'Country of Citizenship'
                  f.select :country, Country.all.sort
                end
              else
                with_errors(account, :country) do
                  label do
                    text 'Country of Citizenship'
                    f.select :country, Country.all.sort
                  end
                end
              end
            end

            column('large-12 horizontal-line')

            column('large-12 agreement') do
              f.submit 'Get Started', class: buttonish(:medium), style: 'margin: 0'
            end
          end
        end
      end
    end
  end
end
