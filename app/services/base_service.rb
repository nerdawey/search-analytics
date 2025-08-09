class BaseService
  def self.call(*)
    new(*).call
  end

  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  private

  def success(result = nil)
    { success?: true, result: result, error: nil }
  end

  def failure(error = nil)
    { success?: false, result: nil, error: error }
  end
end
