class PagesController < ApplicationController
  skip_before_action :require_login, except: %i[featured home]
  skip_before_action :require_email_confirmation, only: %i[featured home landing add_interest]
  skip_after_action :verify_authorized

  layout 'react', only: %i[styleguide featured]

  def landing
    if current_account
      if current_account.finished_contributor_form?
        redirect_to action: :featured
      else
        @paperform_id = case ENV['APP_NAME']
                        when 'demo'
                          'demo-homepage'
                        when 'staging'
                          '0f2g0j1q'
                        else
                          'homepage'
        end
        render :home
      end
    end
  end

  def home; end

  def featured
    unless current_account.finished_contributor_form?
      current_account.update(contributor_form: true)
    end
    unless current_account.confirmed?
      flash[:alert] = 'Please confirm your email before continuing.'
    end

    top_missions = Mission.active.first(4)
    more_missions = Mission.active.offset(4)

    render component: 'FeaturedMissions', props: {
      csrf_token: form_authenticity_token,
      top_missions: top_missions.map { |mission| featured_mission_props(mission) },
      more_missions: more_missions.map { |mission| more_mission_props(mission) }
    }
  end

  def add_interest
    @interest = current_user.interests.new
    @interest.project_id = params[:project_id]
    @interest.protocol = params[:protocol] # mission name
    @interest.save
    respond_to do |format|
      format.json { render json: @interest.to_json }
    end
  end

  def styleguide
    return redirect_to :root unless Rails.env == 'development'
    render component: 'styleguide/Index'
  end

  private

  def featured_mission_props(mission)
    mission.as_json(only: %i[id name description]).merge(
      image_url: mission.image.present? ? Refile.attachment_url(mission, :image, :fill, 312, 312) : nil,
      symbol: mission.token&.symbol,
      projects: mission.projects.map do |project|
        project.as_json(only: %i[id title]).merge(
          interested: current_account.interested?(project.id)
        )
      end
    )
  end

  def more_mission_props(mission)
    mission.as_json(only: %i[id name]).merge(
      image_url: mission.image.present? ? Refile.attachment_url(mission, :image, :fill, 231, 231) : nil,
      symbol: mission.token&.symbol,
      projects_count: mission.projects.count
    )
  end
end
