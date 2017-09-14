module WakameHelpers
  def bb_expand(text)
    text = text.gsub(/\[kanji\]([^\[]*)\[\/kanji\]/, "[%(k)\\1%]")
    text = text.gsub(/\[reading\]([^\[]*)\[\/reading\]/, "[%(y)\\1%]")
    text = text.gsub(/\[radical\]([^\[]*)\[\/radical\]/, "[%(r)\\1%]")
    text = text.gsub(/\[vocabulary\]([^\[]*)\[\/vocabulary\]/, "[%(w)\\1%]")
    return text
  end

  def bb_textile(text)
    RedCloth.new( bb_expand(text) ).to_html
  end

  def wk_level(e)
    # Shuffle for testing purposes
    #return %w(locked unlocked apprentice guru master enlightened burned).shuffle[0]
    if e.unlocked_at
      return 'unlocked'    unless e.learned_at
      return 'apprentice'  if e.deck <= 1
      return 'guru'        if e.deck == 2
      return 'master'      if e.deck == 3
      return 'enlightened' if e.deck == 4 || e.deck == 5
      return 'burned'      if e.deck >= 6
    else
      return 'locked'
    end
  end

  def get_element_class(type)
    type = type.to_s
    [Radical, Kanji, Word].each do |t|
      return t if (t.model_name.singular == type || t.model_name.plural == type)
    end
    raise StandardError.new("Unknown element type: #{type}")
  end
end
