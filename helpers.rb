module WakameHelpers
  def admin?
    session['role'] == 'admin'
  end

  def guest?
    session['role'] == 'guest'
  end

  def protect!
    return if admin?
    halt 401, "Unauthorized"
  end

  def hide!
    return if admin? || guest?
    halt 401, "Unauthorized"
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

  def wk_level(e)
    # Shuffle for testing purposes
    #return %w(locked unlocked apprentice guru master enlightened burned).shuffle[0]
    if e.unlocked
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

  def weblio_pitch(_word)
    response = HTTParty.get(URI.encode("https://www.weblio.jp/content/#{_word}"), headers: $weblio_headers)
    xml = Nokogiri::HTML(response.body)
    midashigo = xml.css("h2.midashigo")
    readings = []
    midashigo.each do |m|
      mm = m.content.match(/.*［(?<pitch>\d)］.*/)
      if mm && mm['pitch']
        readings << {header: m.content.gsub(/ /, ''), pitch: mm['pitch'].to_i}
      end
    end
    return readings
  end
end
