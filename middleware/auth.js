export default (context) => {
  const { redirect, route, $auth } = context

  if (route.name === 'login') {
    if ($auth.loggedIn()) redirect('/')
  } else if (!$auth.loggedIn()) redirect('/login')
}
