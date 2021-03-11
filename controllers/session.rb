paths \
    session:  '/api/session', # GET/POST/DELETE
    settings: '/api/settings'

get :session do
  halt(401, 'Access denied') unless current_user.present?
  current_user.to_h.to_json
end

post :session do
  halt(400, 'Blank login or password') if params['username'].blank? || params['password'].blank?

  user = User.find_by(login: params['username'])
  halt(403, 'Access denied') unless user.present? && user.check_password(params['password'])

  session['user_id'] = user.id
  user.to_h.to_json
end

delete :session do
  session.delete('user_id')
  {status: :ok}.to_json
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

