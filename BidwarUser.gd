extends HBoxContainer

var username: String = "PLACEHOLDER"
var points: int = 0

signal add_points_requested(points: int, username: String)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func init(username: String, points: int):
    set_username(username)
    set_points(points)


func set_username(username: String):
    self.username = username
    $UsernameLabel.text = username


func set_points(points: int):
    self.points = points
    $CurrentPoints.value = points
    $ModifyPoints.value = 0

func add_points(points: int):
    set_points(self.points + points)

func set_disabled():
    $CurrentPoints.editable = false
    $ModifyPoints.editable = false
    $AddButton.disabled = true
    $DeleteButton.disabled = true


func _on_add_button_pressed():
    var points = $ModifyPoints.value
    add_points_requested.emit(points, username)
