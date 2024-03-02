extends VBoxContainer

const component_name = "ROOT"
const Bidwar = preload("res://Bidwar.tscn")

const bidwar_group = "bidwars"

const FILE_DIALOG_MIN_SIZE = Vector2i(400, 400)

var event_load_file_dialogue: FileDialog
var cheer_regex = RegEx.new()
var cheer_count_regex = RegEx.new()
var cheer_team_regex = RegEx.new()

signal message_emitted(sender: String, message: String)

# Called when the node enters the scene tree for the first time.
func _ready():
    $Gift.message_emitted.connect(%Log._on_message_emitted)
    cheer_regex.compile("\\s*Cheer\\d\\d*")
    cheer_count_regex.compile("\\d*$")
    cheer_team_regex.compile("#\\w*")
    #$TabContainer/ChatContainer/ChatLogBox.scroll_vertical = INF
    #%LogBox.scroll_vertical = INF

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
        var tree = get_tree()
        if tree:
            for panel in tree.get_nodes_in_group(bidwar_group):
                if panel.file_name == new_path:
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
    var tree = get_tree()
    if tree:
        for panel in tree.get_nodes_in_group(bidwar_group):
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
    new_panel.add_to_group(bidwar_group)
    new_panel.message_emitted.connect(%Log._on_message_emitted)
    new_panel.remove_requested.connect(self.remove_panel)
    message_emitted.emit(
        component_name,
        "Added new panel: '%s'." % [new_panel.name])

func remove_panel(panel):
    $TabContainer.remove_child(panel)
    panel.remove_from_group(bidwar_group)
    message_emitted.emit(
        component_name,
        "Removed panel: '%s'." % [panel.name])
    panel.queue_free()

func _on_gift_twitch_connected():
    $ConnectButton.disabled = true

func _on_gift_twitch_disconnected():
    $ConnectButton.disabled = false

func _on_gift_chat_message(sender_data: SenderData, message: String):
    var contains = parse_chat_message(sender_data, message)

    if contains['has_cheers']:
        if len(contains['team_names']) > 0:
            message_emitted.emit(component_name, "%s cheered %d for teams: %s" % [sender_data['user'], contains['cheer_count'], contains['team_names']])
        else:
            message_emitted.emit(component_name, "%s cheered %d but no team provided." % [sender_data['user'], contains['cheer_count']])
    add_cheer_to_teams(contains)

func parse_chat_message(sender_data: SenderData, message: String) -> Dictionary:
    var components = Dictionary()
    var cheers = cheer_regex.search_all(message)

    components['user'] = sender_data['user']
    components['has_cheers'] = len(cheers) > 0

    components['cheer_count'] = 0
    for part in cheers:
        var count = cheer_count_regex.search(part.get_string()).get_string()
        components['cheer_count'] += int(count)

    var teams = cheer_team_regex.search_all(message)

    components['team_names'] = []
    for t in teams:
        components['team_names'].append(t.get_string().to_lower())

    return components

func add_cheer_to_teams(contents: Dictionary):
    var tree = get_tree()
    if tree:
        for panel in tree.get_nodes_in_group(bidwar_group):
            panel.add_cheer_to_teams(contents)
