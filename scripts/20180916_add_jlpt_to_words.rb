# JLPT data was taken from jlearn.net website and
# parsed into jlpt_words.json file

j = JSON.parse(File.read('../wakame_data/jlpt_words.json'))
missed = []
ambiguous = []
j.each do |jlpt_level,words|
  lvl = jlpt_level[1].to_i # Get number from JLPT level (eg: "N1")
  words.each do |w|
    if w['w'].present?
      wt1 = WordTitle.where(title: w['w'])
      next if wt1.blank?
      wt2 = WordTitle.where(title: w['r'], seq: wt1.pluck(:seq))
    else
      wt2 = WordTitle.where(title: w['r'])
    end

    wwr = "w['w']/w['r']"
    if wt2.length == 1
      _w = Word.find_by(seq: wt2[0].seq)
      if _w
        _w.update_attribute(:jlptn, lvl)
      else
        missed << wwr
      end
    elsif wt2.length > 1
      ambiguous << wwr
    else
      missed << wwr
    end
  end
end; nil

