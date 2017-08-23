module Views
  module Projects
    class SettingsForm < Views::Base
      needs :project, :slack_channels

      def content
        form_for project do |f|
          div(class: 'content-box') do
            div(class: 'legal-box-header') do
              h3 'Project Settings'
            end
            row do
              column('large-6 small-12') do
                with_errors(project, :title) do
                  label do
                    required_label_text 'Title'
                    f.text_field :title
                  end
                end
                with_errors(project, :slack_channel) do
                  label do
                    i(class: 'fa fa-slack')
                    required_label_text ' Slack Channel '
                    question_tooltip 'Select where project notifications will be sent.'
                    options = capture do
                      options_for_select([[nil, nil]].concat(slack_channels), selected: project.slack_channel)
                    end
                    select_tag 'project[slack_channel]', options, html: { id: 'project_slack_channel' }
                  end
                end
                with_errors(project, :description) do
                  label do
                    required_label_text 'Description'
                    f.text_area :description
                  end
                  link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text float-right')
                end

                with_errors(project, :denomination) do
                  label do
                    text 'Display Currency'
                    question_tooltip 'This is the currency that will be used for display by default. Revenues for revenue sharing will be counted in the currency it was received in.'
                    f.select(:denomination,
                      [['US Dollars ($)', 'USD'],
                       ['Bittoken (฿)', 'BTC'],
                       ['Ether (Ξ)', 'ETH']],
                      { selected: project.denomination, include_blank: false },
                      disabled: project.license_finalized? || project.revenues.any?)
                  end
                end
              end

              column('large-6 small-12') do
                with_errors(project, :tracker) do
                  label do
                    i(class: 'fa fa-tasks')
                    text ' Project Tracker'
                    f.text_field :tracker, placeholder: 'https://trello.com/my-project'
                  end
                end
                with_errors(project, :video_url) do
                  label do
                    i(class: 'fa fa-youtube')
                    text ' Video '
                    question_tooltip 'A video url representing your project. Must be a Youtube url.'
                    f.text_field :video_url, placeholder: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'
                  end
                end
                with_errors(project, :image) do
                  label do
                    text 'Project Image '
                    question_tooltip 'An image that is at least 450 x 400 pixels is recommended.'
                    text f.attachment_field(:image)
                  end
                  text attachment_image_tag(project, :image, class: 'project-image')
                end
              end
            end
          end

          div(class: 'content-box') do
            full_row do
              div(class: 'legal-box-header') do
                h3 'Contribution License Terms'
                i(class: 'fa fa-lock') if project.license_finalized?
              end
            end
            row do
              column('large-6 small-12') do
                with_errors(project, :legal_project_owner) do
                  label do
                    required_label_text "Project Owner's Legal Name "
                    question_tooltip 'The name of the company, association, legal entity, or individual that owns the project and administers awards.'
                    f.text_field :legal_project_owner, disabled: project.license_finalized?
                  end
                end

                with_errors(project, :exclusive_contributions) do
                  label do
                    f.check_box :exclusive_contributions, disabled: project.license_finalized?
                    text 'Contributions are exclusive to this project '
                    question_tooltip 'When contributions are exclusive contributors may not gives others license for their contributions.'
                  end
                end

                with_errors(project, :require_confidentiality) do
                  label do
                    f.check_box :require_confidentiality, disabled: project.license_finalized?
                    text 'Require project and business confidentiality '
                    question_tooltip 'If project requires project confidentiality contributors agree to keep information about this agreement, other contributions to the Project, royalties awarded for other contributions, revenue received, royalties paid to the contributors and others, and all other unpublished information about the business, plans, and customers of the Project secret. Contributors also agree to keep copies of their contributions, copies of other materials contributed to the Project, and information about their content and purpose secret.'
                  end
                end
              end
            end
            br
            full_row do
              div(class: 'legal-box-header') do
                h4 'Contributor Awards'
              end
            end
            row do
              column('large-6 small-12') do
                with_errors(project, :payment_type) do
                  label do
                    required_label_text 'Award Payment Type'
                    question_tooltip 'Project collaborators to your project will receive royalties denominated in a specific currency or direct payments in project tokens for their work contributions.'
                    f.select(:payment_type,
                      [['Revenue Shares', 'revenue_share'],
                       ['Project Tokens', 'project_token']],
                      { selected: project.payment_type, include_blank: false },
                      disabled: project.license_finalized?)
                  end
                end
                with_errors(project, :maximum_tokens) do
                  label do
                    required_label_text 'Total Authorized'
                    award_type_div f, :maximum_tokens, type: 'number', disabled: project.license_finalized? || project.ethereum_enabled?
                  end
                end

                with_errors(project, :maximum_royalties_per_month) do
                  label do
                    required_label_text 'Maximum Awarded Per Month'
                    award_type_div f, :maximum_royalties_per_month,
                      type: :number, placeholder: '25000',
                      disabled: project.license_finalized?
                  end
                end
                div(class: "revenue-sharing-terms #{'hide' if project.project_token?}") do
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

                div do
                  with_errors(project, :revenue_sharing_end_date) do
                    label do
                      text 'Revenue Sharing End Date'
                      f.date_field :revenue_sharing_end_date,
                        disabled: project.license_finalized?
                      div(class: 'help-text') { text '"mm/dd/yyy" means revenue sharing does not end.' }
                    end
                  end
                end

                br
                ethereum_beta(f)

                with_errors(project, :license_finalized) do
                  label do
                    f.check_box :license_finalized, disabled: project.license_finalized?
                    text 'The Contribution License Revenue Sharing Terms Are Finalized'
                    div(class: 'help-text') { text 'Leave this unchecked if you want to use CoMakery for tracking contributions with no legal agreement for sharing revenue.' }
                  end
                end
              end

              column('large-6 small-12') do
                br
                div(class: "revenue-sharing-terms #{'hide' if project.project_token?}") do
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

                div(class: "project-token-terms #{'hide' if project.revenue_share?}") do
                  h5 'About Project Tokens'
                  p do
                    text %(
                        Project Tokens provide open ended and flexible award tracking.
                        They can be used for effort tracking, point systems, blockchain projects, and meta-currencies.
                        Project Token projects don't currently show the CoMakery Contribution License or pricing information.)
                  end
                  p do
                    link_to 'Send us an email', 'mailto:hello@comakery.com'
                    text ' to let us know how you are using them and how we can support you in using them.'
                  end
                end
              end
            end
          end
          div(class: 'content-box') do
            div(class: 'award-types') do
              div(class: 'legal-box-header') do
                h3 'Awards Offered'
              end
              row do
                column('small-3') do
                  text 'Contribution Type'
                end
                column('small-1') do
                  text 'Amount '
                end
                column('small-2') do
                  text 'Community Awardable '
                  question_tooltip 'Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.'
                end
                column('small-4') do
                  text 'Description'
                  br
                  link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text')
                end
                column('small-2') do
                  text 'Remove '
                  question_tooltip 'Award type cannot be changed after awards have been issued.'
                end
              end

              project.award_types.build(amount: 0) if project.award_types.select { |award_type| award_type.amount == 0 }.blank?
              f.fields_for(:award_types) do |ff|
                row(class: "award-type-row#{ff.object.amount == 0 ? ' hide award-type-template' : ''}") do
                  ff.hidden_field :id
                  ff.hidden_field :_destroy, 'data-destroy': ''
                  column('small-3') do
                    ff.text_field :name
                  end
                  column('small-1') do
                    readonly = !ff.object&.modifiable?
                    if readonly
                      tooltip("Award types' amounts can't be modified if there are existing awards", if: readonly) do
                        ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                      end
                    else
                      ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                    end
                  end
                  column('small-2', class: 'text-center') do
                    ff.check_box :community_awardable
                  end
                  column('small-4', class: 'text-center') do
                    ff.text_area :description, class: 'award-type-description'
                  end
                  column('small-2', class: 'text-center') do
                    if ff.object&.modifiable?
                      a('×', href: '#', 'data-mark-and-hide': '.award-type-row', class: 'close')
                    else
                      text "(#{pluralize(ff.object.awards.count, 'award')} sent)"
                    end
                  end
                end
              end
            end
            row(class: 'add-award-type') do
              column do
                p { a('+ add award type', href: '#', 'data-duplicate': '.award-type-template') }
              end
            end
          end

          full_row do
            column do
              with_errors(project, :public) do
                label do
                  f.check_box :public
                  text ' Set project as publicly visible on CoMakery '
                  question_tooltip 'Decide whether or not to display this project in the CoMakery project index'
                end
              end
              f.submit 'Save', class: buttonish(:expand)
            end
          end
        end
      end

      def award_type_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"
        div(class: 'input-group') do
          span(class: 'input-group-label award-type') { text project.currency_denomination }
          form.text_field field_name, **opts
        end
      end

      def percentage_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"

        div(class: 'input-group') do
          span(class: 'input-group-label percentage') { text '%' }
          form.text_field field_name, **opts
        end
      end

      def ethereum_beta(form)
        if current_account.slack_auth.slack_team_ethereum_enabled?
          with_errors(project, :ethereum_enabled) do
            label do
              form.check_box :ethereum_enabled, disabled: project.ethereum_enabled
              text ' Publish to Ethereum Blockchain '
              question_tooltip "WARING: This is irreversible.
                      This will issue blockchain tokens for all existing and
                      future awards for users with ethereum accounts.
                      This information is public with anonymized account names
                      and cannot be revoked."
            end
          end
        else
          label do
            link_to 'Contact us', 'mailto:hello@comakery.com'
            text " if you'd like to join the Ξthereum blockchain beta"
          end
          br
        end
      end
    end
  end
end
