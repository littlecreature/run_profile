@tool
extends EditorPlugin

const PROFILE_SET_PATH := "res://addons/run_profile/profiles.tres"

var button: Button
var popup_menu: PopupMenu
var profile_set: RunProfileSet
var profile_set_original: RunProfileSet


enum WindowMode {
	TOP_LEFT,
	CENTERED,
	CUSTOM_POSITION,
	FORCE_MAXIMISED,
	FORCE_FULLSCREEN
}

func _enter_tree():
	
	# Toolbar button
	button = Button.new()
	button.flat = true
	button.tooltip_text = "Run Profiles"
	button.icon = load("res://addons/run_profile/icons/off.png")
	
	# Load profile data
	_load_profiles()
	
	# Load last selected
	var last_id : int = load_last_selected()
	_mark_selected(last_id)
	change_editor_settings(last_id)

	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, button)

	# Popup menu
	popup_menu = PopupMenu.new()
	button.add_child(popup_menu)

	_build_popup_menu()

	# Signals
	button.pressed.connect(_on_button_pressed)
	popup_menu.id_pressed.connect(_on_menu_selected)

# ─────────────────────────────────────────────
# Profiles
# ─────────────────────────────────────────────

func _load_profiles():
	profile_set = load(PROFILE_SET_PATH)
	assert(profile_set != null)
	
func _mark_selected(id: int) -> void:
	if profile_set.profiles[id] != null:
		profile_set.profiles[id].selected = true
		button.icon = profile_set.profiles[id].icon

func _build_popup_menu():
	popup_menu.clear()

	for i in profile_set.profiles.size():
		var profile := profile_set.profiles[i]
		if !profile.enabled : continue
		var text : String = profile.display_name
		if profile.selected : text += " ✓"
		popup_menu.add_icon_item(
			profile.icon,
			text,
			i
		)
		
func _reset_popup_menu():
	for i in profile_set.profiles.size():
		var profile := profile_set.profiles[i]
		profile.selected = false

# ─────────────────────────────────────────────
# Popup positioning 
# ─────────────────────────────────────────────

func _on_button_pressed():
	var screen_pos := button.get_screen_position()
	var button_size := button.size

	# Show popup roughly where it will be
	popup_menu.popup(Rect2i(
		Vector2i(
			screen_pos.x,
			screen_pos.y + button_size.y
		),
		Vector2i.ZERO
	))

	# Reposition after layout is complete
	call_deferred("_reposition_popup")

func _reposition_popup():

	if not is_instance_valid(popup_menu):
		return
	if not popup_menu.visible:
		return

	var screen_pos := button.get_screen_position()
	var button_size := button.size
	var menu_size := popup_menu.size   

	popup_menu.position = Vector2i(
		screen_pos.x - menu_size.x + button_size.x,         
		screen_pos.y + button_size.y
	)

# ─────────────────────────────────────────────
# Selection
# ─────────────────────────────────────────────

func _on_menu_selected(id: int):
	#print("Selected profile:", id)
	#print(profile_set.profiles[id].mode)
	_reset_popup_menu()
	#profile_set.profiles[id].selected = true
	_mark_selected(id)
	_build_popup_menu()
	
	change_editor_settings(id)
	
	save_selected(id)
	

func save_selected(id: int) -> void:
	#print("Saving profile: ", id)
	var cfg := ConfigFile.new()
	cfg.set_value("run_profile", "last_id", id)
	cfg.save("res://addons/run_profile/settings.cfg")
	
func load_last_selected() -> int:
	var cfg := ConfigFile.new()
	var err := cfg.load("res://addons/run_profile/settings.cfg")
	if err == OK:
		var last_id := cfg.get_value("run_profile", "last_id", null)
		if last_id != null:
			return last_id
	return 0

# ─────────────────────────────────────────────
# Change the editor settings
# ─────────────────────────────────────────────

func change_editor_settings(id : int):
	var profile = profile_set.profiles[id]
	#print(profile.mode)
	#print(profile.custom_position.x)
	#print(profile.custom_position.y)
	if profile.custom_position is not Vector2i:
		profile.custom_position = Vector2i.ZERO

	set_editor_window_mode(profile.mode)
	#if profile.mode == WindowMode.CUSTOM_POSITION:
	set_editor_custom_position(profile.custom_position)

func get_editor_window_mode() -> int:
	var settings := EditorInterface.get_editor_settings()
	return settings.get_setting("run/window_placement/rect")

func set_editor_window_mode(mode : int) -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.set_setting("run/window_placement/rect", mode)

func get_editor_custom_position() -> Vector2i:
	var settings := EditorInterface.get_editor_settings()
	var position : Vector2i = Vector2i.ZERO
	
	if settings.has_setting("run/window_placement/rect_custom_position"):
		position = settings.get_setting("run/window_placement/rect_custom_position")
	#else: print("no pos")
	return position
	
func set_editor_custom_position(position : Vector2i) -> void:
	var settings := EditorInterface.get_editor_settings()
	settings.set_setting("run/window_placement/rect_custom_position", position)
	return
	
# ─────────────────────────────────────────────
# Clean up
# ─────────────────────────────────────────────

func _exit_tree():
	if is_instance_valid(button):
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
		button.queue_free()
