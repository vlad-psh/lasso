paths login: '/login', # GET: login form; POST: log in
    logout: '/logout', # DELETE: logout
    settings: '/settings'

get :login do
  if current_user.present?
    flash[:notice] = "Already logged in"
    redirect path_to(:index)
  else
    slim :login
  end
end

post :login do
  begin
    throw StandardError.new('Blank login or password') if params['username'].blank? || params['password'].blank?

    user = User.find_by(login: params['username'])
    throw StandardError.new('User not found') unless user.present?
    throw StandardError.new('Incorrect password') unless user.check_password(params['password'])

    flash[:notice] = "Successfully logged in as #{user.login}!"
    session['user_id'] = user.id
    redirect path_to(:index)
  rescue
    flash[:error] = "Incorrect username or password :("
    redirect path_to(:login)
  end
end

delete :logout do
  session.delete('user_id')
  flash[:notice] = "Successfully logged out"
  redirect path_to(:index)
end

post :settings do
  protect!

  if params['black_theme'] != nil
    current_user.settings['theme'] = (params['black_theme'] == 'true' ? 'black' : 'white')
  end
  if params['editing'] != nil
    current_user.settings['editing'] = (params['editing'] == 'true' ? true : false)
  end
  current_user.save

  'ok'
end

