class Views::Projects::Show < Views::Projects::Base
  needs :project, :award, :awardable_authentications, :awardable_types, :award_data, :can_award

  def content
    content_for(:title) { project.title.strip }
    content_for(:description) { project.description_text(150) }

    if award_data[:contributions].present?
      content_for :js do
        make_charts
      end
    end

    div(class: "project-head") {
      div {
        row(class: "project-title") {
          column("small-12") {
            h2 project.title
          }
        }
        row {
          column("large-6 small-12") {
            if project.video_url
              div(class: "project-video") {
                div(class: "flex-video widescreen") {
                  iframe(width: "454", height: "304", src: "//www.youtube.com/embed/#{project.youtube_id}?modestbranding=1&iv_load_policy=3&rel=0&showinfo=0&color=white&autohide=0", frameborder: "0")
                }
              }
            else
              div {
                div(class: "content") {
                  img(src: project_image(project), class: "project-image")
                }
              }
            end
            p(class: 'centered') {
              text "Lead by "
              b "#{project.owner_slack_user_name}"
              text " with "
              strong project.slack_team_name
            }
          }
          column("large-6 small-12 header-graphic") {
            div(class: 'content-box') {

              row(class: "project-tasks") {
                if policy(project).edit?
                  div {
                    a(class: "edit", href: edit_project_path(project)) {
                      i(class: "fa fa-pencil") {}
                      text " Edit Project"
                    }
                  }
                end
                if project.slack_team_domain
                  div {
                    a(href: "https://#{project.slack_team_domain}.slack.com/messages/#{project.slack_channel}", target: "_blank", class: "text-link") {
                      i(class: "fa fa-slack")
                      text " Slack Channel"
                    }
                  }
                end
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
              full_row {
                p(class: "description") {
                  text raw project.description_html
                }
              }
            }
          }

        }
      }
    }

    div(class: "project-body") {

      row {
        column("large-6 medium-12") {

          div(id: "award-send", class: "content-box") {
            render partial: "award_send"
          }
        }
        column("large-6 medium-12") {
          div(class: 'content-box') {
            row(class: "awarded-info-header") {
              h3 "Project Activity"
              div(class: "float-right") {
                a(href: project_awards_path(project), class: "text-link coin-numbers") {
                  i(class: "fa fa-history")
                  text " History"
                }
              }
            }
            row { awarded_info }

            row { top_contributors }
          }
        }
      }
    }
  end

  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.pieChart("#award-percentages", {"content": #{pie_chart_data}});
        window.stackedBarChart("#contributions-chart", #{award_data[:contributions_by_day].to_json});
      });
    JAVASCRIPT
  end

  def pie_chart_data
    award_data[:contributions_summary_pie_chart].map do |award|
      {label: award[:name], value: award[:net_amount]}
    end.to_json
  end

  def total_coins_issued
    award_data[:award_amounts][:total_coins_issued]
  end

  def percentage_issued
    total_coins_issued * 100 / project.maximum_coins.to_f
  end

  def awarded_info
    ul(class: 'menu simple awarded-info') {
      li {
        span(class: " coin-numbers") {
          text project.currency_denomination
          text number_with_precision(total_coins_issued, precision: 0, delimiter: ',')
        }
        if percentage_issued >= 0.01
          text " (#{number_with_precision(percentage_issued, precision: 2)}%)"
        end

        text raw "&nbsp;awarded"
      }


      if award_data[:award_amounts][:my_project_coins]
        li {
          span(class: "coin-numbers") {
            text project.currency_denomination
            text number_with_precision(award_data[:award_amounts][:my_project_coins], precision: 0, delimiter: ',')
          }
          text raw "&nbsp;mine"
        }
      end
    }

    if award_data[:contributions].present?
      p {
        div(id: "contributions-chart")
      }
      p {
        h4 "#{project.payment_description} Earned "
        div(id: "award-percentages", class: "royalty-pie") {}
      }
    end
  end

  def royalty_payment
    p {
      if can_award
        form(method: "POST") {
          script(
              "src" => "https://checkout.stripe.com/checkout.js",
              "class" => 'stripe-button',
              "data-key" => "pk_test_DuBJXYk5G6VvuuLT5fYsSbBj",
              "data-label" => "Pay #{project.payment_description}",
              "data-panel-label" => "Pay #{project.payment_description}",
              "data-amount" => total_coins_issued * 60,
              "data-name" => project.title,
              "data-description" => "Pay #{project.payment_description}",
              # "data-image" => project_image(project),
              "data-locale" => "auto",
              "data-zip-code" => true,
              "data-bitcoin" => true
          )
        }
      end
    }
  end

  def top_contributors
    if award_data[:contributions_summary].present?
      div(class: "table-scroll") {
        table(class: "award-rows", style: "width: 100%") {
          tr(class: "header-row") {
            th "Top Contributors"
            th(class: "text-align-right") { text "Earned" }
            th(class: "text-align-right") { text "Paid" }
            th(class: "text-align-right") { text "Remaining" }
          }
          award_data[:contributions_summary].each do |contributor|
            tr(class: "award-row") {
              td(class: "contributor") {
                img(src: contributor[:avatar], class: "icon avatar-img")
                div(class: "margin-small margin-collapse inline-block") { text contributor[:name] }
              }
              td(class: "earned") {
                span(class: "float-right margin-small") {
                  text project.currency_denomination
                  text number_with_precision(contributor[:earned], precision: 0, delimiter: ',')
                }
              }
              td(class: "paid") {
                span(class: "float-right margin-small") {
                  text project.currency_denomination
                  text number_with_precision(contributor[:paid], precision: 0, delimiter: ',')
                }
              }
              td(class: "remaining") {
                span(class: "float-right margin-small") {
                  text project.currency_denomination
                  text number_with_precision(contributor[:remaining], precision: 0, delimiter: ',')
                }
              }
            }
          end
        }
      }
    end
  end
end
