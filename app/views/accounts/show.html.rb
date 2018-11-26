class Views::Accounts::Show < Views::Base
  needs :awards, :projects, :awards_count, :projects_count

  def content
    text react_component 'Account',
      currentAccount: current_account.as_json(only: %i[email first_name last_name nickname date_of_birth country qtum_wallet ethereum_wallet]).merge(
        etherscan_address: current_account.decorate.etherscan_address,
        qtum_address: current_account.decorate.qtum_wallet_url,
        image_url: current_account.image.present? ? attachment_url(current_account, :image, :fill, 190, 190) : nil
      ),
      awards: awards,
      awardsCount: awards_count,
      projects: projects,
      projectsCount: projects_count,
      countryList: Country.all.sort,
      clippyIcon: image_url('Octicons-clippy.png')
  end
end
