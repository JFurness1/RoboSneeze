extends VBoxContainer

const BidwarTeam = preload("res://BidwarTeam.tscn")

const VISUALISER_WINDOW_DIMENSIONS = Vector2i(1200, 200)

const panel_style: String = "BIDWAR"

signal message_emitted(sender: String, content: String)
signal remove_requested(to_remove)
signal points_changed(team: String, new_points: int)

var file_name: String
var text_file_name: String
var visuliser_window: Window

# Called when the node enters the scene tree for the first time.
func _ready():
    $VisualisationWindow.hide()

func set_properties(name: String, filename: String):
    self.name = name
    self.file_name = filename
    self.text_file_name = self.file_name.replace(".json", ".txt")
    $TitleContainer/Title.text = "%s" % [self.file_name]
    $VisualisationWindow.title = self.name


func add_team_to_list(new_team):
    %TeamList.add_child(new_team)
    new_team.bidwar_team_removal_request.connect(_on_bidwar_team_removal_request)
    new_team.points_changed.connect(save_data)
    $VisualisationWindow._add_team_to_scroller(new_team)
    message_emitted.emit(self.name, "Added team '%s' with points: %d." % [new_team.team_name, new_team.points])


func add_new_team(name: String, start_points: int, update_file: bool = true):
    var new_team = BidwarTeam.instantiate()
    new_team.name = name
    new_team.set_details(name, start_points)
    self.add_team_to_list(new_team)
    if update_file:
        save_data()

func add_new_team_from_data(data: Dictionary):
    var new_team = BidwarTeam.instantiate()
    new_team.set_from_data(data)
    self.add_team_to_list(new_team)

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
                "Removed team '%s' (had %d points)" % [team_name, points])
            found = true
            break
    if not found:
        message_emitted.emit(self.name,
                "WARNING: Failed to find team '%s' for removal." % name)

func save_data():
    var outfile = FileAccess.open(self.text_file_name, FileAccess.WRITE)
    var teamnodes = %TeamList.get_children()
    teamnodes.sort_custom(_order_teams)
    var teams: Array = []
    for team in teamnodes:
        teams.append(team.get_data())

    if outfile:
        for team in teams:
            outfile.store_string("%s: %d\n" % [team['name'], team['points']])
        message_emitted.emit(self.name, "Scores saved to '%s'." % self.text_file_name)
        outfile.close()
    else:
        message_emitted.emit(self.name, "Failed to open file '%s' for writing." % self.text_file_name)

    var datfile = FileAccess.open(self.file_name, FileAccess.WRITE)
    if datfile:
        var outdict = {
            'name': self.name,
            'type': self.panel_style,
            'teams': teams
            }
        datfile.store_string(JSON.stringify(outdict))
        datfile.close()
    else:
        message_emitted.emit(self.name, "Failed to open file '%s' for writing." % self.file_name)

func set_from_data(data: Dictionary, file_name: String):
    self.set_properties(data['name'], file_name)
    for team in data['teams']:
        self.add_new_team_from_data(team)

func _order_teams(a, b) -> bool:
     return a.points > b.points

func _on_close_button_pressed():
    save_data()
    remove_requested.emit(self)

func _on_visualiser_button_pressed():
    size_visulaiser_from_inputs()
    $VisualisationWindow.show()

func size_visulaiser_from_inputs():
    $VisualisationWindow.size = Vector2i(
        $VisualisationOptions/WindowWidthInput.value,
        $VisualisationOptions/WindowHeightInput.value
        )

func _on_visualisation_window_close_requested():
    $VisualisationWindow.hide()

func _on_window_width_input_value_changed(value):
    $VisualisationWindow.size.x = int(value)

func _on_window_height_input_value_changed(value):
     $VisualisationWindow.size.y = int(value)
