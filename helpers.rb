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

  OPTIONS_DEFAULTS = {
    theme: 'white',
    device: 'pc',
    editing: true
  }
  # List of options which should be saved in current_user.settings
  # All other options will be saved in session
  OPTIONS_PERSISTENT = []

  def options(name)
    if OPTIONS_PERSISTENT.include?(name)
      return (current_user.present? ? current_user.settings[name] : nil) || OPTIONS_DEFAULTS[name.to_sym]
    else
      return session[name] || OPTIONS_DEFAULTS[name.to_sym]
    end
  end

  def custom_today
    # TODO: configurable settings for users
    # Right now, new days starts from 5AM (server's local time)
    return Date.today - (DateTime.now.hour < 5 ? 1 : 0)
  end
end
