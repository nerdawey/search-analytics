class SearchEventProcessorService < BaseService
  def initialize(user_hash)
    @user_hash = user_hash
  end

  def call(session_id)
    events = SearchEvent.by_user(@user_hash).by_session(session_id).ordered_by_created_at

    final_event = find_final_event(events)
    return failure('No final event found') unless final_event

    final_term = SearchSummary.normalize_term(final_event.raw_value)
    return failure('No final term found') if final_term.blank?

    return failure('Not a meaningful search') unless meaningful_search?(events, final_term)

    remove_intermediate_searches(session_id, final_term)

    result = SearchSummary.increment_or_create(user_hash: @user_hash, term: final_term)
    success(result)
  end

  def process_session(session_id)
    call(session_id)[:result]
  end

  private

  def find_final_event(events)
    finalize_event = events.finalize.last
    return finalize_event if finalize_event

    events.keystroke.last
  end

  def meaningful_search?(events, final_term)
    return false if final_term.length < 2

    return false if final_term.chars.uniq.length == 1 && final_term.length > 3

    keystroke_events = events.keystrokes
    return true if keystroke_events.size >= 2

    return true if final_term.length >= 3

    false
  end

  def remove_intermediate_searches(_session_id, final_term)
    SearchSummary.by_user(@user_hash)
      .excluding_term(final_term)
      .prefix_of(final_term)
      .destroy_all
  end
end
