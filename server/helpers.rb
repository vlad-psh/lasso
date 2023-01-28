module WakameHelpers
  def protect!
    return if current_user
    halt 401, "Unauthorized"
  end

  def current_user
    return nil unless session['user_id'].present?

    @current_user ||= User.find(session['user_id'])
    return @current_user
  end

  def custom_today
    # TODO: configurable settings for users
    # Right now, new days starts from 5AM (server's local time)
    return Date.today - (DateTime.now.hour < 5 ? 1 : 0)
  end
end
