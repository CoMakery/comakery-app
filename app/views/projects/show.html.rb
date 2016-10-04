class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :award_data, :can_award

  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.pieChart("#award-percentages", {"content": #{pie_chart_data}});
        window.stackedBarChart("#contributions-chart", #{award_data[:contributions_by_day].to_json});
      });
    JAVASCRIPT
  end

  def pie_chart_data
    award_data[:contributions_summary].map do |award|
      {label: award[:name], value: award[:net_amount]}
    end.to_json
  end

  def content
    content_for(:title) { project.title.strip }
    content_for(:description) { project.description_text(150) }

    if award_data[:contributions].present?
      content_for :js do
        make_charts
      end
    end

    content_for(:pre_body) {
      div(class: "project-head") {
        div(class: "small-12 medium-11 large-10 small-centered columns") {
          row(class: "project-title") {
            column("small-12") {
              h1 project.title
              p {
                text "by "
                strong project.slack_team_name
                if policy(project).edit?
                  a(class: "edit", href: edit_project_path(project)) {
                    i(class: "fa fa-pencil") {}
                    text " Edit Project"
                  }
                end
              }
            }
          }
          row {
            column("medium-5 small-12") {
              if project.video_url
                div(class: "project-video") {
                  div(class: "flex-video widescreen") {
                    iframe(width: "454", height: "304", src: "//www.youtube.com/embed/#{project.youtube_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: "0")
                  }
                }
              else
                div(class: "sixteen-nine") {
                  div(class: "content") {
                    img(src: project_image(project), class: "project-image")
                  }
                }
              end
            }
            column("medium-7 small-12") {
              full_row {
                p(class: "description") {
                  text raw project.description_html
                }
              }
              row(class: "project-settings") {
                column("medium-5 small-12") {
                  text "Owner: "
                  b "#{project.owner_slack_user_name}"
                }
                column("medium-7 small-12") {
                  text "Visibility: "
                  b "#{project.public? ? "Public" : "Private"}"
                }
              }
              row(class: "project-tasks") {
                column("medium-5 small-12") {
                  if project.tracker
                    div {
                      a(href: project.tracker, target: "_blank", class: "text-link") {
                        i(class: "fa fa-tasks")
                        text " Project Tasks"
                      }
                    }
                  end

                  if project.contributor_agreement_url
                    div {
                      a(href: project.contributor_agreement_url, target: "_blank", class: "text-link") {
                        i(class: "fa fa-gavel")
                        text " Contributor Agreement"
                      }
                    }
                  end

                  if project.ethereum_contract_explorer_url
                    div {
                      link_to "Ξthereum Smart Contract", project.ethereum_contract_explorer_url,
                        target: "_blank", class: "text-link"
                    }
                  end
                }

                column("medium-7 small-12") {
                  if project.slack_team_domain
                    div {
                      a(href: "https://#{project.slack_team_domain}.slack.com/messages/#{project.slack_channel}", target: "_blank", class: "text-link") {
                        i(class: "fa fa-slack")
                        text " Project Slack Channel"
                      }
                    }
                  end
                  if project.video_url
                    div {
                      a(href: project.video_url, target: "_blank", class: "text-link") {
                        i(class: "fa fa-youtube")
                        text " Video"
                      }
                    }
                  end
                }
              }
            }
          }
        }
      }
    }

    row(class: "project-body") {
      column("large-5 small-12") {
        div(class:"award-send") {
          render partial: "award_send"
        }
      }

      column("large-7 small-12 contributors-column") {
        row {
          column("small-12", class: "underlined-header") {
            text "Royalties "
            question_tooltip("This shows project coins issued on CoMakery. It does not currently show secondary trading on the Ethereum blockchain.")
          }
        }

        row {
          column("small-12 medium-4", class: "coins-issued") {
            total_coins_issued = award_data[:award_amounts][:total_coins_issued]
            div(class: "") {
              div {

                span(class: " coin-numbers") {
                  text currency_unit
                  text number_with_precision(project.maximum_coins, precision: 0, delimiter: ',')
                }
                text raw "&nbsp;max"
              }

              div {
                span(class: " coin-numbers") {
                  text currency_unit
                  text number_with_precision(total_coins_issued, precision: 0, delimiter: ',')
                }

                text raw "&nbsp;total"
              }

              percentage_issued = total_coins_issued * 100 / project.maximum_coins.to_f
              if percentage_issued >= 0.01
                text " (#{number_with_precision(percentage_issued, precision: 2)}%)"
              end

              if award_data[:award_amounts][:my_project_coins]
                div {
                  span(class: "coin-numbers") {
                    text currency_unit
                    text number_with_precision(award_data[:award_amounts][:my_project_coins], precision: 0, delimiter: ',')
                  }
                  text raw "&nbsp;mine"
                }
              end
            }

            p(class: " font-small") {
              a(href: project_awards_path(project), class: "text-link") {
                i(class: "fa fa-history")
                text " History"
              }
            }

            # STRIPE CHECKOUT DEMO:
            form(method: "GET") {
              script(
                "src" => "https://checkout.stripe.com/checkout.js",
                "class" => 'stripe-button',
                "data-key" => "pk_test_DuBJXYk5G6VvuuLT5fYsSbBj",
                "data-label" => "Pay Royalties",
                "data-panel-label" => "Pay Royalties",
                "data-amount" => total_coins_issued * 60,
                "data-name" => project.title,
                "data-description" => "Pay Royalties",
                "data-image" => project_image(project),
                "data-locale" => "auto",
                "data-zip-code" => true,
                "data-bitcoin" => true
              )
            }

          }
          column("medium-8 small-12", class: "centered") {
            div(id: "award-percentages") {}
          }
        }

        if award_data[:contributions].present?
          row { column("small-12", class: "underlined-header") { text "Recent Activity" } }

          full_row {
            div(id: "contributions-chart")
          }
        end
      }
    }

    br
    row {
      div(class: "table-scroll") {
        table(class: "award-rows", style: "width: 100%") {
          tr(class: "header-row") {
            th "Top Contributors"
            th(class: "text-align-right") { text "Earned" }
            th(class: "text-align-right") { text "Paid" }
            th(class: "text-align-right") { text "Remaining" }
          }
          award_data[:contributions].each do |contributor|
            tr(class: "award-row") {
              td {
                img(src: contributor[:avatar], class: "icon avatar-img")
                div(class: "margin-small margin-collapse inline-block") { text contributor[:name] }
              }
              td {
                span(class: "float-right margin-small") {
                  text currency_unit
                  text number_with_precision(contributor[:net_amount], precision: 0, delimiter: ',')
                }
              }
              td {
                span(class: "float-right margin-small") {
                  text currency_unit
                  text number_with_precision(contributor[:net_amount] * 0.6, precision: 0, delimiter: ',')
                }
              }
              td {
                span(class: "float-right margin-small") {
                  text currency_unit
                  text number_with_precision(contributor[:net_amount] * 0.4, precision: 0, delimiter: ',')
                }
              }
            }
          end
        }
      }


    }
  end
end
