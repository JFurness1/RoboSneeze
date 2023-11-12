extends HBoxContainer

var team_name: String
var points: int

signal bidwar_team_removal_request(team_name: String, points: int)
signal points_changed(name: String, new_points: int)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func set_team_name(name: String):
    self.team_name = name
    $TeamName.text = name

func set_points(points: int):
    self.points = points
    $CurrentPoints.value = points
    points_changed.emit(self.team_name, self.points)

func set_details(name: String, points: int):
    self.set_team_name(name)
    self.set_points(points)

func _on_change_button_pressed():
    self.set_points(self.points + $ChangePoints.value)

func _on_delete_button_pressed():
    bidwar_team_removal_request.emit(self.name, self.points)


func _on_current_points_value_changed(value):
    self.set_points(value)
