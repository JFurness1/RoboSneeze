extends VBoxContainer

const BidwarTeam = preload("res://BidwarTeam.tscn")

const VISUALISER_WINDOW_DIMENSIONS = Vector2i(1200, 200)

signal message_emitted(sender: String, content: String)
signal remove_requested(to_remove)
signal points_changed(team: String, new_points: int)
signal removed_team(team_name: String, points: int)

var file_name: String
var visuliser_window: Window

# Called when the node enters the scene tree for the first time.
func _ready():
    $VisualisationWindow.hide()

func set_properties(name: String):
    print("Setting Properties")
    self.name = name
    self.file_name = make_filename(name)
    $TitleContainer/Title.text = "%s" % [self.file_name]
    $VisualisationWindow.title = self.name

func make_filename(filename: String) -> String:
    var out = filename.replace(" ", "_")
    var path = DirAccess.open("./").get_current_dir()
    return "%s/%s.txt" % [path, out]

func add_new_team(name: String, start_points: int, update_file: bool = true):
    var new_team = BidwarTeam.instantiate()
    new_team.name = name
    new_team.set_details(name, start_points)
    %TeamList.add_child(new_team)
    new_team.bidwar_team_removal_request.connect(_on_bidwar_team_removal_request)
    new_team.points_changed.connect(save_data)
    $VisualisationWindow._add_team_to_scroller(new_team)
    message_emitted.emit(self.name, "Added team '%s' with points: %d." % [name, start_points])
    if update_file:
        save_data()

func _on_add_team_button_pressed():
    # These should be valid as if they were invalid the add button would be disabled.
    var name = %NewTeamNameBox.text
    var start_points = %NewTeamPointsBox.value
    self.add_new_team(name, start_points)
    $AddNewContainer/HSplitContainer/NewTeamNameBox.text = ""
    $AddNewContainer/HSplitContainer/AddTeamButton.disabled = true
    %NewTeamPointsBox.value = 0

func _on_new_team_name_box_text_changed(new_text):
    var box_disabled: bool = false
    if new_text:
        box_disabled = false
        for team in %TeamList.get_children():
            if team.name == new_text:
                box_disabled = true
                break
    else:
        box_disabled = true

    $AddNewContainer/HSplitContainer/AddTeamButton.disabled = box_disabled

func _on_bidwar_team_removal_request(team_name: String, points: int):
    var found: bool = false
    for team in %TeamList.get_children():
        if team.name == team_name:
            team.queue_free()
            message_emitted.emit(self.name,
                "Removed team '%s' (had %d points)" % [self.name, name, points])
            removed_team.emit(team_name, points)
            found = true
            break
    if not found:
        message_emitted.emit(self.name,
                "WARNING: Failed to find team '%s' for removal." % [name])

func save_data():
    var outfile = FileAccess.open(self.file_name, FileAccess.WRITE)
    outfile.store_string("%s\n" % self.name)
    var teamarray = %TeamList.get_children()
    teamarray.sort_custom(_order_teams)
    for team in teamarray:
        outfile.store_string("%s: %d\n" % [team.team_name, team.points])
    outfile.close()
    message_emitted.emit(self.name, "Data saved to '%s'." % self.file_name)

func load_data(file_name: String) -> bool:
    message_emitted.emit("BidWarLoader", "Attempting to load '%s'." % file_name)
    if FileAccess.file_exists(file_name):
        self.file_name = file_name
        var infile = FileAccess.open(file_name, FileAccess.READ)
        var name = infile.get_line()
        self.set_properties(name)
        var line = infile.get_line()
        while line:
            var bits = line.split(': ', false)
            # Add a new team but don't update the file
            self.add_new_team(bits[0], int(bits[1]), false)
            line = infile.get_line()
        return true
    else:
        message_emitted.emit("BidWarLoader", "Cannot  find '%s'." % file_name)
        return false

func _order_teams(a, b) -> bool:
     return a.points > b.points

func _on_close_button_pressed():
    save_data()
    remove_requested.emit(self)

func _on_visualiser_button_pressed():
    $VisualisationWindow.show()

func _on_visualisation_window_close_requested():
    $VisualisationWindow.hide()
