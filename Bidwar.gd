extends Control

const BidwarTeam = preload("res://BidwarTeam.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    pass

func add_new_team(name: String, start_points: int) -> bool:
    var new_team = BidwarTeam.instantiate()
    new_team.name = name
    new_team.set_details(name, start_points)
    %TeamList.add_child(new_team)
    return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_add_team_button_pressed():
    # These should be valid as if they were invalid the add button would be disabled.
    var name = %NewTeamNameBox.text
    var start_points = %NewTeamPointsBox.value
    self.add_new_team(name, start_points)
    $VBoxContainer/AddNewContainer/HSplitContainer/NewTeamNameBox.text = ""
    $VBoxContainer/AddNewContainer/HSplitContainer/AddTeamButton.disabled = true
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

    $VBoxContainer/AddNewContainer/HSplitContainer/AddTeamButton.disabled = box_disabled
