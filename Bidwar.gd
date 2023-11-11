extends Control

const BidwarTeam = preload("res://BidwarTeam.tscn")

signal message_emitted(sender: String, content: String)

var file_name: String
# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func set_properties(name: String):
    self.name = name
    $VBoxContainer/Title.text = name
    self.file_name = make_filename(name)

func make_filename(filename: String) -> String:
    var out = filename.replace(" ", "_")
    return out + ".txt"

func add_new_team(name: String, start_points: int):
    var new_team = BidwarTeam.instantiate()
    new_team.name = name
    new_team.set_details(name, start_points)
    %TeamList.add_child(new_team)
    new_team.bidwar_team_removal_request.connect(_on_bidwar_team_removal_request)
    new_team.points_changed.connect(save_data)
    save_data()

func _on_add_team_button_pressed():
    # These should be valid as if they were invalid the add button would be disabled.
    var name = %NewTeamNameBox.text
    var start_points = %NewTeamPointsBox.value
    self.add_new_team(name, start_points)
    $VBoxContainer/AddNewContainer/HSplitContainer/NewTeamNameBox.text = ""
    $VBoxContainer/AddNewContainer/HSplitContainer/AddTeamButton.disabled = true
    %NewTeamPointsBox.value = 0
    message_emitted.emit(self.name, "Added team '%s'" % [name])

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

    $VBoxContainer/AddNewContainer/HSplitContainer/AddTeamButton.disabled = box_disabled

func _on_bidwar_team_removal_request(team_name: String, points: int):
    var found: bool = false
    for team in %TeamList.get_children():
        if team.name == team_name:
            team.queue_free()
            message_emitted.emit(self.name,
                "Removed team '%s' (had %d points)" % [self.name, name, points])
            found = true
            break
    if not found:
        message_emitted.emit(self.name,
                "WARNING: Failed to find team '%s' for removal." % [name])

func save_data():
    var outfile = FileAccess.open(self.file_name, FileAccess.WRITE)
    for team in %TeamList.get_children():
        outfile.store_string("%s: %d\n" % [team.team_name, team.points])
    outfile.close()
    message_emitted.emit(self.name, "Data saved to '%s'." % self.file_name)
