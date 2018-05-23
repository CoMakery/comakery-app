require 'open-uri'
namespace :dev do
  task migrate: [:environment] do
    Authentication.all.each do |authentication|
      next unless authentication.slack?
      oauth = authentication.oauth_response
      authentication.build_team(oauth) if oauth
      account = authentication.account
      if authentication.slack_first_name || authentication.slack_last_name
        account.first_name = authentication.slack_first_name
        account.last_name = authentication.slack_last_name
      elsif account.first_name.blank? && account.last_name.blank?
        account.nickname = authentication.slack_user_name
      end
      image_url = oauth['info']['image'] if oauth
      image_url ||= authentication.slack_image_32_url
      if image_url.present?
        begin
          open(image_url, 'rb') do |file|
            account.image = file
          end
        # rubocop:disable Lint/RescueException
        rescue Exception => e
          puts e.message
        end
      end
      account.save(validate: false)
      puts account.errors.full_messages
    end

    Project.all.each do |project|
      vis = project.public == true ? 1 : 0
      # rubocop:disable SkipsModelValidations
      project.update_column :visibility, vis
      channel = project.channels.find_or_create_by channel_id: project.slack_channel, team: project.teams.last if project.slack_channel
      project.awards.each do |award|
        award.update_columns channel_id: channel&.id, account_id: award.authentication&.account_id
        puts award.errors.full_messages
      end
      puts channel.errors.full_messages
    end
  end
end
