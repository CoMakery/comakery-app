class Views::Accounts::Show < Views::Base
  needs :awards, :projects, :awards_count, :projects_count

  def content
    text react_component(
      'Account',
      {
        currentAccount: current_account.as_json(only: %i[email first_name last_name nickname date_of_birth country ethereum_auth_address linkedin_url github_url dribble_url behance_url]).merge(
          specialty_id: current_account.specialty_id.to_s,
          image_url: current_account.image.present? ? attachment_url(current_account, :image, :fill, 190, 190) : nil
        ),
        awards: awards,
        awardsCount: awards_count,
        projects: projects,
        projectsCount: projects_count,
        countryList: ISO3166::Country.all_translated,
        specialtyList: Specialty.all.map { |s| [s.name, s.id.to_s] },
        clippyIcon: image_url('Octicons-clippy.png')
      },
      prerender: true
    )
  end
end
