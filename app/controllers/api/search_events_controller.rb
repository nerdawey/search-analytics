module Api
  class SearchEventsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_user_hash

    def create
      result = SearchEventCreatorService.new(@user_hash, search_event_params).call

      if result[:success?]
        render json: { status: 'success', message: 'Search event recorded' }, status: :created
      else
        render json: { status: 'error', message: result[:error] }, status: :unprocessable_entity
      end
    end

    private

    def set_user_hash
      @user_hash = generate_user_hash
    end

    def search_event_params
      params.require(:search_event).permit(:session_id, :raw_value, :event_type)
    end
  end
end
