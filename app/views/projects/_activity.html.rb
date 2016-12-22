class Views::Projects::Activity < Views::Base
  needs :project, :award_data

  def content
    div(class: 'content-box') {
      row(class: "awarded-info-header") {
        h3 "Project Activity"
      }
      row {
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

          if award_data[:contributions].present?
            p {
              div(id: "contributions-chart")
            }
            content_for :js do
              make_charts
            end
          end
        }
      }
    }
  end


  def make_charts
    text(<<-JAVASCRIPT.html_safe)
      $(function() {
        window.stackedBarChart("#contributions-chart", #{award_data[:contributions_by_day].to_json});
      });
    JAVASCRIPT
  end

  def total_coins_issued
    award_data[:award_amounts][:total_coins_issued]
  end

  def percentage_issued
    total_coins_issued * 100 / project.maximum_coins.to_f
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
end