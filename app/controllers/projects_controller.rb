class ProjectsController < ApplicationController
  skip_before_action :require_login, except: %i[new edit create update update_status landing]
  skip_after_action :verify_authorized, only: %i[landing]

  before_action :assign_current_account
  before_action :assign_project, only: %i[edit show update]
  before_action :assign_project_by_long_id, only: %i[unlisted]
  before_action :redirect_for_whitelabel, only: %i[show unlisted]
  before_action :set_projects, only: %i[index]
  before_action :set_award, only: %i[show unlisted]
  before_action :set_tokens, only: %i[new edit]
  before_action :set_missions, only: %i[new edit]
  before_action :set_visibilities, only: %i[new edit]
  before_action :set_teams, only: %i[new edit]
  before_action :set_generic_props, only: %i[new edit]
  before_action :set_show_props, only: %i[show unlisted]

  layout 'legacy', except: %i[show unlisted new edit]

  def landing
    if current_account
      @my_projects = current_account.my_projects(@project_scope).with_all_attached_images.includes(:account, :project_admins).unarchived.order(updated_at: :desc).limit(100).decorate
      @team_projects = current_account.other_member_projects(@project_scope).with_all_attached_images.includes(:account, :project_admins).unarchived.order(updated_at: :desc).limit(100).decorate
      @archived_projects = @whitelabel_mission ? [] : current_account.projects.with_all_attached_images.includes(:account, :project_admins).archived.order(updated_at: :desc).limit(100).decorate
      @involved_projects = current_account.projects_involved.with_all_attached_images.includes(:account, :project_admins).where.not(id: @my_projects.pluck(:id)).unarchived.order(updated_at: :desc).limit(100).decorate
    end

    @my_project_contributors = TopContributors.call(projects: @my_projects).contributors
    @team_project_contributors = TopContributors.call(projects: @team_projects).contributors
    @involved_project_contributors = TopContributors.call(projects: @involved_projects).contributors
    @archived_project_contributors = TopContributors.call(projects: @archived_projects).contributors
  end

  def index
    @project_contributors = TopContributors.call(projects: @projects).contributors

    @meta_title = 'CoMakery Projects - Work at the Cutting Edge'

    @meta_desc = 'Projects from around the world are looking to achieve great things, often leveraging the blockchain ' \
                 'to do so. At CoMakery, you can search and find projects to work on and earn tokens or USDC, or even ' \
                 'start your own project.'

    @meta_image = '/comakery-projects.jpg'
  end

  def new
    @project = current_account.projects.build
    @project.channels.build if current_account.teams.any?
    @project.long_id ||= SecureRandom.hex(20)

    authorize @project

    @props[:project] = @project.serializable_hash.merge(
      {
        url: "https://#{current_domain}/p/#{@project.long_id}",
        mission_id: params[:mission_id] ? Mission.find(params[:mission_id])&.id : nil
      }.as_json
    )
  end

  def create
    @project = current_account.projects.build project_params
    @project.public = false
    @project.long_id ||= SecureRandom.hex(20)

    @project.mission = @whitelabel_mission if @whitelabel_mission

    authorize @project

    if @project.save
      set_generic_props
      camelize_props
      render json: { id: @project.id, props: @props }, status: :ok
    else
      errors  = @project.errors.messages.map { |k, v| ["project[#{k}]", v.to_sentence] }.to_h
      message = @project.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  def show
    authorize @project

    @meta_title = 'CoMakery Project'
    @meta_desc = "#{@project.title}: #{Comakery::Markdown.to_text(@project.description)}"
    @meta_image = Attachment::GetPath.call(attachment: @project.square_image).path
  end

  def unlisted
    authorize @project
  end

  def edit
    @project.channels.build if current_account.teams.any?
    @project.long_id ||= SecureRandom.hex(20)
    authorize @project

    @props[:form_action] = 'PATCH'
    @props[:form_url]    = project_path(@project)
  end

  def update
    @project.long_id ||= params[:long_id] || SecureRandom.hex(20)
    authorize @project

    if @project.update(project_params)
      set_generic_props
      camelize_props
      render json: { message: 'Project updated', id: @project.id, props: @props }, status: :ok
    else
      errors  = @project.errors.messages.map { |k, v| [k, v.to_sentence] }.to_s
      message = @project.errors.full_messages.join(', ')
      render json: { message: message, errors: errors }, status: :unprocessable_entity
    end
  end

  def update_status
    @project = @project_scope.find_by(id: params[:project_id])
    authorize @project

    begin
      @project.update(status: params[:status])
      render json: { message: 'Successfully updated.' }, status: :ok
    rescue ArgumentError
      render json: { message: 'Invalid Status' }, status: :unprocessable_entity
    end
  end

  private

    def assign_project_by_long_id
      @project = @project_scope.includes(account: [image_attachment: :blob]).find_by(long_id: params[:long_id])&.decorate

      return redirect_to('/404.html') unless @project
      return redirect_to(project_path(@project)) unless @project.unlisted?
    end

    def set_projects
      @page = (params[:page] || 1).to_i

      @q = policy_scope(@project_scope).ransack(params[:q])
      @q.sorts = 'project_roles_count DESC' if @q.sorts.empty?

      @projects_all = @q.result.with_all_attached_images.includes(:token, :mission, :project_admins, account: [image_attachment: :blob])
      @projects = @projects_all.page(@page).per(9)

      redirect_to '/404.html' if (@page > 1) && @projects.out_of_range?
    end

    def set_tokens
      @tokens = Token.listed.or(Token.where(id: @project&.token&.id)).pluck(:name, :id).append(['No Token', '']).reverse.to_h
    end

    def set_missions
      @missions = Mission.all.pluck(:name, :id).append(['No Mission', '']).reverse.to_h
    end

    def set_visibilities
      @visibilities = Project.visibilities.keys
    end

    def set_teams # rubocop:todo Metrics/CyclomaticComplexity
      @teams = current_account&.authentication_teams&.includes(:team, :authentication)&.map do |a_team|
        {
          team: "[#{a_team.team.provider}] #{a_team.team.name}",
          team_id: a_team.team.id.to_s,
          discord: a_team.team.discord?,
          channels: a_team.channels&.map do |channel|
            {
              channel: a_team.team.discord? ? channel.first.to_s : channel,
              channel_id: a_team.team.discord? ? channel.second.to_s : channel
            }
          end
        }
      end
    end

    # rubocop:todo Metrics/PerceivedComplexity
    def set_generic_props # rubocop:todo Metrics/CyclomaticComplexity
      @props = {
        project: @project&.serializable_hash&.merge(
          {
            square_image_url: GetImageVariantPath.call(attachment: @project&.square_image, resize_to_fill: [1200, 800]).path,
            panoramic_image_url: GetImageVariantPath.call(attachment: @project&.panoramic_image, resize_to_fill: [1500, 300]).path,
            mission_id: @project&.mission&.id,
            token_id: @project&.token&.id,
            channels: @project&.channels&.includes(:team)&.map do |channel|
              {
                channel_id: channel&.channel_id&.to_s,
                team_id: channel&.team&.id&.to_s,
                id: channel&.id,
                name_with_provider: channel&.name_with_provider
              }
            end,
            github_url: @project.github_url,
            documentation_url: @project.documentation_url,
            getting_started_url: @project.getting_started_url,
            governance_url: @project.governance_url,
            funding_url: @project.funding_url,
            video_conference_url: @project.video_conference_url,
            url: unlisted_project_url(@project.long_id)
          }.as_json
        ),
        tokens: @tokens,
        decimal_places: Token.select(:id, :decimal_places),
        missions: @missions,
        visibilities: @visibilities,
        teams: @teams&.reject { |t| t[:channels].blank? },
        discord_bot_url: (Comakery::Discord.new.add_bot_link if @teams&.any? { |t| t[:discord] && t[:channels].empty? }),
        license_url: contribution_licenses_path(type: 'CP'),
        terms_readonly: @project&.terms_readonly?,
        form_url: projects_path,
        form_action: 'POST',
        csrf_token: form_authenticity_token,
        project_for_header: project_header,
        mission_for_header: @project&.mission&.decorate&.header_props,
        is_whitelabel: @whitelabel_mission.present?,
        discord_enabled: Comakery::Discord.enabled?,
        slack_enabled: Comakery::Slack.enabled?
      }
    end
    # rubocop:enable Metrics/PerceivedComplexity

    def project_header
      if @project
        @project.decorate.header_props(current_user)
      else
        { image_url: helpers.image_url('default_project.jpg') }
      end
    end

    def project_tasks_by_specialty
      @project.ready_tasks_by_specialty.map do |specialty, awards|
        [
          specialty&.name&.downcase || 'general',
          awards.map do |task|
            task_to_props(task).merge(
              allowed_to_start: policy(task).start?,
              reached_maximum_assignments: task.reached_maximum_assignments_for?(current_account)
            )
          end
        ]
      end
    end

    def set_show_props # rubocop:todo Metrics/CyclomaticComplexity
      @props = {
        whitelabel: ENV['WHITELABEL'] || false,
        tasks_by_specialty: project_tasks_by_specialty,
        follower: current_account&.involved?(@project.id),
        project_data: project_props(@project),
        token_data: token_props(@project&.token&.decorate),
        csrf_token: form_authenticity_token,
        my_tasks_path: my_tasks_path(project_id: @project.id),
        editable: policy(@project).edit?,
        project_for_header: @project.decorate.header_props(current_account),
        mission_for_header: @whitelabel_mission ? nil : @project&.mission&.decorate&.header_props
      }
    end

    def camelize_props
      @props.deep_transform_keys! { |key| key.to_s.camelize(:lower) }
    end

    def project_params
      result = params.require(:project).permit(
        :contributor_agreement_url,
        :description,
        :square_image,
        :panoramic_image,
        :maximum_tokens,
        :token_id,
        :mission_id,
        :long_id,
        :title,
        :tracker,
        :video_url,
        :github_url,
        :documentation_url,
        :getting_started_url,
        :governance_url,
        :funding_url,
        :video_conference_url,
        :payment_type,
        :exclusive_contributions,
        :legal_project_owner,
        :minimum_payment,
        :require_confidentiality,
        :confidentiality,
        :license_finalized,
        :visibility,
        :status,
        :display_team,
        :hot_wallet_mode,
        :transfer_batch_size,
        channels_attributes: %i[
          _destroy
          id
          team_id
          channel_id
        ]
      )
      result
    end

    def assign_current_account
      @current_account_deco = current_account&.decorate
    end

    def set_award
      last_award = @project.awards&.completed&.last
      @award = Award.new channel: last_award&.channel, award_type: last_award&.award_type
      awardable_types_result = GetAwardableTypes.call(account: current_account, project: @project)
      @awardable_types = awardable_types_result.awardable_types
      @can_award = awardable_types_result.can_award
    end

    def contributor_props(account, project)
      a = account.decorate.serializable_hash(
        only: %i[id nickname first_name last_name linkedin_url github_url dribble_url behance_url],
        include: :specialty,
        methods: :image_url
      )

      a['specialty'] ||= {}

      if project.account == account || project.project_admins.include?(account)
        a['specialty']['name'] = 'Team Leader'
      elsif !project.contributors_distinct.include?(account)
        a['specialty']['name'] = 'Interested'
      end

      a
    end

    def project_props(project)
      project.as_json(only: %i[id title require_confidentiality display_team whitelabel]).merge(
        description_html: Comakery::Markdown.to_html(project.description),
        show_contributions: policy(project).show_contributions?,
        square_image_url: GetImagePath.call(attachment: project.square_image, fallback: helpers.image_url('default_project.jpg')).path,
        panoramic_image_url: GetImagePath.call(attachment: project.panoramic_image, fallback: helpers.image_url('default_project.jpg')).path,
        video_id: project.video_id,
        token_percentage: project.percent_awarded_pretty,
        maximum_tokens: project.maximum_tokens,
        awarded_tokens: project.total_awarded_pretty,
        team_size: project.team_size,
        team: project.team_top.map { |contributor| contributor_props(contributor, project) },
        chart_data: GetContributorData.call(project: @project).award_data[:contributions_summary_pie_chart].map { |award| award[:net_amount] }.sort { |a, b| b <=> a },
        stats: project.stats
      )
    end

    def token_props(token)
      return if token.nil?

      token.as_json(only: %i[name symbol _token_type]).merge(
        'image_url' =>
          GetImageVariantPath.call(attachment: token.logo_image, resize_to_fill: [25, 18]).path
      )
    end

    def redirect_for_whitelabel
      if @whitelabel_mission
        if policy(@project).show_contributions?
          redirect_to project_dashboard_transfers_path(@project)
        else
          redirect_to project_award_types_path(@project)
        end
      end
    end
end
