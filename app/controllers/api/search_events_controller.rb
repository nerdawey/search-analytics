module Api
  class SearchEventsController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :set_user_hash

    def create
      @search_event = SearchEvent.new(search_event_params)
      @search_event.user_hash = @user_hash

      if @search_event.save
        # Process search analytics if this is a finalize event
        process_search_session(@user_hash, @search_event.session_id) if @search_event.event_type == 'finalize'

        render json: { status: 'success', message: 'Search event recorded' }, status: :created
      else
        render json: { status: 'error', message: @search_event.errors.full_messages.join(', ') },
               status: :unprocessable_entity
      end
    rescue StandardError
      render json: { status: 'error', message: 'Internal server error' }, status: :internal_server_error
    end

    private

    def set_user_hash
      @user_hash = generate_user_hash
    end

    def process_search_session(user_hash, session_id)
      # Get all events for this session
      events = SearchEvent.by_user(user_hash).by_session(session_id).order(:created_at)

      # Find the final search term (last keystroke or finalize event)
      final_event = find_final_event(events)
      return unless final_event

      final_term = SearchSummary.normalize_term(final_event.raw_value)
      return if final_term.blank?

      # Check if this is a meaningful search (not just intermediate typing)
      return unless meaningful_search?(events, final_term)

      # IMPORTANT: Remove any previous search summaries from this session that are prefixes of the final term
      remove_intermediate_searches(user_hash, session_id, final_term)

      # Increment or create search summary for the final term only
      SearchSummary.increment_or_create(user_hash: user_hash, term: final_term)
    end

    def find_final_event(events)
      # Look for a finalize event first
      finalize_event = events.finalized.last
      return finalize_event if finalize_event

      # If no finalize event, use the last keystroke
      events.keystrokes.last
    end

    def meaningful_search?(events, final_term)
      # A search is meaningful if:
      # 1. It has at least 2 characters
      # 2. It's not just repeated keystrokes of the same character
      # 3. It has some variation in the typing session

      return false if final_term.length < 2

      # Check for repeated characters
      return false if final_term.chars.uniq.length == 1 && final_term.length > 3

      # Check if there was meaningful typing activity
      keystroke_events = events.keystrokes
      return true if keystroke_events.count >= 2

      # If there's only one keystroke event, it's still meaningful if it's a finalize event
      # or if the term is substantial
      return true if final_term.length >= 3

      false
    end

    def remove_intermediate_searches(user_hash, _session_id, final_term)
      # Get all search summaries for this user
      user_summaries = SearchSummary.by_user(user_hash)

      # Find and remove any summaries that are prefixes of the final term
      user_summaries.each do |summary|
        if final_term.start_with?(summary.term) && summary.term != final_term
          # This is an intermediate search that should be removed
          summary.destroy
        end
      end
    end

    def search_event_params
      params.require(:search_event).permit(:session_id, :raw_value, :event_type)
    end
  end
end
