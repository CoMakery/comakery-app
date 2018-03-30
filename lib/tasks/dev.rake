require 'open-uri'
namespace :dev do
  task migrate: [:environment] do
    Authentication.all.each do |authentication|
      oauth = authentication.oauth_response
      next unless oauth
      authentication.build_team oauth
      account = authentication.account
      if account.name.blank?
        if oauth['info']['first_name'].blank? && oauth['info']['last_name'].blank?
          account.first_name = oauth['info']['name']
        else
          account.first_name = oauth['info']['first_name']
          account.last_name = oauth['info']['first_name']
        end
      end
      if oauth['info']['image'].present?
        begin
          open(oauth['info']['image'], 'rb') do |file|
            account.image = file
          end
        rescue
          puts "can't open #{oauth['info']['image']} - ##{authentication.id}"
        end
      end
      account.save
      puts account.errors.full_messages
    end

    Project.all.each do |project|
      next unless project.slack_channel
      channel = project.channels.find_or_create_by name: project.slack_channel, team: project.teams.last
      project.awards.each do |award|
        award.update channel_id: channel.id
        puts award.errors.full_messages
      end
      puts channel.errors.full_messages
    end
  end
end
