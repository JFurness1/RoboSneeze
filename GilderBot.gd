extends VBoxContainer

const component_name = "ROOT"
const Bidwar = preload("res://Bidwar.tscn")
const TugOfWar = preload("res://TugOfWar.tscn")
const FILE_DIALOG_MIN_SIZE = Vector2i(400, 400)

var bidwar_load_file_dialogue: FileDialog

signal message_emitted(sender: String, message: String)
# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_new_bid_war_name_box_text_changed(new_text: String):
    validate_name_and_set_button(new_text, $NewFeatureGrid/AddNewBidWarButton)

func _on_new_tug_of_war_name_box_text_changed(new_text: String):
    validate_name_and_set_button(new_text, $NewFeatureGrid/AddNewTugOfWarButton)

func validate_name_and_set_button(new_text: String, button: Button) -> bool:
    var box_disabled: bool = false
    if new_text:
        box_disabled = false
        for panel in $TabContainer.get_children():
            if panel.name == new_text:
                box_disabled = true
                break
    else:
        box_disabled = true

    button.disabled = box_disabled
    return not box_disabled

func _on_add_new_bid_war_button_pressed():
    # Input should be valid or box would be disabled.
    var name: String = $NewFeatureGrid/NewBidWarName.text
    var new_bidwar = Bidwar.instantiate()
    new_bidwar.set_properties(name)
    add_panel(new_bidwar)
    $NewFeatureGrid/NewBidWarName.text = ""
    $NewFeatureGrid/AddNewBidWarButton.disabled = true

func _on_add_new_tug_of_war_button_pressed():
    # Input should be valid or box would be disabled.
    var name: String = $NewFeatureGrid/NewTugOfWarName.text
    var new_tug_of_war = TugOfWar.instantiate()
    new_tug_of_war.set_properties(name)
    add_panel(new_tug_of_war)
    $NewFeatureGrid/NewTugOfWarName.text = ""
    $NewFeatureGrid/AddNewTugOfWarButton.disabled = true

func _on_new_bid_war_name_text_submitted(new_text):
    # Match submitting to hitting button
    if validate_name_and_set_button(new_text, $NewFeatureGrid/AddNewBidWarButton):
        _on_add_new_bid_war_button_pressed()
    else:
        if new_text:
            message_emitted.emit(
                component_name,
                "WARNING: Can't create new Bid War as name '%s' already exists." % [new_text])
        else:
            message_emitted.emit(
                component_name,
                "WARNING: Must have a Bid War name."

            )

func _on_new_tug_of_war_name_text_submitted(new_text):
    if validate_name_and_set_button(new_text, $NewFeatureGrid/AddNewTugOfWarButton):
        _on_add_new_tug_of_war_button_pressed()
    else:
        if new_text:
            message_emitted.emit(
                component_name,
                "WARNING: Can't create new Tug of War as name '%s' already exists." % [new_text])
        else:
            message_emitted.emit(
                component_name,
                "WARNING: Must have a Tug of War name.")

func _on_load_bid_war_button_pressed():
    var file_dialog = FileDialog.new()
    file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    file_dialog.title = "Load Bid War"
    file_dialog.access = FileDialog.ACCESS_FILESYSTEM
    file_dialog.set_filters(["*.txt"])
    file_dialog.min_size = FILE_DIALOG_MIN_SIZE
    file_dialog.borderless = false
    file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
    self.add_child(file_dialog)
    file_dialog.visible = true
    file_dialog.file_selected.connect(self._on_load_bid_war_file_selected)
    self.bidwar_load_file_dialogue = file_dialog

func bidwar_path_is_valid(path: String) -> bool:
    for panel in $TabContainer.get_children():
        if panel is TextEdit:
            continue
        else:
            if panel.file_name == path:
                return false
    return true

func _on_load_bid_war_file_selected(path: String):
    self.remove_child(bidwar_load_file_dialogue)
    bidwar_load_file_dialogue.queue_free()

    if not bidwar_path_is_valid(path):
        message_emitted.emit(component_name, "A bidwar with filename '%s' is already running. Cannot load it twice!" % path)
    else:
        var new_bidwar = Bidwar.instantiate()
        if new_bidwar.load_data(path):
            self.add_panel(new_bidwar)
        else:
            message_emitted.emit(component_name, "Failed to read Bid War data from file '%s'" % path)

func add_panel(new_panel):
    $TabContainer.add_child(new_panel)
    new_panel.message_emitted.connect(%LogBox.add_message)
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



