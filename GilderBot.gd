extends VBoxContainer

const component_name = "ROOT"
const Bidwar = preload("res://Bidwar.tscn")

const FILE_DIALOG_MIN_SIZE = Vector2i(400, 400)

var event_load_file_dialogue: FileDialog

signal message_emitted(sender: String, message: String)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_new_event_name_text_changed(new_text: String):
    validate_name_and_set_button(new_text)

func validate_name_and_set_button(new_text: String) -> bool:
    var box_disabled: bool = false

    if new_text:
        var new_path = Globals.make_filename(new_text)
        box_disabled = false
        for panel in $TabContainer.get_children():
            if not (panel is TextEdit) and panel.file_name == new_path:
                box_disabled = true
                break
        if FileAccess.file_exists(new_path):
            box_disabled = true
    else:
        box_disabled = true

    $NewEventHBox/AddNewEventButton.disabled = box_disabled
    return not box_disabled

func _reset_add_buttons():
    $NewEventHBox/NewEventName.text = ""
    $NewEventHBox/AddNewEventButton.disabled = true

func _on_add_new_event_button_pressed():
    # Input should be valid or box would be disabled.
    var name: String = $NewEventHBox/NewEventName.text
    var new_bidwar = Bidwar.instantiate()
    new_bidwar.set_properties(name, Globals.make_filename(name))
    add_panel(new_bidwar)
    _reset_add_buttons()

func _on_new_event_name_text_submitted(new_text):
    # Match submitting to hitting button
    if validate_name_and_set_button(new_text):
        _on_add_new_event_button_pressed()
    else:
        if new_text:
            message_emitted.emit(
                component_name,
                "WARNING: Can't create new Event as name '%s' already exists." % [new_text])
        else:
            message_emitted.emit(
                component_name,
                "WARNING: Must have an Event name.")

func _on_load_event_button_pressed():
    var file_dialog = FileDialog.new()
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    file_dialog.title = "Load Event"
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.set_filters(["*.json"])
    file_dialog.min_size = FILE_DIALOG_MIN_SIZE
    file_dialog.borderless = false
    file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
    self.add_child(file_dialog)
    file_dialog.visible = true
    file_dialog.file_selected.connect(self._on_load_event_file_selected)
    self.event_load_file_dialogue = file_dialog

func event_path_is_valid(path: String) -> bool:
    for panel in $TabContainer.get_children():
        if panel is TextEdit:
            continue
        else:
            if panel.file_name == path:
                return false
    return true

func _on_load_event_file_selected(path: String):
    self.remove_child(event_load_file_dialogue)
    event_load_file_dialogue.queue_free()

    if not event_path_is_valid(path):
        message_emitted.emit(component_name, "An event with filename '%s' is already running. Cannot load it twice!" % path)
    else:
        var new_bidwar = Bidwar.instantiate()
        var datafile = FileAccess.open(path, FileAccess.READ)
        if datafile:
            new_bidwar.set_from_data(JSON.parse_string(datafile.get_as_text()), path)
            self.add_panel(new_bidwar)
        else:
            message_emitted.emit(component_name, "Failed to read event data from file '%s'" % path)

func add_panel(new_panel):
    $TabContainer.add_child(new_panel)
    new_panel.message_emitted.connect(%LogBox._on_message_emitted)
    new_panel.remove_requested.connect(self.remove_panel)
    message_emitted.emit(
        component_name,
        "Added new panel: '%s'." % [new_panel.name])

func remove_panel(panel):
    $TabContainer.remove_child(panel)
    message_emitted.emit(
        component_name,
        "Removed panel: '%s'." % [panel.name])
    panel.queue_free()

