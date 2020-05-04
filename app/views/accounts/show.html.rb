class Views::Accounts::Show < Views::Base
  needs :awards, :projects, :awards_count, :projects_count

  def content
    text react_component(
      'Account',
      {
        currentAccount: current_account.as_json(only: %i[email first_name last_name nickname date_of_birth country qtum_wallet ethereum_auth_address ethereum_wallet cardano_wallet bitcoin_wallet eos_wallet tezos_wallet occupation linkedin_url github_url dribble_url behance_url]).merge(
          specialty_id: current_account.specialty_id.to_s,
          etherscan_address: current_account.decorate.etherscan_address,
          qtum_address: current_account.decorate.qtum_wallet_url,
          cardano_address: current_account.decorate.cardano_wallet_url,
          bitcoin_address: current_account.decorate.bitcoin_wallet_url,
          eos_address: current_account.decorate.eos_wallet_url,
          tezos_address: current_account.decorate.tezos_wallet_url,
          image_url: current_account.image.present? ? attachment_url(current_account, :image, :fill, 190, 190) : nil
        ),
        awards: awards,
        awardsCount: awards_count,
        projects: projects,
        projectsCount: projects_count,
        countryList: Country.all.sort,
        specialtyList: Specialty.all.map { |s| [s.name, s.id.to_s] },
        clippyIcon: image_url('Octicons-clippy.png')
      },
      prerender: true
    )
  end
end
