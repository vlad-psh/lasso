paths study: '/study/:class/:group', # get, post
  study2: '/study2'

get :study do
  protect!

  progresses = Progress.public_send(safe_group(params[:group])).
                        public_send(safe_type(params[:class])).
                        where(user: current_user)
  @count = progresses.count
  @progress = progresses.order('RANDOM()').first

  if @progress.present?
    @title = @progress.title
    slim :study
  else
    flash[:notice] = "No more #{params[:class]} in \"#{params[:group]}\" group"
    redirect path_to(:index)
  end
end

post :study do
  protect!

  p = Progress.find(params[:id])
  halt(403, 'Forbidden') if p.user_id != current_user.id
  halt(400, 'Element not found') unless p.present?

  p.answer!(params[:answer])

  redirect path_to(:study).with(safe_type(params[:class]), safe_group(params[:group]))
end

get :study2 do
  protect!

  slim :study2
end

post :study2 do
  progresses = {}
  params[:answers].each do |i, a|
    a['progress'] = Progress.find_by(seq: a['seq'], title: a['base'], user: current_user)
    halt(403, 'Forbidden') if a['progress'].blank?
# TODO: Make so that answers can be given to words without 'progress' record
# (new progress record should be created automatically)
  end

  params[:answers].each do |i,a|
    next if a['answer'] == 'burned'
    a['progress'].answer!(a['answer'])
  end

  return 'ok'
end

