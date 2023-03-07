obs = obslua
stop_target = ""
start_target = ""
pause_target = ""

function source_activated(cd)
	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if pause_target == name then
			obs.obs_frontend_recording_pause(true)
		elseif stop_target == name then
 			obs.obs_frontend_recording_stop()
 		elseif start_target == name then
 			obs.obs_frontend_recording_start()
 		end
	end
end
function source_deactivated(cd)
	local source = obs.calldata_source(cd, "source")
	if source ~= nil then
		local name = obs.obs_source_get_name(source)
		if pause_target == name then
			obs.obs_frontend_recording_pause(false)
 		end
	end
end

function script_properties()
	local props = obs.obs_properties_create()

	local pStart = obs.obs_properties_add_list(props, "start_target", "start target", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local pStop = obs.obs_properties_add_list(props, "stop_target", "stop target", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local pPause = obs.obs_properties_add_list(props, "pause_target", "pause target", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_enum_sources()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			local name = obs.obs_source_get_name(source)
			obs.obs_property_list_add_string(pStart, name, name)
			obs.obs_property_list_add_string(pStop, name, name)
			obs.obs_property_list_add_string(pPause, name, name)
		end
	end
	obs.source_list_release(sources)

	return props
end

function script_description()
	return "start/stop recording when specified source is in active scene"
end

function script_update(settings)
	stop_target = obs.obs_data_get_string(settings, "stop_target")
	start_target = obs.obs_data_get_string(settings, "start_target")
	pause_target = obs.obs_data_get_string(settings, "pause_target")
end

function script_load(settings)
	local sh = obs.obs_get_signal_handler()
	obs.signal_handler_connect(sh, "source_activate", source_activated)
	obs.signal_handler_connect(sh, "source_deactivate", source_deactivated)
end
