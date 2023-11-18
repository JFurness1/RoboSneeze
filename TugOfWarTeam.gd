extends HBoxContainer

var team_name: String = "PLACEHOLDER"
var points: int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


func set_details(name: String, points: int):
    self.set_team_name(name)
    self.set_points(points)

func set_points(new_points: int):
    self.points = new_points
    $CurrentPoints.value = self.points

func set_team_name(new_name: String):
    self.team_name = new_name
    $TeamNameInput.text = new_name

func _on_change_button_pressed():
    var change = $ChangePoints.value
    self.set_points(points + change)


func _on_current_points_value_changed(value):
    self.set_points(value)


func _on_team_name_input_text_submitted(new_text):
    self.set_team_name(new_text)
