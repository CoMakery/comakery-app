class TeamDecorator < Draper::Decorator
  delegate_all
  include ActionView::Helpers::NumberHelper

  def channels
    return [] unless discord?
    d_client = Comakery::Discord.new
    @channels ||= d_client.channels(self)
  end

  def parent_channels
    return @parent_channels if @parent_channels
    parents = channels.select { |c| c['parent_id'].nil? }
    @parent_channels = {}
    parents.each do |c|
      @parent_channels[c['id']] = c['name']
    end
    @parent_channels
  end

  def child_channels
    channels.reject { |c| c['parent_id'].nil? }
  end

  def channel_name(channel_id)
    return unless channel_id
    channel = channels.select { |c| c['id'] == channel_id }.first
    channel['name'] if channel
  end

  def channel_for_selects
    return @channel_for_selects if @channel_for_selects
    @channel_for_selects = []
    child_channels.each do |channel|
      parent_name = parent_channels[channel['parent_id']]
      @channel_for_selects << [channel['name'], channel['id']] if parent_name == 'Text Channels'
    end
    @channel_for_selects
  end
end
