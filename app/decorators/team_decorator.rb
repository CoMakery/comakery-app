# TODO: Refactor all discord-related logic to a lib

class TeamDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  # Calling Discord API to pull list of channels for the team (in Decorator?!)
  def channels
    return [] unless discord?

    d_client = Comakery::Discord.new
    @channels ||= d_client.channels(self)
  end

  # Filtering out categories and non-text channels
  # See https://discordapp.com/developers/docs/resources/channel#channel-object-channel-types
  def text_channels
    channels.reject { |c| c['parent_id'].nil? || c['type'] != 0 }
  end

  def channel_for_selects
    text_channels.map { |c| [c['name'], c['id']] }
  end

  def channel_name(channel_id)
    return unless channel_id

    channel = channels.select { |c| c['id'] == channel_id }.first
    channel['name'] if channel
  end
end
