class SearchEventCreatorService < BaseService
  def initialize(user_hash, event_params)
    @user_hash = user_hash
    @event_params = event_params
  end

  def call
    search_event = SearchEvent.new(@event_params)
    search_event.user_hash = @user_hash

    if search_event.save
      process_finalize_event(search_event) if search_event.event_type == 'finalize'
      success(search_event)
    else
      failure(search_event.errors.full_messages.join(', '))
    end
  rescue StandardError => e
    failure("Internal server error: #{e.message}")
  end

  private

  def process_finalize_event(search_event)
    SearchEventProcessorService.new(@user_hash).process_session(search_event.session_id)
  end
end
