paths \
    mecab_text: '/api/mecab/text',
    mecab_word: '/api/mecab/word/:seq'

post :mecab_text do
  protect!

  wt = WordTitle.where(title: params[:sentence]).pluck(:seq).uniq

  if wt.length == 1 # found exact word
    w = Word.find_by(seq: wt[0])
    return [{
        text: params[:sentence],
        reading: w.rebs[0],
        base: params[:sentence],
        gloss: w.en[0]['gloss'][0],
        seq: wt[0]
    }].to_json
  else
    return MecabParser.parse_sentence(params[:sentence]).to_json
  end
end

get :mecab_word do
  w = Word.find_by(seq: params[:seq])
  w.meikyo_mecab.to_json
end
