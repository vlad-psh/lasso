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

  def find_element(type, id)
    if [:radical, :r].include?(type.to_sym)
      return Radical.find(id)
    elsif [:kanji, :k].include?(type.to_sym)
      return Kanji.find(id)
    elsif [:word, :w].include?(type.to_sym)
      return Word.find(id)
    else
      return nil
    end
  end
end
