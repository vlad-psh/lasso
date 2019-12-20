paths drills: '/drills',
    drill: '/drill/:id',
    flagged: '/flagged'

get :drills do
  protect!
  @drill_sets = Drill.where(user: current_user).order(created_at: :desc)
  slim :drills
end

post :drills do
  protect!

  drill = Drill.create(title: params[:title], user: current_user)

  redirect path_to(:drill).with(drill.id)
end

get :drill do
  protect!
  @drill = Drill.find_by(user: current_user, id: params[:id])
  halt(404, "Drill Set not found") if @drill.blank?

  @elements = @drill.progresses.eager_load(:word).map do |p|
    {
      title: p.title,
      reading: p.word.rebs.first,
      description: p.word.list_desc,
      html_class: p.html_class,
      href: path_to(:word).with(p.seq)
    }
  end

  slim :drill
end

patch :drill do
  protect!

  drill = Drill.find(params[:id])
  halt(403, "Access denied") if drill.user_id != current_user.id

  if params[:is_active]
    drill.update_attribute(:is_active, params[:is_active] == 'true' ? true : false)
  end

  redirect path_to(:drill).with(drill.id)
end

get :flagged do
  protect!
# TODO: this list is for all users; make it personal
  @progresses = Progress.where.not(flagged_at: nil).order(flagged_at: :desc)
  slim :flagged
end

