module WakameHelpers
  def bb_expand(text)
    text = text.gsub(/\[radical\]([^\[]*)\[\/radical\]/, "[%(r)\\1%]")
    text = text.gsub(/\[kanji\]([^\[]*)\[\/kanji\]/, "[%(k)\\1%]")
    text = text.gsub(/\[reading\]([^\[]*)\[\/reading\]/, "[%(y)\\1%]")
    return text
  end

  def bb_textile(text)
    RedCloth.new( bb_expand(text) ).to_html
  end
end
