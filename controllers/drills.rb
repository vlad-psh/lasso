paths \
    drills: '/api/drills',
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

  words = drill.progresses.eager_load(:word, :srs_progresses).order(:id).map do |p|
    {
      seq: p.seq,
      title: p.title,
      reading: p.word.rebs.first,
      description: p.word.list_desc,
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

  if params[:enabled].present?
    drill.update(is_active: params[:enabled] == '0' ? false : true)
    return {
      text: params[:enabled] == '0' ? 'Enable' : 'Disable',
      value: params[:enabled] == '0' ? 1 : 0
    }.to_json
  elsif params[:reset] == 'reading'
    drill.reset_leitner(:reading)
  elsif params[:reset] == 'writing'
    drill.reset_leitner(:writing)
  end

  return '{}'
end

