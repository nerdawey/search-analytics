class ProcessSearchSessionJob < ApplicationJob
  queue_as :default

  def perform(user_hash:, session_id:)
    # Get all events for this session
    events = SearchEvent.by_user(user_hash).by_session(session_id).order(:created_at)

    # Find the final search term (last keystroke or finalize event)
    final_event = find_final_event(events)
    return unless final_event

    final_term = SearchSummary.normalize_term(final_event.raw_value)
    return if final_term.blank?

    # Check if this is a meaningful search (not just intermediate typing)
    return unless meaningful_search?(events, final_term)

    # Increment or create search summary
    SearchSummary.increment_or_create(user_hash: user_hash, term: final_term)
  end

  private

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
end
