@tool
extends EditorPlugin

const PROFILE_SET_PATH := "res://addons/run_profile/profiles.tres"

var button: Button
var popup_menu: PopupMenu
var profile_set: RunProfileSet

func _enter_tree():

    # Load profile data
    _load_profiles()

    # Toolbar button
    button = Button.new()
    button.flat = true
    button.tooltip_text = "Run Profiles"
    button.icon = load("res://addons/run_profile/icons/off.png")

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


func _build_popup_menu():
    popup_menu.clear()

    for i in profile_set.profiles.size():
        var profile := profile_set.profiles[i]
        popup_menu.add_icon_item(
            profile.icon,
            profile.display_name,
            i
        )


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
    print("Selected profile:", id)


# ─────────────────────────────────────────────
# Clean up
# ─────────────────────────────────────────────

func _exit_tree():
    if is_instance_valid(button):
        remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, button)
        button.queue_free()



