paths \
    session:  '/api/session', # GET/POST/DELETE
    signup:   '/api/signup',
    settings: '/api/settings'

get :session do
  halt(401, 'Access denied') unless current_user.present?
  current_user.to_h.to_json
end

post :session do
  halt(400, 'Blank login or password') if params['username'].blank? || params['password'].blank?

  user = User.find_by(login: params['username'].downcase)
  halt(403, 'Access denied') unless user.present? && user.check_password(params['password'])

  session['user_id'] = user.id
  user.to_h.to_json
end

delete :session do
  session.delete('user_id')
  {status: :ok}.to_json
end

post :signup do
  u = User.find_by(invite_token: params[:token])
  halt(404, 'Invite token not found') unless u.present?

  login = params[:username].strip.downcase
  halt(400, 'Invalid username') if login.blank?
  halt(400, 'Username already exists') if User.where(login: login).present?

  u.login = login
  u.password = params[:password]
  u.invite_token = nil
  u.save

  return
end

post :settings do
  protect!

  session_stored = %w(theme device)
  persistent = %w()

  session_stored.each do |opt|
    session[opt] = params[opt].strip[0..20] if params[opt] != nil
  end

  persistent.each do |opt|
    current_user.settings[opt] = params[opt].strip[0..20] if params[opt] != nil
  end
  current_user.save

  {status: :ok}.to_json
end

