class AwardsController < ApplicationController
  before_action :set_project, except: %i[index confirm]
  before_action :authorize_project_edit, except: %i[index show confirm start submit accept reject]
  before_action :set_award_type, except: %i[index confirm]
  before_action :set_award, except: %i[index new create confirm]
  before_action :authorize_award_show, only: %i[show]
  before_action :authorize_award_start, only: %i[start]
  before_action :authorize_award_submit, only: %i[submit]
  before_action :authorize_award_review, only: %i[accept reject]
  before_action :authorize_award_pay, only: %i[update_transaction_address]
  before_action :set_filter, only: %i[index]
  before_action :set_awards, only: %i[index]
  before_action :set_page, only: %i[index]
  before_action :set_form_props, only: %i[new edit clone]
  before_action :set_show_props, only: %i[show]
  before_action :set_award_props, only: %i[award]
  before_action :set_index_props, only: %i[index]
  before_action :redirect_if_award_issued, only: %i[start update edit destroy award send_award recipient_address]
  skip_before_action :verify_authenticity_token, only: %i[update_transaction_address]
  skip_before_action :require_login, only: %i[confirm]
  skip_after_action :verify_authorized, only: %i[confirm]

  layout 'react'

  def index
    render component: 'MyTasks', props: @props
  end

  def new
    render component: 'TaskForm', props: @props
  end

  def clone
    @props[:task][:image_from_id] = @award.id

    render component: 'TaskForm', props: @props
  end

  def show
    render component: 'TaskDetails', props: @props
  end

  def award
    render component: 'TaskShow', props: @props
  end

  def edit
    @props[:form_url] = project_award_type_award_path(@project, @award_type, @award)
    @props[:form_action] = 'PATCH'

    render component: 'TaskForm', props: @props
  end

  def create
    @award = @award_type.awards.new(award_params)
    @award.issuer = current_account

    if !@award.image && params[:task][:image_from_id]
      source_award = Award.find(params[:task][:image_from_id].to_i)
      if policy(source_award.project).edit?
        @award.image_id = source_award.image_id
      end
    end

    if @award.save
      set_ok_response
      render json: @ok_response, status: :ok
    else
      error_response
      render json: @error_response, status: :unprocessable_entity
    end
  end

  def update
    if @award.update(award_params)
      set_ok_response
      render json: @ok_response, status: :ok
    else
      error_response
      render json: @error_response, status: :unprocessable_entity
    end
  end

  def start
    if @award.update(account: current_account, status: 'started')
      redirect_to my_tasks_path(filter: 'started'), notice: 'Task started'
    else
      redirect_to project_award_type_award_path(@award.project, @award.award_type, @award), flash: { error: @award.errors&.full_messages&.join(', ') }
    end
  end

  def submit
    if @award.update(submit_params.merge(status: 'submitted'))
      redirect_to my_tasks_path(filter: 'submitted'), notice: 'Task submitted'
    else
      redirect_to project_award_type_award_path(@award.project, @award.award_type, @award), flash: { error: @award.errors&.full_messages&.join(', ') }
    end
  end

  def accept
    if @award.update(status: 'accepted')
      redirect_to my_tasks_path(filter: 'done'), notice: 'Task accepted'
    else
      redirect_to project_award_type_award_path(@award.project, @award.award_type, @award), flash: { error: @award.errors&.full_messages&.join(', ') }
    end
  end

  def reject
    if @award.update(status: 'rejected')
      redirect_to my_tasks_path(filter: 'done'), notice: 'Task rejected'
    else
      redirect_to project_award_type_award_path(@award.project, @award.award_type, @award), flash: { error: @award.errors&.full_messages&.join(', ') }
    end
  end

  def destroy
    @award.destroy
    redirect_to project_award_types_path, notice: 'Task destroyed'
  end

  def recipient_address
    @project.token ? set_recipient_address_response : set_recipient_address_response_for_missing_token
    render json: @recipient_address_response, status: :ok
  end

  def send_award
    result = SendAward.call(
      award: @award,
      quantity: send_award_params[:quantity],
      message: send_award_params[:message],
      channel_id: send_award_params[:channel_id],
      uid: send_award_params[:uid],
      email: send_award_params[:email]
    )
    if result.success?
      @award.send_award_notifications
      @award.send_confirm_email
      if @award.account&.decorate&.can_receive_awards?(@project)
        session[:last_award_id] = @award.id
        @award.account&.update new_award_notice: true
      end
      flash[:notice] = send_award_notice
      head :ok
    else
      error_response(result.message)
      render json: @error_response, status: :unprocessable_entity
    end
  end

  def update_transaction_address
    @award.update! ethereum_transaction_address: params[:tx], status: 'paid'
    @award = @award.decorate
    render layout: false
  end

  def confirm
    if current_account
      award = Award.find_by confirm_token: params[:token]
      if award
        flash[:notice] = confirm_message(award.project) if award.confirm!(current_account)
        redirect_to project_path(award.project)
      else
        flash[:error] = 'Invalid award token!'
        redirect_to root_path
      end
    else
      session[:redeem] = true
      flash[:notice] = "Please #{view_context.link_to 'log in', new_session_path} or #{view_context.link_to 'signup', new_account_path} before receiving your award"
      redirect_to new_account_path
    end
  end

  private

    def set_project
      @project = Project.find(params[:project_id])&.decorate
      redirect_to('/404.html') unless @project
    end

    def authorize_project_edit
      authorize @project, :edit?
    end

    def authorize_award_show
      authorize @award, :show?
    end

    def authorize_award_start
      authorize @award, :start?
    end

    def authorize_award_submit
      authorize @award, :submit?
    end

    def authorize_award_review
      authorize @award, :review?
    end

    def authorize_award_pay
      authorize @award, :pay?
    end

    def set_award_type
      @award_type = @project.award_types.find(params[:award_type_id])
    end

    def set_award
      @award = Award.find(params[:id] || params[:award_id])
    end

    def set_filter
      @filter = params[:filter]&.downcase || 'ready'
    end

    def set_awards
      @awards = policy_scope(Award).filtered_for_view(@filter, current_account).order(updated_at: :desc)
    end

    def set_page
      @page = (params[:page] || 1).to_i
      @awards_paginated = @awards.page(@page).per(20)
      redirect_to '/404.html' if (@page > 1) && @awards_paginated.out_of_range?
    end

    def award_params
      params.fetch(:task, {}).permit(
        :name,
        :why,
        :description,
        :image,
        :requirements,
        :experience_level,
        :amount,
        :proof_link
      )
    end

    def send_award_params
      params.fetch(:task, {}).permit(
        :quantity,
        :message,
        :channel_id,
        :uid,
        :email
      )
    end

    def submit_params
      params.fetch(:task, {}).permit(
        :submission_url,
        :submission_comment,
        :submission_image
      )
    end

    def task_to_props(task)
      task&.serializable_hash&.merge({
        mission: {
          name: task.project&.mission&.name,
          url: task.project&.mission ? mission_path(task.project&.mission) : nil
        },
        token: {
          currency: task.project&.token&.symbol,
          logo: helpers.attachment_url(task.project&.token, :logo_image, :fill, 100, 100)
        },
        project: {
          name: task.project&.title,
          url: task.project && (task.project.unlisted? ? unlisted_project_path(task.project.long_id) : project_path(task.project))
        },
        batch: {
          specialty: task.award_type&.specialty&.name
        },
        issuer: {
          name: task.issuer&.decorate&.name,
          image: helpers.account_image_url(task.issuer, 100),
          self: task.issuer == current_account
        },
        contributor: {
          name: task.account&.decorate&.name,
          image: helpers.account_image_url(task.account, 100),
          wallet_present: task.account&.decorate&.can_receive_awards?(task.project)
        },
        image_url: helpers.attachment_url(task, :image),
        submission_image_url: helpers.attachment_url(task, :submission_image),
        payment_url: awards_project_path(task.project),
        details_url: project_award_type_award_path(task.project, task.award_type, task),
        start_url: project_award_type_award_start_path(task.project, task.award_type, task),
        submit_url: project_award_type_award_submit_path(task.project, task.award_type, task),
        accept_url: project_award_type_award_accept_path(task.project, task.award_type, task),
        reject_url: project_award_type_award_reject_path(task.project, task.award_type, task),
        updated_at: helpers.time_ago_in_words(task.updated_at)
      })
    end

    def set_index_props
      @props = {
        tasks: @awards_paginated.map { |task| task_to_props(task) },
        pagination_html: helpers.paginate(@awards_paginated, window: 3),
        filters: ['ready', 'started', 'submitted', 'to review', 'to pay', 'done'].map do |filter|
          {
            name: filter,
            current: filter == @filter,
            count: policy_scope(Award).filtered_for_view(filter, current_account).size,
            url: my_tasks_path(filter: filter)
          }
        end,
        past_awards_url: show_account_path
      }
    end

    def set_show_props
      @props = {
        task: task_to_props(@award),
        csrf_token: form_authenticity_token
      }
    end

    def set_award_props
      @props = {
        task: @award.serializable_hash,
        batch: @award_type.serializable_hash,
        project: @project.serializable_hash,
        token: @project.token ? @project.token.serializable_hash : {},
        channels: (@project.channels + [Channel.new(name: 'Email')]).map { |c| [c.name || c.channel_id, c.id.to_s] }.to_h,
        members: @project.channels.map { |c| [c.id.to_s, c.members.to_h] }.to_h,
        recipient_address_url: project_award_type_award_recipient_address_path(@project, @award_type, @award),
        form_url: project_award_type_award_send_award_path(@project, @award_type, @award),
        form_action: 'POST',
        url_on_success: project_award_types_path,
        csrf_token: form_authenticity_token
      }
    end

    def set_form_props
      @props = {
        task: (@award ? @award : @award_type.awards.new).serializable_hash&.merge(
          image_url: Refile.attachment_url(@award ? @award : @award_type.awards.new, :image, :fill, 300, 300)
        ),
        batch: @award_type.serializable_hash,
        project: @project.serializable_hash,
        token: @project.token ? @project.token.serializable_hash : {},
        experience_levels: Award::EXPERIENCE_LEVELS,
        form_url: project_award_type_awards_path(@project, @award_type),
        form_action: 'POST',
        url_on_success: project_award_types_path,
        csrf_token: form_authenticity_token
      }
    end

    def redirect_if_award_issued
      if @award.completed?
        flash[:error] = 'Completed task cannot be changed'
        redirect_to project_award_types_path
      end
    end

    def set_ok_response
      @ok_response = {
        id: @award.id,
        message: (action_name == 'create' ? 'Task created' : 'Task updated'),
        form_url: project_award_type_award_path(@project, @award_type, @award),
        edit_url: edit_project_award_type_award_path(@project, @award_type, @award)
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def error_response(message = nil)
      @error_response = {
        id: @award.id,
        message: message ? message : @award.errors&.full_messages&.join(', '),
        errors: @award.errors&.messages&.map { |k, v| ["task[#{k}]", v.to_sentence] }.to_h
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def set_recipient_address_response
      address = (
        if params[:channel_id].blank?
          Account.where('lower(email)=?', params[:email].downcase).first
        else
          Account.find_from_uid_channel(params[:uid], Channel.find_by(id: params[:channel_id]))
        end
      )&.send("#{Token::BLOCKCHAIN_NAMES[@project.token.coin_type.to_sym]}_wallet")

      network = (
        if @project.token.coin_type_on_ethereum?
          @project.token.ethereum_network.presence || 'main'
        else
          @project.token.blockchain_network
        end
      )

      wallet_url = address ? UtilitiesService.get_wallet_url(network, address) : nil

      @recipient_address_response = {
        address: address,
        wallet_url: wallet_url
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def set_recipient_address_response_for_missing_token
      @recipient_address_response = {
        address: nil,
        wallet_url: nil
      }.deep_transform_keys { |key| key.to_s.camelize(:lower) }
    end

    def send_award_notice
      if !@award.self_issued? && @award.decorate.recipient_address.blank?
        "The award recipient hasn't entered a blockchain address for us to send the award to. When the recipient enters their blockchain address you will be able to approve the token transfer on the awards page."
      else
        "#{@award.decorate.recipient_display_name.possessive} task has been accepted. Initiate payment for the task on the payments page."
      end
    end

    def confirm_message(project)
      return nil unless project.token&.coin_type?
      blockchain_name = Token::BLOCKCHAIN_NAMES[project.token.coin_type.to_sym]
      send("confirm_message_for_#{blockchain_name}_award")
    end

    def confirm_message_for_ethereum_award
      if current_account.ethereum_wallet.present?
        "Congratulations, you just claimed your award! Your Ethereum address is #{view_context.link_to current_account.ethereum_wallet, current_account.decorate.etherscan_address} you can change your Ethereum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Ethereum tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your Ethereum Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end

    def confirm_message_for_qtum_award
      if current_account.qtum_wallet.present?
        "Congratulations, you just claimed your award! Your Qtum address is #{view_context.link_to current_account.qtum_wallet, current_account.decorate.qtum_wallet_url} you can change your Qtum address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Qtum tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your Qtum Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end

    def confirm_message_for_cardano_award
      if current_account.cardano_wallet.present?
        "Congratulations, you just claimed your award! Your Cardano address is #{view_context.link_to current_account.cardano_wallet, current_account.decorate.cardano_wallet_url} you can change your Cardano address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Cardano tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your Cardano Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end

    def confirm_message_for_bitcoin_award
      if current_account.bitcoin_wallet.present?
        "Congratulations, you just claimed your award! Your Bitcoin address is #{view_context.link_to current_account.bitcoin_wallet, current_account.decorate.bitcoin_wallet_url} you can change your Bitcoin address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Bitcoin tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your Bitcoin Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end

    def confirm_message_for_eos_award
      if current_account.eos_wallet.present?
        "Congratulations, you just claimed your award! Your EOS account name is #{view_context.link_to current_account.eos_wallet, current_account.decorate.eos_wallet_url} you can change your EOS account name on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your EOS tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your EOS Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end

    def confirm_message_for_tezos_award
      if current_account.tezos_wallet.present?
        "Congratulations, you just claimed your award! Your Tezos address is #{view_context.link_to current_account.tezos_wallet, current_account.decorate.tezos_wallet_url} you can change your Tezos address on your #{view_context.link_to('account page', show_account_path)}. The project owner can now issue your Tezos tokens."
      else
        "Congratulations, you just claimed your award! Be sure to enter your Tezos Adress on your #{view_context.link_to('account page', show_account_path)} to receive your tokens."
      end
    end
end
