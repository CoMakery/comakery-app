require 'metrics'

class Views::Admin::Metrics::Index < Views::Base
  def content
    full_row do
      h1('Metrics')

      h4('Empathy')
      h4("I've figured out how to solve a problem in a way my target market will adopt and pay for.", class: 'subheader')

      p('One measure of empathy is whether new users are signing up for the site.')

      figure do
        figcaption('Sign-ups per day')
        table(role: 'grid') do
          thead do
            tr do
              th('Signed up', colspan: '2')
              th('Users', colspan: '2')
            end
          end

          render partial: 'daily_count_rows', locals: { metrics: ::Metrics.signups_per_day }
        end
      end

      figure do
        figcaption('Sign-ups per week')
        table(role: 'grid') do
          thead do
            tr do
              th('Signed up', colspan: '2')
              th('Users', colspan: '2')
            end
          end

          render partial: 'daily_count_rows', locals: { metrics: ::Metrics.signups_per_week }
        end
      end

      h4('Stickiness')
      h4("I've built the right features that keep users around.", class: 'subheader')

      p("One measure of stickiness is how often users come back to the site. We don't have that information, but we know when they were last active on the site.")

      figure do
        figcaption('Churn per day')
        table(role: 'grid') do
          thead do
            tr do
              th('Last Active', colspan: '2')
              th('Users', colspan: '2')
            end
          end

          render partial: 'daily_count_rows', locals: { metrics: ::Metrics.churn_per_day }
        end
      end

      figure do
        figcaption('Churn per week')
        table(role: 'grid') do
          thead do
            tr do
              th('Last Active', colspan: '2')
              th('Users', colspan: '2')
            end
          end

          render partial: 'daily_count_rows', locals: { metrics: ::Metrics.churn_per_week }

          tr do
            td('Lapsed', colspan: '2')
            td(::Metrics.lapsed[:count], class: 'text-right')
            td
          end
        end
      end
    end
  end
end
