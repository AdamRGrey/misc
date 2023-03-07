import obspython as obs
import urllib.request
import urllib.error
from urllib import request, parse
import json

url         = ""
body 		= ""

# ------------------------------------------------------------


def call_hook():
	global url
	global body
	
	try:
		data = json.dumps({"content": body})
		data = str(data)
		data = data.encode()
		req =  request.Request(url, data=data,method="POST",headers = {'Content-Type': 'application/json', 'User-Agent': 'curl/7.54.1'})
		resp = request.urlopen(req)

	except urllib.error.URLError as err:
		obs.script_log(obs.LOG_WARNING, "Error opening URL '" + url + "': " + err.reason)
		obs.remove_current_callback()

def testbutton_pressed(props, prop):
	call_hook()
# ------------------------------------------------------------

def on_event(event):
	if event == obs.OBS_FRONTEND_EVENT_STREAMING_STARTED:
		call_hook()

def script_description():
	return "posts basic text to a discord webhook when you go live\n\nBy AdamRGrey"

def script_load(settings):
	obs.obs_frontend_add_event_callback(on_event)

def script_defaults(settings):
	obs.obs_data_set_default_string(settings, "body", "hey I'm live! https://twitch.tv")

def script_update(settings):
	global url
	global body
	
	url         = obs.obs_data_get_string(settings, "url")
	body = obs.obs_data_get_string(settings, "body")

def script_properties():
	props = obs.obs_properties_create()

	obs.obs_properties_add_text(props, "url", "URL", obs.OBS_TEXT_DEFAULT)
	obs.obs_properties_add_text(props, "body", "body", obs.OBS_TEXT_DEFAULT)

	obs.obs_properties_add_button(props, "button", "test", testbutton_pressed)
	return props
