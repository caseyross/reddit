import parseRoute from './infra/parseRoute.coffee'
import api from '../api/index.js'
import { Time } from '../utils/index.js'

# Set the API config from environment vars.
api.configure({
	clientID: process.env.API_CLIENT_ID
	enableDiagnostics: ((new URLSearchParams(location.search)).get('debug') ? process.env.API_ENABLE_DIAGNOSTICS) in ['TRUE', 'true', '1']
	redirectURI: process.env.API_REDIRECT_URI
})

# If a login attempt was started by a prior instance of the application, finish it.
if api.getLoginStatus() is 'pending'
	{ error, memoString: rememberedPath } = api.finishPendingLogin()
	if error
		switch error.reason
			when 'no-matching-login-attempt' then alert("Login failed. The login process was not followed correctly.")
			when 'user-refused-login' then alert("Login failed. You didn't allow access to your account.") 
			else alert("Login failed. We didn't expect it to fail in this way so we don't know why.")
	history.replaceState(null, null, rememberedPath ? '/')

# Parse the current route so we can start making network requests for critical path data ASAP.
route = parseRoute(location)
if route.preload
	for id in route.preload
		api.preload(id)

# Apply color theming as soon as possible, preferably before any other CSS loads.
THEMES =
	DARK: 'theme-dark'
	LIGHT: 'theme-light'
setTheme = ->
	localHour = Time.localHour()
	newTheme = switch
		when 6 <= localHour <= 18 then THEMES.LIGHT
		else THEMES.DARK
	document.body.classList.add(newTheme)
	document.body.classList.remove(...Object.values(THEMES).filter((x) -> x != newTheme))
window.addEventListener('DOMContentLoaded', (e) ->
	setTheme()
	setInterval(setTheme, Time.mToMs(1))
)