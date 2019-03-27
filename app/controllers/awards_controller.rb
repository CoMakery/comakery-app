class AwardsController < ApplicationController
  before_action :assign_project, except: %i[confirm]
  before_action :authorize_project_edit, except: %i[confirm]
  before_action :set_award_type, except: %i[confirm]
  before_action :set_award, except: %i[new create confirm]
  before_action :set_form_props, only: %i[new edit]
  before_action :set_show_props, only: %i[show]
  before_action :redirect_if_award_issued, only: %i[update edit destroy show send_award recipient_address]
  skip_before_action :verify_authenticity_token, only: %i[update_transaction_address]
  skip_before_action :require_login, only: %i[confirm]
  skip_after_action :verify_authorized, only: %i[confirm]

  layout 'react'

  def new
    render component: 'TaskForm', props: @props
  end

  def show
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
    @award.update! ethereum_transaction_address: params[:tx]
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

    def authorize_project_edit
      authorize @project, :edit?
    end

    def set_award_type
      @award_type = @project.award_types.find(params[:award_type_id])
    end

    def set_award
      @award = @award_type.awards.find(params[:id] || params[:award_id])
    end

    def award_params
      params.fetch(:task, {}).permit(
        :name,
        :why,
        :description,
        :requirements,
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

    def set_show_props
      @props = {
        task: @award.serializable_hash,
        batch: @award.award_type.serializable_hash,
        token: @project.token ? @project.token.serializable_hash : {},
        channels: (@project.channels + [Channel.new(name: 'Email')]).map { |c| [c.name, c.id.to_s] }.to_h,
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
        task: (@award ? @award : @award_type.awards.new).serializable_hash,
        token: @project.token ? @project.token.serializable_hash : {},
        form_url: project_award_type_awards_path(@project, @award_type),
        form_action: 'POST',
        url_on_success: project_award_types_path,
        csrf_token: form_authenticity_token
      }
    end

    def redirect_if_award_issued
      if @award.done?
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
        "Successfully sent award to #{@award.decorate.recipient_display_name}. You can initiate the token transfer on the awards page."
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
