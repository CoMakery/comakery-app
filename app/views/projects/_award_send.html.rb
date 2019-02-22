class Views::Projects::AwardSend < Views::Base
  needs :project, :award, :awardable_types, :can_award

  def content
    div(id: 'award-send') do
      row(class: 'awarded-info-header') do
        if can_award
          h3 "Award #{project.payment_description}"
        else
          h3 "Earn #{project.payment_description}"
        end
      end
      br
      form_for [project, award] do |f|
        div(class: 'award-types') do
          if can_award
            row do
              column('small-12') do
                label do
                  text 'Communication Channel'
                  project_channels = [Channel.new(name: 'Email')]
                  project_channels += project.channels if project.channels.any?
                  options = capture do
                    options_from_collection_for_select(project_channels, :id, :name_with_provider, award.channel_id)
                  end
                  f.select :channel_id, options, {}, class: 'fetch-channel-users'
                end
              end
            end

            row(class: 'award-uid') do
              column('small-12') do
                if award.channel && award.channel.members(current_account).any?
                  label(class: 'uid-select') do
                    options = capture do
                      options_for_select(award.channel.members(current_account), award.uid)
                    end
                    text 'User'
                    f.select :uid, options, include_blank: true, class: 'member-select'
                  end

                  label(class: 'uid-email hide') do
                    text 'Email Address'
                    f.text_field :uid, class: 'award-email', value: award.email, name: nil
                  end
                else
                  label(class: 'uid-select hide') do
                    text 'User'
                    f.select :uid, []
                  end

                  label(class: 'uid-email') do
                    text 'Email Address'
                    f.text_field :uid, class: 'award-email', value: award.email
                  end
                end
              end
            end

            row do
              column('small-12') do
                label do
                  text 'Award Type'
                  options = []
                  if awardable_types.any?
                    options = capture do
                      options_from_collection_for_select(awardable_types.order('amount asc').decorate, :id, :name_with_amount, award.award_type_id)
                    end
                  end
                  f.select :award_type_id, options, {}
                end
              end
            end

            row do
              column('small-3') do
                label do
                  text 'Quantity'
                  f.text_field(:quantity, type: :text, default: 1, class: 'financial')
                end
              end

              row do
                column('small-12') do
                  with_errors(project, :description) do
                    label do
                      text 'Description'
                      f.text_area(:description)
                      link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text')
                    end
                  end
                end
              end
              row do
                column('small-12') do
                  div(class: 'preview_award_div')

                  button 'Send Award', class: 'button radius small metamask-transfer-btn button_submit', data: { disable_with: 'Send Award' }
                end
              end
            end
          else
            project.award_types.order('amount asc').decorate.each do |award_type|
              row(class: 'award-type-row') do
                if award_type.active?
                  column('small-12') do
                    with_errors(project, :account_id) do
                      label do
                        row do
                          column('small-12') do
                            row do
                              span(award_type.name)
                              span(class: ' financial') do
                                text " (#{award_type.amount_pretty})"
                              end
                              text ' (Community Awardable)' if award_type.community_awardable?
                              br
                              span(class: 'help-text') { text raw(award_type.description_markdown) }
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    transfer_tokens

    content_for :js do
      preview_award_script
    end
  end

  def transfer_tokens
    last_award_id = session.delete(:last_award_id)
    if (last_award = Award.find_by(id: last_award_id)) && current_account.decorate.can_send_awards?(last_award.project) && !last_award.ethereum_transaction_address?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/qrc20_qweb3_script.js') if project.coin_type_qrc20?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/cardano_trezor_script.js') if project.coin_type_ada?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/bitcoin_trezor_script.js') if project.coin_type_btc?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/qtum_ledger_script.js') if project.coin_type_qtum?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/eos_scatter_script.js') if project.coin_type_eos?
      javascript_include_tag 'eztz.min' if project.coin_type_xtz?
      javascript_include_tag '//connect.trezor.io/6/trezor-connect.js' if project.coin_type_xtz?
      javascript_include_tag Webpacker.manifest.lookup!('wallets/tezos_trezor_script.js') if project.coin_type_xtz?

      render 'sessions/metamask_modal'
      javascript_tag(transfer_tokens_script(last_award))
    end
  end

  def transfer_tokens_script(last_award)
    %(
      $(function() {
        var currentState = history.state;
        if(!currentState || !currentState['award']) {
          history.pushState({ award: '#{last_award.id}' }, 'transfer_tokens_award-#{last_award.id}');
          setTimeout(function() { transferAward(JSON.parse('#{last_award.decorate.json_for_sending_awards}')); }, 1900);
        }
      });
    )
  end

  def preview_award_script
    text(<<-JAVASCRIPT.html_safe)
      function resetSendingAwardButtonSection() {
        $('.preview_award_div').html('Loading...');
        $('button.button_submit').removeClass('submit');
        $('button.button_submit img').remove();
      }

      $(function() {
        $('body').on('change', "[name='award[channel_id]']", function() {
          resetSendingAwardButtonSection()
        })

        $('body').on('change', "[name='award[uid]'], [name='award[award_type_id]'], [name='award[quantity]']", function() {
          var uid;
          var channel_id = $("[name='award[channel_id]']").val();
          if(channel_id && channel_id != '') {
            uid = $(".uid-select [name='award[uid]']").val();
          } else {
            uid = $(".uid-email [name='award[uid]']").val();
          }
          var quantity = $("[name='award[quantity]']").val();
          var award_type_id = $("[name='award[award_type_id]']").val();
          resetSendingAwardButtonSection();
          if(uid && uid != '' && quantity && award_type_id) {
            $.get('#{preview_project_awards_path(project_id: project.id, format: :js)}', {uid: uid, quantity: quantity, award_type_id: award_type_id, channel_id: channel_id})
          }
        })
      });
    JAVASCRIPT
  end
end
