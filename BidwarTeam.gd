extends HBoxContainer

var team_name: String = "PLACEHOLDER"
var points: int = 0

signal name_changed(old_name: String, new_name: String)
signal points_changed(name: String, old_points: int, new_points: int)
signal bidwar_team_removal_request(team_name: String, points: int)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _on_delete_button_pressed():
    print("REMOVE REQUESTED")
    bidwar_team_removal_request.emit(self.name, self.points)

func set_details(name: String, points: int):
    self.set_team_name(name)
    self.set_points(points)


func set_points(new_points: int):
    var old_points = self.points
    self.points = new_points
    $CurrentPoints.value = self.points
    if new_points != old_points:
        points_changed.emit(self.team_name, old_points, new_points)


func set_team_name(new_name: String):
    var old_name = self.team_name
    self.team_name = new_name
    $TeamNameInput.text = new_name
    if old_name != new_name:
        name_changed.emit(old_name, new_name)


func _on_change_button_pressed():
    var change = $ChangePoints.value
    self.set_points(points + change)


func _on_current_points_value_changed(value):
    self.set_points(value)


func _on_team_name_input_text_submitted(new_text):
    self.set_team_name(new_text)
