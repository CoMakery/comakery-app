class Views::Accounts::Show < Views::Base
  ACCOUNT_FIELDS = %i[
    email first_name last_name nickname date_of_birth country
    ethereum_auth_address linkedin_url github_url dribble_url behance_url
  ].freeze

  needs :awards, :projects, :awards_count, :projects_count

  def content
    text react_component('Account', component_properties, prerender: true)
  end

  private

    def component_properties
      {
        currentAccount: current_account_properties,
        awards: awards,
        awardsCount: awards_count,
        projects: projects,
        projectsCount: projects_count,
        countryList: ISO3166::Country.all_translated,
        specialtyList: Specialty.all.map { |s| [s.name, s.id.to_s] },
        clippyIcon: image_url('Octicons-clippy.png')
      }
    end

    def current_account_properties
      current_account
        .as_json(only: ACCOUNT_FIELDS)
        .merge(
          specialty_id: current_account.specialty_id.to_s,
          image_url: account_image_url
        )
    end

    def account_image_url
      GetImageVariantPath.call(
        attachment: current_account.image,
        resize_to_fill: [190, 190]
      ).path
    end
end
