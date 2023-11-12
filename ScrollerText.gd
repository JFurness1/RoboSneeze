extends Control

var team_name: String
var points: int

func init(team_name: String, points: int):
    self.set_team_name(team_name)
    self.set_points(points)

func set_team_name(new_name: String):
    self.team_name = new_name
    $HBoxContainer/TeamName.text = new_name

func set_points(new_points: int):
    self.points = new_points
    $HBoxContainer/Points.text = str(self.points)

func shift_position(shift: Vector2):
    self.position += shift

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
