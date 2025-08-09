class ProcessSearchSessionJob < ApplicationJob
  queue_as :default

  def perform(user_hash:, session_id:)
    SearchEventProcessorService.new(user_hash).process_session(session_id)
  end

  private

  def find_final_event(events)
    finalize_event = events.finalize.ordered_by_created_at.last
    return finalize_event if finalize_event.present?

    events.keystroke.ordered_by_created_at.last
  end

  def meaningful_search?(_events, final_term)
    return false if final_term.blank?
    return false if final_term.length < 2
    return false if final_term.chars.uniq.length == 1

    true
  end
end
