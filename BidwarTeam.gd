extends HBoxContainer

var team_name: String
var points: int

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

func set_details(name: String, points: int):
    self.set_team_name(name)
    self.set_points(points)

func _on_change_button_pressed():
    self.set_points(self.points + $ChangePoints.value)
