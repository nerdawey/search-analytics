class ApplicationController < ActionController::Base
  private

  def generate_user_hash
    ip = request.remote_ip
    user_id = cookies.signed[:user_id] || generate_persistent_user_id

    Digest::SHA256.hexdigest("#{ip}#{user_id}#{Rails.application.secret_key_base}")
  end

  private

  def generate_persistent_user_id
    user_id = SecureRandom.uuid
    cookies.signed[:user_id] = { value: user_id, expires: 1.year.from_now }
    user_id
  end
end
