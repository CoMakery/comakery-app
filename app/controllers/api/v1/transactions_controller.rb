class Api::V1::TransactionsController < Api::V1::ApiController
  # POST /api/v1/projects/1/transactions
  def create
    @api_v1_transfer_queue = Api::V1::TransferQueue.new(api_v1_transfer_queue_params)

    respond_to do |format|
      if @api_v1_transfer_queue.save
        format.html { redirect_to @api_v1_transfer_queue, notice: 'Transfer queue was successfully created.' }
        format.json { render :show, status: :created, location: @api_v1_transfer_queue }
      else
        format.html { render :new }
        format.json { render json: @api_v1_transfer_queue.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /api/v1/projects/1/transactions/1
  def update
    respond_to do |format|
      if @api_v1_transfer_queue.update(api_v1_transfer_queue_params)
        format.html { redirect_to @api_v1_transfer_queue, notice: 'Transfer queue was successfully updated.' }
        format.json { render :show, status: :ok, location: @api_v1_transfer_queue }
      else
        format.html { render :edit }
        format.json { render json: @api_v1_transfer_queue.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /api/v1/projects/1/transactions/1
  def destroy
    @api_v1_transfer_queue.destroy
    respond_to do |format|
      format.html { redirect_to api_v1_transfer_queues_url, notice: 'Transfer queue was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def project
      @project ||= project_scope.find(params[:project_id])
    end

    def transfer
      @transfer ||= project.awards.completed_or_cancelled.find(params[:id])
    end
end
