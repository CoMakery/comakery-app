class ApplicationMailer < ActionMailer::Base
  before_action :set_whitelabel_mission
  before_action :set_brand_name
  before_action :set_contact_email
  before_action :set_host
  before_action :set_from

  default from: -> { @from }
  layout 'mailer'

  def set_whitelabel_mission
    @whitelabel_mission = params[:whitelabel_mission] if params
  end

  def set_brand_name
    @brand_name = if @whitelabel_mission
      @whitelabel_mission.name
    else
      'CoMakery'
    end
  end

  def set_contact_email
    @contact_email = if @whitelabel_mission
      "community@#{@whitelabel_mission.whitelabel_domain}"
    else
      'community@comakery.com'
    end
  end

  def set_host
    @host = if @whitelabel_mission
      @whitelabel_mission.whitelabel_domain
    else
      ENV['APP_HOST']
    end
  end

  def set_from
    @from = if @whitelabel_mission
      "info@#{@whitelabel_mission.whitelabel_domain}"
    else
      'CoMakery@comakery.com'
    end
  end
end
