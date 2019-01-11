class Views::Projects::Form::BlockchainSettings < Views::Base
  needs :project, :f

  def content
    row do
      column('large-6 small-12') do
        selected = f.object.coin_type
        options = capture do
          options_for_select(coin_type_options, selected: selected)
        end
        with_errors(project, :coin_type) do
          label do
            text 'Payment Type'
            f.select :coin_type, options, { include_blank: true }, disabled: project.completed_awards.any?
          end
        end

        selected = f.object.ethereum_network
        selected = 'main' if project.completed_awards.blank? && f.object.ethereum_network.blank? && project.coin_type_on_ethereum?
        options = capture do
          options_for_select(ethereum_network_options, selected: selected)
        end
        with_errors(project, :ethereum_network) do
          label(class: "ethereum-network-lbl #{'hide' unless project.coin_type_on_ethereum?}") do
            text 'Blockchain Network'
            f.select :ethereum_network, options, { include_blank: true }, disabled: project.completed_awards.any?
          end
        end

        selected = f.object.blockchain_network
        options = capture do
          options_for_select(blockchain_network_options, selected: selected)
        end
        with_errors(project, :blockchain_network) do
          label(class: "blockchain-network-lbl #{'hide' if project.coin_type_on_ethereum?}") do
            text 'Blockchain Network'
            f.select :blockchain_network, options, { include_blank: true }, disabled: project.completed_awards.any?, 'data-info': Project.blockchain_networks.to_json
          end
        end

        css_class = "contract-info-div #{'hide' unless project.coin_type_token?}"
        div(class: css_class) do
          with_errors(project, :ethereum_contract_address) do
            label(class: "ethereum-contract-address-lbl #{'hide' unless project.coin_type_erc20?}") do
              text 'Contract Address'
              f.text_field :ethereum_contract_address, placeholder: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367', disabled: project.completed_awards.any?
            end
          end

          with_errors(project, :contract_address) do
            label(class: "contract-address-lbl #{'hide' unless project.coin_type_qrc20?}") do
              text 'Contract Address'
              f.text_field :contract_address, placeholder: '2c754a7b03927a5a30ca2e7c98a8fdfaf17d11fc', disabled: project.completed_awards.any?
            end
          end

          with_errors(project, :token_symbol) do
            label do
              text 'Symbol'
              f.text_field :token_symbol
            end
          end

          with_errors(project, :decimal_places) do
            label do
              text 'Decimal Places'
              f.text_field :decimal_places, disabled: project.completed_awards.any?
            end
          end
        end

        with_errors(project, :maximum_tokens) do
          label do
            required_label_text 'Budget'
            f.text_field :maximum_tokens, type: 'number', disabled: project.license_finalized? || project.ethereum_enabled?
          end
        end

        with_errors(project, :maximum_royalties_per_month) do
          label do
            required_label_text 'Maximum Awarded Per Month'
            f.text_field :maximum_royalties_per_month,
              type: :number, placeholder: '25000',
              disabled: project.license_finalized?
          end
        end
        div(class: "revenue-sharing-terms #{'hide' unless project.revenue_share?}") do
          with_errors(project, :royalty_percentage) do
            label do
              required_label_text 'Revenue Shared With Contributors'
              question_tooltip "The Project Owner agrees to count money customers pay either to license, or to use a hosted instance of, the Project as 'Revenue'. Money customers pay for consulting, training, custom development, support, and other services related to the Project does not count as Revenue."
              # percentage_div { f.text_field :royalty_percentage, placeholder: "5%", class: 'input-group-field' }
              percentage_div f, :royalty_percentage, placeholder: '10',
                                                     disabled: project.license_finalized?
            end
          end
        end
        if project.revenue_share?
          div do
            with_errors(project, :revenue_sharing_end_date) do
              label do
                text 'Revenue Sharing End Date'
                f.text_field :revenue_sharing_end_date, class: 'datepicker-no-limit', placeholder: 'mm/dd/yyyy', value: f.object.revenue_sharing_end_date&.strftime('%m/%d/%Y'), disabled: project.license_finalized?
                div(class: 'help-text') { text '"mm/dd/yyy" means revenue sharing does not end.' }
              end
            end
          end
        end

        # # Uncomment this after legal review  of licenses, disclaimers, etc.
        # with_errors(project, :license_finalized) {
        #   label {
        #     f.check_box :license_finalized, disabled: project.license_finalized?
        #     text 'The Contribution License Revenue Sharing Terms Are Finalized'
        #     div(class: 'help-text') { text "Leave this unchecked if you want to use #{I18n.t('project_name')} for tracking contributions with no legal agreement for sharing revenue." }
        #   }
        # }
      end

      column('large-6 small-12') do
        br
        div(class: "revenue-sharing-terms #{'hide' unless project.revenue_share?}") do
          h5 'Example'
          table(class: 'royalty-calc') do
            thead do
              tr do
                th { text 'Revenue' }
                th { text 'Shared' }
              end
            end
            tbody do
              tr do
                td(class: 'revenue') {}
                td(class: 'revenue-shared') {}
              end
            end
          end
        end
      end
    end
    content_for :js do
      coin_type_on_change
      contract_address_on_change
      ethereum_contract_address_on_change
    end
  end

  def percentage_div(form, field_name, **opts)
    opts[:class] = "#{opts[:class]} input-group-field"

    div(class: 'input-group') do
      span(class: 'input-group-label percentage') { text '%' }
      form.text_field field_name, **opts
    end
  end

  def coin_type_options
    Project.coin_types.invert
  end

  def ethereum_network_options
    Project.ethereum_networks.invert
  end

  def blockchain_network_options
    Project.blockchain_networks.invert
  end

  def contract_address_on_change
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        $('body').on('change', "[name='project[contract_address]'], [name='project[blockchain_network]']", function() {
          var network = $("[name='project[blockchain_network]']").val();
          var contract = $("[name='project[contract_address]']").val();
          var symbol = $("[name='project[token_symbol]']").val();
          var decimals = $("[name='project[decimal_places]']").val()
          if(network && network != '' && contract != '' && (!symbol || symbol == '' || !decimals || decimals == '')) {
            getQtumSymbolsAndDecimals(network, contract).then(function(rs) {
              if(rs) {
                if (!symbol || symbol == '') {
                  $("[name='project[token_symbol]']").val(rs[0]);
                }
                if (!decimals || decimals == '') {
                  $("[name='project[decimal_places]']").val(rs[1])
                }
              }
            })
          }
        });
      })
    JAVASCRIPT
  end

  def ethereum_contract_address_on_change
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        $('body').on('change', "[name='project[ethereum_contract_address]'], [name='project[ethereum_network]']", function() {
          var network = $("[name='project[ethereum_network]']").val();
          var contract = $("[name='project[ethereum_contract_address]']").val();
          var symbol = $("[name='project[token_symbol]']").val();
          var decimals = $("[name='project[decimal_places]']").val()
          if(network && network != '' && contract != '' && (!symbol || symbol == '' || !decimals || decimals == '')) {
            var rs = getSymbolsAndDecimals(network, contract)
            if (!symbol || symbol == '') {
              $("[name='project[token_symbol]']").val(rs[0]);
            }
            if (!decimals || decimals == '') {
              $("[name='project[decimal_places]']").val(rs[1])
            }
          }
        });
      })
    JAVASCRIPT
  end

  def coin_type_on_change
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        $('body').on('change', "[name='project[coin_type]']", function() {
          var coinType = $('#project_coin_type option:selected').val()
          customBlockchainNetwork(coinType)
          switch(coinType) {
          case 'erc20':
            $('.contract-info-div').removeClass('hide')
            $(".blockchain-network-lbl").addClass('hide')
            $(".ethereum-network-lbl").removeClass('hide')
            $(".contract-address-lbl").addClass('hide')
            $(".ethereum-contract-address-lbl").removeClass('hide')
            break;
          case 'qrc20':
            $('.contract-info-div').removeClass('hide')
            $(".blockchain-network-lbl").removeClass('hide')
            $(".ethereum-network-lbl").addClass('hide')
            $(".contract-address-lbl").removeClass('hide')
            $(".ethereum-contract-address-lbl").addClass('hide')
            break;
          case 'eth':
            $('.contract-info-div').addClass('hide')
            $(".blockchain-network-lbl").addClass('hide')
            $(".ethereum-network-lbl").removeClass('hide')
            break;
          case 'ada':
            $('.contract-info-div').addClass('hide')
            $(".blockchain-network-lbl").removeClass('hide')
            $(".ethereum-network-lbl").addClass('hide')
            break;
          }
        });
      })
    JAVASCRIPT
  end
end
