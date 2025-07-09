paths \
    drills: '/api/drills',
    drill: '/api/drill/:id',
    drills_words: '/api/drills/words'

get :drills do
  protect!
  drills = Drill.where(user: current_user).order(updated_at: :desc)
  drills.map(&:to_h).to_json
end

post :drills do
  protect!

  Drill.create!(title: params[:title], user: current_user).to_json
rescue StandardError => e
  halt(400, "Unable to create record: #{e}")
end

get :drill do
  protect!
  drill = Drill.find_by(user: current_user, id: params[:id])
  halt(404, "Drill Set not found") if drill.blank?

  words = drill.drills_progresses. \
    eager_load(progress: [:word, :srs_progresses]). \
    order(created_at: :desc).map do |dp|
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

  json({
    drill: drill,
    words: words,
    sentences: drill.sentences.map{|i| i.study_hash(current_user)},
  })
end

# Change drill list
#
# params[:id] [Number] Drill ID
# params[:title] [String] Optional. New title for drill
# params[:is_active] [String] Optional. Use it to enable/disable drill list. '0' stands for 'false'
# params[:reset] [String] Optional. Use it to reset progresses. Values: 'reading' or 'writing'
patch :drill do
  protect!

  drill = Drill.find(params[:id])
  halt(403, "Access denied") if drill.user_id != current_user.id

  drill.title = params[:title] if params[:title].present?
  drill.is_active = params[:is_active] if params.key?(:is_active)

  drill.reset_leitner(:reading) if params[:reset] == 'reading'
  drill.reset_leitner(:writing) if params[:reset] == 'writing'

  drill.save

  return drill.to_h.to_json
end

# Add/remove word from drill list
#
# params[:drill_id] [Number]
# params[:seq] [Number] Word seq
# params[:title] [String] Kreb title
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
    drill.touch
    return {result: :added}.to_json
  end
end
