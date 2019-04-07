class Views::Accounts::BuildProfile < Views::Base
  needs :account, :skip_validation

  def content
    row do
      column(%i[small-12 large-6], class: 'large-centered') do
        h1('Build Your Profile')

        form_for account, url: update_profile_accounts_path do |f|
          row do
            if account.email.blank?
              column('large-12') do
                if skip_validation
                  label do
                    text 'E-mail: *'
                    f.email_field :email
                  end
                else
                  with_errors(account, :email) do
                    label do
                      text 'E-mail: *'
                      f.email_field :email
                    end
                  end
                end
              end
            end

            column('large-12') do
              with_errors(account, :first_name) do
                label do
                  text 'First Name: *'
                  f.text_field :first_name
                end
              end
            end

            column('large-12') do
              with_errors(account, :last_name) do
                label do
                  text 'Last Name: *'
                  f.text_field :last_name
                end
              end
            end

            column('large-12') do
              with_errors(account, :date_of_birth) do
                label do
                  text 'Date of Birth: *'
                  f.text_field :date_of_birth, placeholder: 'mm/dd/yyyy', class: 'datepicker'
                end
              end
            end

            column('large-12') do
              f.object.country ||= 'United States of America'
              with_errors(account, :country) do
                label do
                  text 'Country: *'
                  f.select :country, Country.all.sort
                end
              end
            end

            column('large-12') do
              with_errors(account, :specialty) do
                label do
                  text 'What Is Your Specialty? *'
                  f.collection_select :specialty_id, Specialty.all, :id, :name, include_blank: 'Please Select One'
                end
              end
            end

            column('large-12') do
              with_errors(account, :occupation) do
                label do
                  text 'What Is Your Occupation?'
                  f.text_field :occupation
                end
              end
            end

            column('large-12') do
              with_errors(account, :linkedin_url) do
                label do
                  text 'LinkedIn Profile URL'
                  f.text_field :linkedin_url
                end
              end
            end

            column('large-12') do
              with_errors(account, :github_url) do
                label do
                  text 'GitHub Profile URL'
                  f.text_field :github_url
                end
              end
            end

            column('large-12') do
              with_errors(account, :dribble_url) do
                label do
                  text 'Dribble Profile URL'
                  f.text_field :dribble_url
                end
              end
            end

            column('large-12') do
              with_errors(account, :behance_url) do
                label do
                  text 'Behance Profile URL'
                  f.text_field :behance_url
                end
              end
            end

            column('large-12 agreement') do
              f.submit 'SAVE YOUR PROFILE', class: buttonish(:medium), style: 'margin: 0'
            end
          end
        end
      end
    end
  end
end
