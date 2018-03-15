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
    termj = term.downcase.hiragana
    hhash = highlight_find(text, term)
    if termj.japanese?
      hhash2 = []
      hhash.each do |h|
        hhash2 << (h[:h] == true ? h : highlight_find(h[:t], termj))
      end
      return highlight_html(hhash2.flatten)
    else
      return highlight_html(hhash)
    end
  end

  def highlight_html(hhash)
    result = ""
    hhash.each do |h|
      result += h[:h] == true ? "<span class='highlight'>#{h[:t]}</span>" : h[:t]
    end
    return result
  end

  def highlight_find(text, term)
    i = text.index(Regexp.new(term, Regexp::IGNORECASE))
    result = []
    if i != nil
      result << {t: text[0...i], h: false} if i > 0
      result << {t: text[i...(i+term.length)], h: true}
      if i + term.length < text.length
        result << highlight_find(text[(i+term.length)..-1], term)
      end
    else
      result << {t: text, h: false}
    end
    return result.flatten
  end

  def wk_level(e)
    # Shuffle for testing purposes
    #return %w(locked unlocked apprentice guru master enlightened burned).shuffle[0]
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

end
