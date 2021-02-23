export default (context) => {
  const { store, redirect } = context
  const user = store.state.env.user
  if (!user) {
    redirect('/login')
  }
}
