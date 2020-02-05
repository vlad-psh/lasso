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

  def current_level
    return 1 unless current_user

    @current_level ||= @current_user.current_level
    return @current_level
  end

  def user_settings(_name)
    return nil unless current_user
    return current_user.settings.try(:[], _name)
  end

  def highlight(text, term)
    return text unless text.present? && term.present?

    termj = term.downcase.hiragana
    terms = termj.japanese? ? [term, termj, term.downcase.katakana] : [term]
    hhash = highlight_find(text, terms)
    return highlight_html(hhash)
  end

  def highlight_html(hhash)
    result = ""
    hhash.each do |h|
      result += h[:h] == true ? "<span class='highlight'>#{h[:t]}</span>" : h[:t]
    end
    return result
  end

  def highlight_find(text, terms)
    i, term = nil, nil
    terms.each do |t|
      next unless i.blank?
      i = text.index(Regexp.new(t, Regexp::IGNORECASE))
      term = t if i.present?
    end

    result = []
    if i != nil
      result << {t: text[0...i], h: false} if i > 0
      result << {t: text[i...(i+term.length)], h: true}
      if i + term.length < text.length
        result << highlight_find(text[(i+term.length)..-1], terms)
      end
    else
      result << {t: text, h: false}
    end
    return result.flatten
  end

  SAFE_TYPES = [:radicals, :kanjis, :words]
  SAFE_GROUPS = [:just_learned, :expired]

  def safe_type(method)
    m = method.to_sym
    throw StandardError.new("Unknown method: #{method}") unless SAFE_TYPES.include?(m)
    return m
  end

  def safe_group(method)
    m = method.to_sym
    throw StandardError.new("Unknown method: #{method}") unless SAFE_GROUPS.include?(m)
    return m
  end

  OPTIONS_DEFAULTS = {
    theme: 'white',
    device: 'pc'
  }
  # List of options which should be saved in current_user.settings
  # All other options will be saved in session
  OPTIONS_PERSISTENT = []

  def options(name)
    return (OPTIONS_PERSISTENT.include?(name) ? current_user.settings[name] : session[name]) || OPTIONS_DEFAULTS[name.to_sym]
  end
end
