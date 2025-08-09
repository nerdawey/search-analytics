class ApplicationController < ActionController::Base
  private

  def generate_user_hash
    ip = request.remote_ip
    session_id = session.id || SecureRandom.uuid

    Digest::SHA256.hexdigest("#{ip}#{session_id}#{Rails.application.secret_key_base}")
  end
end
