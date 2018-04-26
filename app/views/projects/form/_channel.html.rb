class Views::Projects::Form::Channel < Views::Base
  needs :f, :providers

  def content
    div(class: 'content-box', 'data-id': 'communication-channels') {
      div(class: 'award-types') {
        div(class: 'legal-box-header') { h3 'Communication Channels' }
        row {
          column('small-3') { text 'Provider' }
          column('small-3') { text 'Team or Guild' }
          column('small-3') { text 'Channel' }
          column('small-3', class: 'text-center') { text 'Remove' }
        }

        f.fields_for(:channels) do |ff|
          row(class: "channel-row#{ff.object.team_id.blank? && ff.object.name.blank? ? ' hide channel-template' : ''}") {
            ff.hidden_field :id
            ff.hidden_field :_destroy, 'data-destroy': ''
            column('small-3') {
              options = capture do
                options_for_select([[nil, nil]].concat(providers.map { |c| [c.titleize, c] }), selected: ff.object.provider)
              end
              select_tag 'provider', options, class: 'provider_select'
            }
            column('small-3 team-select-container') {
              options = []
              if ff.object.teams.present?
                options = capture do
                  options_from_collection_for_select(ff.object.teams, :id, :name, ff.object.team_id)
                end
              end
              ff.select :team_id, options, { include_blank: true }, class: 'team_select'
            }
            column('small-3 channel-select-container') {
              options = []
              if ff.object.fetch_channels.present?
                options = capture do
                  options_for_select(ff.object.channels, selected: ff.object.channel_id)
                end
              end
              ff.select :channel_id, options, { include_blank: true }, class: 'channel_select'
            }
            column('small-3', class: 'text-center') {
              a('×', href: '#', 'data-mark-and-hide': '.channel-row', class: 'close')
            }
          }
        end
      }
      row(class: 'add-channel') {
        column {
          p { a('+ add channel', href: '#', 'data-duplicate': '.channel-template') }
        }
      }
      render_cancel_and_save_buttons(f)
    }
  end

  def render_cancel_and_save_buttons(form)
    full_row_right {
      link_to 'Cancel', f.object, class: 'button cancel'
      form.submit 'Save', class: buttonish(:expand)
    }
  end
end
