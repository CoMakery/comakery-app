module Views
  module Projects
    class SettingsForm < Views::Base
      needs :project, :providers, :provider_data

      def content
        form_for project do |f|
          div(class: 'content-box', 'data-id': 'general-info') {
            div(class: 'legal-box-header') { h3 'General Info' }
            row {
              column('large-6 small-12') {
                with_errors(project, :title) {
                  label {
                    required_label_text 'Title'
                    f.text_field :title
                  }
                }

                with_errors(project, :description) {
                  label {
                    required_label_text 'Description'
                    f.text_area :description
                  }
                  link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text float-right')
                }

                with_errors(project, :denomination) {
                  label {
                    text 'Display Currency'
                    question_tooltip 'This is the currency that will be used for display by default. Revenues for revenue sharing will be counted in the currency it was received in.'
                    f.select(:denomination,
                      [['US Dollars ($)', 'USD'], ['Bitcoin (฿)', 'BTC'], ['Ether (Ξ)', 'ETH']], { selected: project.denomination, include_blank: false },
                      disabled: project.license_finalized? || project.revenues.any?)
                  }
                }
              }

              column('large-6 small-12') {
                with_errors(project, :tracker) {
                  label {
                    i(class: 'fa fa-tasks')
                    text ' Project Tracker'
                    f.text_field :tracker, placeholder: 'https://trello.com/my-project'
                  }
                }
                with_errors(project, :video_url) {
                  label {
                    i(class: 'fa fa-youtube')
                    text ' Video '
                    question_tooltip 'A video url representing your project. Must be a Youtube url.'
                    f.text_field :video_url, placeholder: 'https://www.youtube.com/watch?v=Dn3ZMhmmzK0'
                  }
                }
                with_errors(project, :image) {
                  label {
                    text 'Project Image '
                    question_tooltip 'An image that is at least 450 x 400 pixels is recommended.'
                    text f.attachment_field(:image)
                  }
                  text attachment_image_tag(project, :image, class: 'project-image')
                }
              }
            }
            render_cancel_and_save_buttons(f)
          }

          render partial: '/projects/form/channel', locals: { f: f, providers: providers }

          div(class: 'content-box', 'data-id': 'contribution-terms') {
            full_row {
              div(class: 'legal-box-header') {
                h3 'Contribution Terms'
                i(class: 'fa fa-lock') if project.license_finalized?
              }
            }
            row {
              column('large-6 small-12') {
                with_errors(project, :legal_project_owner) {
                  label {
                    required_label_text "Project Owner's Legal Name "
                    question_tooltip 'The name of the company, association, legal entity, or individual that owns the project and administers awards.'
                    f.text_field :legal_project_owner, disabled: project.license_finalized?
                  }
                }

                with_errors(project, :exclusive_contributions) {
                  label {
                    f.check_box :exclusive_contributions, disabled: project.license_finalized?
                    text 'Contributions are exclusive to this project '
                    question_tooltip 'When contributions are exclusive contributors may not gives others license for their contributions.'
                  }
                }

                with_errors(project, :require_confidentiality) {
                  label {
                    f.check_box :require_confidentiality, disabled: project.license_finalized?
                    text 'Require project and business confidentiality '
                    question_tooltip 'If project requires project confidentiality contributors agree to keep information about this agreement, other contributions to the Project, royalties awarded for other contributions, revenue received, royalties paid to the contributors and others, and all other unpublished information about the business, plans, and customers of the Project secret. Contributors also agree to keep copies of their contributions, copies of other materials contributed to the Project, and information about their content and purpose secret.'
                  }
                }
              }
            }
            br
            full_row {
              div(class: 'legal-box-header') { h4 'Contributor Awards' }
            }
            row {
              column('large-6 small-12') {
                with_errors(project, :ethereum_contract_address) {
                  label {
                    text 'Ethereum Contract Address'
                    f.text_field :ethereum_contract_address, placeholder: '0x583cbBb8a8443B38aBcC0c956beCe47340ea1367'
                  }
                }

                with_errors(project, :maximum_tokens) {
                  label {
                    required_label_text 'Total Token Budget'
                    award_type_div f, :maximum_tokens, type: 'number', disabled: project.license_finalized? || project.ethereum_enabled?
                  }
                }

                with_errors(project, :maximum_royalties_per_month) {
                  label {
                    required_label_text 'Maximum Awarded Per Month'
                    award_type_div f, :maximum_royalties_per_month,
                      type: :number, placeholder: '25000',
                      disabled: project.license_finalized?
                  }
                }
                div(class: "revenue-sharing-terms #{'hide' if project.project_token?}") {
                  with_errors(project, :royalty_percentage) {
                    label {
                      required_label_text 'Revenue Shared With Contributors'
                      question_tooltip "The Project Owner agrees to count money customers pay either to license, or to use a hosted instance of, the Project as 'Revenue'. Money customers pay for consulting, training, custom development, support, and other services related to the Project does not count as Revenue."
                      # percentage_div { f.text_field :royalty_percentage, placeholder: "5%", class: 'input-group-field' }
                      percentage_div f, :royalty_percentage, placeholder: '10',
                                                             disabled: project.license_finalized?
                    }
                  }
                }

                div {
                  with_errors(project, :revenue_sharing_end_date) {
                    label {
                      text 'Revenue Sharing End Date'
                      f.text_field :revenue_sharing_end_date, class: 'datepicker-no-limit', placeholder: 'mm/dd/yyyy', value: f.object.revenue_sharing_end_date&.strftime('%m/%d/%Y'), disabled: project.license_finalized?
                      div(class: 'help-text') { text '"mm/dd/yyy" means revenue sharing does not end.' }
                    }
                  }
                }
                with_errors(project, :token_symbol) {
                  label {
                    text 'Token Symbol'
                    f.text_field :token_symbol
                  }
                }

                # # Uncomment this after legal review  of licenses, disclaimers, etc.
                # with_errors(project, :license_finalized) {
                #   label {
                #     f.check_box :license_finalized, disabled: project.license_finalized?
                #     text 'The Contribution License Revenue Sharing Terms Are Finalized'
                #     div(class: 'help-text') { text "Leave this unchecked if you want to use #{I18n.t('project_name')} for tracking contributions with no legal agreement for sharing revenue." }
                #   }
                # }
              }

              column('large-6 small-12') {
                br
                div(class: "revenue-sharing-terms #{'hide' if project.project_token?}") {
                  h5 'Example'
                  table(class: 'royalty-calc') {
                    thead {
                      tr {
                        th { text 'Revenue' }
                        th { text 'Shared' }
                      }
                    }
                    tbody {
                      tr {
                        td(class: 'revenue') {}
                        td(class: 'revenue-shared') {}
                      }
                    }
                  }
                }
              }
            }
            render_cancel_and_save_buttons(f)
          }
          div(class: 'content-box', 'data-id': 'awards-offered') {
            div(class: 'award-types') {
              div(class: 'legal-box-header') { h3 'Awards Offered' }
              row {
                column('small-3') { text 'Contribution Type' }
                column('small-1') { text 'Amount ' }
                column('small-1') {
                  text 'Community Awardable '
                  question_tooltip 'Check this box if you want people on your team to be able to award others. Otherwise only the project owner can send awards.'
                }
                column('small-4 lb-description') {
                  text 'Description'
                  br
                  link_to('Styling with Markdown is Supported', 'https://guides.github.com/features/mastering-markdown/', class: 'help-text')
                }
                column('small-1') { text 'Disable' }
                column('small-2', class: 'text-center') {
                  text 'Remove '
                  question_tooltip 'Award type cannot be changed after awards have been issued.'
                }
              }

              project.award_types.build(amount: 0) if project.award_types.select { |award_type| award_type.amount == 0 }.blank?
              f.fields_for(:award_types) do |ff|
                row(class: "award-type-row#{ff.object.amount == 0 ? ' hide award-type-template' : ''}") {
                  ff.hidden_field :id
                  ff.hidden_field :_destroy, 'data-destroy': ''
                  column('small-3') { ff.text_field :name }
                  column('small-1 award-amount') {
                    readonly = !ff.object&.modifiable?
                    if readonly
                      tooltip("Award types' amounts can't be modified if there are existing awards", if: readonly) do
                        ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                      end
                    else
                      ff.text_field :amount, type: :number, class: 'text-right', readonly: readonly
                    end
                  }
                  column('small-1', class: 'text-center') { ff.check_box :community_awardable }
                  column('small-4', class: 'text-center lb-description') { ff.text_area :description, class: 'award-type-description' }
                  column('small-1', class: 'text-center') { ff.check_box :disabled }
                  column('small-2', class: 'text-center') {
                    if ff.object&.modifiable?
                      a('×', href: '#', 'data-mark-and-hide': '.award-type-row', class: 'close')
                    else
                      text "(#{pluralize(ff.object.awards.count, 'award')} sent)"
                    end
                  }
                }
              end
            }
            row(class: 'add-award-type') {
              column {
                p { a('+ add award type', href: '#', 'data-duplicate': '.award-type-template') }
              }
            }
            render_cancel_and_save_buttons(f)
          }
          div(class: 'content-box', 'data-id': 'visibility') {
            div(class: 'award-types') {
              div(class: 'legal-box-header') { h3 'Visibility' }
              row {
                column('small-5') {
                  options = capture do
                    options_for_select(visibility_options, selected: f.object.visibility)
                  end
                  label {
                    text 'Project Visible To'
                    f.select :visibility, options
                  }
                }
              }
              row {
                label(style: 'margin-left: 15px;') {
                  text 'Project URL'
                }
                column('small-5') {
                  text_field_tag :unlisted_url, unlisted_project_url(f.object.long_id), name: nil, class: 'copy-source'
                  hidden_field_tag :long_id, f.object.long_id
                }
                column('small-1', style: 'padding-left: 0; margin-left: -16px; margin-top: 8px') {
                  a(class: 'copiable', style: 'padding: 9px; border: 1px solid #ccc;') {
                    image_tag 'Octicons-clippy.png', size: '20x20'
                  }
                }
                column('small-1') {}
              }
            }
          }

          full_row {
            f.submit 'Save', class: buttonish(:expand, :last_submit)
          }
        end
      end

      def award_type_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"
        div(class: 'input-group') {
          span(class: 'input-group-label award-type') { text project.currency_denomination }
          form.text_field field_name, **opts
        }
      end

      def percentage_div(form, field_name, **opts)
        opts[:class] = "#{opts[:class]} input-group-field"

        div(class: 'input-group') {
          span(class: 'input-group-label percentage') { text '%' }
          form.text_field field_name, **opts
        }
      end

      def visibility_options
        [['Logged in team members', 'member'], ['Publicly listed in CoMakery searches', 'public_listed'], ['Logged in team member via unlisted url', 'member_unlisted'], ['Unlisted url (no login required)', 'public_unlisted'], ['Archived (visible to me only)', 'archived']]
      end

      def render_cancel_and_save_buttons(form)
        full_row_right {
          link_to 'Cancel', project, class: 'button cancel'
          form.submit 'Save', class: buttonish(:expand)
        }
      end
    end
  end
end
