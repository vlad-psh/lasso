paths \
    drills: '/api/drills',
    drills_words: '/api/drills/words',
    drill: '/api/drill/:id'

get :drills do
  protect!
  drills = Drill.where(user: current_user).order(created_at: :desc)
  drills.map(&:to_h).to_json
end

post :drills do
  protect!

  drill = Drill.create(title: params[:title], user: current_user)

  redirect path_to(:drill).with(drill.id)
end

get :drill do
  protect!
  drill = Drill.find_by(user: current_user, id: params[:id])
  halt(404, "Drill Set not found") if drill.blank?

  words = drill.drills_progresses. \
    eager_load(progress: [:word, :srs_progresses]). \
    order(created_at: :asc).map do |dp|
      p = dp.progress
      w = p.word
      {
        seq: p.seq,
        title: p.title,
        reading: w.rebs.first,
        description: w.list_desc,
        progress: {
          reading: p.burned_at ? :burned : p.srs_progresses.detect{|i|
            i.learning_type == 'reading'}.try(:html_class_leitner) || :pristine,
          writing: p.burned_at ? :burned : p.srs_progresses.detect{|i|
            i.learning_type == 'writing'}.try(:html_class_leitner) || :pristine,
        },
      }
  end

  {
    drill: drill,
    words: words,
    sentences: drill.sentences.map{|i| i.study_hash(current_user)},
  }.to_json
end

patch :drill do
  protect!

  drill = Drill.find(params[:id])
  halt(403, "Access denied") if drill.user_id != current_user.id

  drill.title = params[:title] if params[:title].present?
  drill.is_active = params[:enabled] == '0' ? false : true if params[:enabled].present?

  drill.reset_leitner(:reading) if params[:reset] == 'reading'
  drill.reset_leitner(:writing) if params[:reset] == 'writing'

  drill.save

  return drill.to_h.to_json
end

post :drills_words do
  protect!

  drill = Drill.find_by(id: params[:drill_id], user: current_user)
  halt(404, "Drill list not found") if drill.blank?

  word_title = params[:title] || Word.find_by(seq: params[:seq]).krebs.first
  progress = Progress.find_or_create_by(seq: params[:seq], title: word_title, user: current_user)

  if drill.progresses.include?(progress)
    drill.progresses.delete(progress)
    progress.update(flagged: false) if progress.drills.blank?
    return {result: :removed}.to_json
  else
    drill.progresses << progress
    progress.update(flagged: true)
    return {result: :added}.to_json
  end
end
