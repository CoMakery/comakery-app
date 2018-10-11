class Views::Projects::Form::Channel < Views::Base
  needs :f, :providers, :current_section

  def content
    div(class: "content-box switch-target #{' active' if current_section == '#channel'}", id: 'channel', 'data-id': 'communication-channels') do
      div(class: 'award-types') do
        div(class: 'legal-box-header') { h3 'Communication Channels' }
        row do
          column('small-3') { text 'Provider' }
          column('small-3') { text 'Team or Guild' }
          column('small-3') { text 'Channel' }
          column('small-3', class: 'text-center') { text 'Remove' }
        end

        f.fields_for(:channels) do |ff|
          row(class: "channel-row#{ff.object.team_id.blank? && ff.object.name.blank? ? ' hide channel-template' : ''}") do
            ff.hidden_field :id
            ff.hidden_field :_destroy, 'data-destroy': ''
            column('small-3') do
              options = capture do
                options_for_select([[nil, nil]].concat(providers.map { |c| [c.titleize, c] }), selected: ff.object.provider)
              end
              select_tag 'provider', options, class: 'provider_select'
            end
            column('small-3 team-select-container') do
              options = []
              if ff.object.teams.present?
                options = capture do
                  options_from_collection_for_select(ff.object.teams, :id, :name, ff.object.team_id)
                end
              end
              ff.select :team_id, options, { include_blank: true }, class: 'team_select'
            end
            column('small-3 channel-select-container') do
              options = []
              if ff.object.fetch_channels.present?
                options = capture do
                  options_for_select(ff.object.channels, selected: ff.object.channel_id)
                end
              end
              ff.select :channel_id, options, { include_blank: true }, class: 'channel_select'
            end
            column('small-3', class: 'text-center') do
              a('×', href: '#', 'data-mark-and-hide': '.channel-row', class: 'close')
            end
          end
        end
      end
      if providers.present?
        row(class: 'add-channel') do
          column do
            p { a('+ add channel', href: '#', 'data-duplicate': '.channel-template') }
          end
        end
        render_cancel_and_save_buttons(f)
      else
        span(class: 'text-warning') do
          text 'Start adding channels by signing into Slack / Discord'
        end
      end
    end
  end

  def render_cancel_and_save_buttons(form)
    full_row_right do
      link_to 'Cancel', f.object, class: 'button cancel'
      form.submit 'Save', class: buttonish(:expand)
    end
  end
end
