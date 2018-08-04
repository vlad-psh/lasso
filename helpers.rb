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

  def level_started_at(level)
    return nil unless level && current_user

    if level == 1
      return Action.joins(:card).merge(Card.where(level: 1)).where(action_type: 2, user: current_user).order(created_at: :asc).first.created_at
    else
      return Action.joins(:card).merge(Card.where(level: level-1)).where(action_type: 2, user: current_user).order(created_at: :desc).first.created_at
    end
  end

  def bb_expand(text)
    text = text.gsub(/\[kanji\]([^\[]*)\[\/kanji\]/, "[%(k)\\1%]")
    text = text.gsub(/\[radical\]([^\[]*)\[\/radical\]/, "[%(r)\\1%]")
    text = text.gsub(/\[meaning\]([^\[]*)\[\/meaning\]/, "[%(m)\\1%]")
    text = text.gsub(/\[reading\]([^\[]*)\[\/reading\]/, "[%(y)\\1%]")
    text = text.gsub(/\[vocabulary\]([^\[]*)\[\/vocabulary\]/, "[%(w)\\1%]")
    return text
  end

  def bb_textile(text)
    RedCloth.new( bb_expand(text) ).to_html
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

  def wk_level(e)
    if e.kind_of?(Array)
      e = e.sort{|a,b| a.deck <=> b.deck}.last
    end

    if e.present? && e.try(:unlocked)
      return 'unlocked'    unless e.learned
      return 'apprentice'  if e.deck <= 1
      return 'guru'        if e.deck == 2
      return 'master'      if e.deck == 3
      return 'enlightened' if e.deck == 4 || e.deck == 5
      return 'burned'      if e.deck >= 6
    else
      return 'locked'
    end
  end

  SAFE_TYPES = [:radicals, :kanjis, :words]
  SAFE_GROUPS = [:just_unlocked, :just_learned, :expired, :failed]

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

  def kr_common?(kreb)
    return false unless kreb && kreb['pri']
    kreb['pri'].each do |k,v|
      return true if %w(news ichi spec gai).include?(k) && v == 1
      return true if k == 'spec' && v == 2
    end
    return false
  end
end
