require 'open-uri'
namespace :dev do
  task migrate: [:environment] do
    Authentication.all.each do |authentication|
      next unless authentication.slack?
      oauth = authentication.oauth_response
      next unless oauth
      authentication.build_team oauth
      account = authentication.account
      if account.decorate.name.blank?
        account.first_name = oauth['info']['first_name']
        account.last_name = oauth['info']['last_name']
        account.nickname = oauth['info']['user']
      end
      if oauth['info']['image'].present?
        begin
          open(oauth['info']['image'], 'rb') do |file|
            account.image = file
          end
        # rubocop:disable Lint/RescueException
        rescue Exception => e
          puts e.message
        end
      end
      account.save
      puts account.errors.full_messages
    end

    Project.all.each do |project|
      vis = project.public == true ? 1 : 0
      # rubocop:disable SkipsModelValidations
      project.update_column :visibility, vis
      next unless project.slack_channel
      channel = project.channels.find_or_create_by name: project.slack_channel, team: project.teams.last
      project.awards.each do |award|
        auth = Authentication.find_by id: award.account_id
        account_id = auth ? auth.account_id : award.account_id
        award.update channel_id: channel.id, account_id: account_id
        puts award.errors.full_messages
      end
      puts channel.errors.full_messages
    end
  end
end
