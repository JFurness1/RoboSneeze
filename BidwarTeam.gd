extends HBoxContainer

var team_name: String = "PLACEHOLDER_NAME"
var team_tag: String = "PLACEHOLDER_TAG"
var points: int = 0
var image_path: String = ""

var user_contributions = Dictionary()

signal name_changed(old_name: String, new_name: String)
signal tag_changed(old_tag: String, new_tag: String)
signal points_changed(name: String, old_points: int, new_points: int)
signal bidwar_team_removal_request(team_name: String, points: int)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass


func _on_delete_button_pressed():
    bidwar_team_removal_request.emit(self.name, self.points)


func set_details(name: String, tag: String, points: int):
    self.set_team_name(name)
    self.set_team_tag(tag)
    self.set_points(points)


func set_points(new_points: int):
    var old_points = self.points
    self.points = new_points
    $CurrentPoints.value = self.points
    if new_points != old_points:
        points_changed.emit(self.team_name, old_points, new_points)


func add_points(points: int, user: String = ""):
    set_points(self.points + points)
    if len(user) > 0:
        if self.user_contributions.has(user):
            self.user_contributions[user] += points
        else:
            self.user_contributions[user] = points
    for u in self.user_contributions:
        print("User: %s has contributed %d to this team." % [u, self.user_contributions[u]])


func set_team_name(new_name: String):
    var old_name = self.team_name
    self.team_name = new_name
    $TeamNameInput.text = new_name
    if old_name != new_name:
        name_changed.emit(old_name, new_name)


func set_team_tag(new_tag: String):
    var old_tag = self.team_tag
    new_tag = sanitize_team_tag(new_tag)
    self.team_tag = new_tag
    $TeamTagInput.text = new_tag
    if old_tag != new_tag:
        tag_changed.emit(old_tag, new_tag)


func sanitize_team_tag(tag: String):
    tag = tag.replace("#", "")
    tag = tag.replace(" ", "_")
    tag = tag.to_lower()
    return tag


func _on_team_tag_input_text_focus_exit():
    set_team_tag($TeamTagInput.text)


func _on_change_button_pressed():
    var change = $ChangePoints.value
    self.set_points(points + change)


func _on_current_points_value_changed(value):
    self.set_points(value)


func _on_team_name_input_text_submitted(new_text):
    self.set_team_name(new_text)


func _on_team_tag_input_text_submitted(new_text):
    self.set_team_tag(new_text)


func _on_set_image_button_pressed():
    $ImageSelectDialog.visible = true


func _on_image_select_dialog_close_requested():
    $ImageSelectDialog.visible = false


func _on_image_select_dialog_file_selected(path):
    if not FileAccess.file_exists(path):
        self.image_path = ""
    else:
        var new_image = Image.load_from_file(path)
        var texture = ImageTexture.create_from_image(new_image)
        $TextureRect.texture = texture
        self.image_path = path


func get_data() -> Dictionary:
    return {
        "name": self.team_name,
        "tag": self.team_tag,
        "points": self.points,
        "image": self.image_path
    }


func set_from_data(data: Dictionary):
    self.set_team_name(data['name'])
    print('Data: tag = %s' % data['tag'])
    self.set_team_tag(data['tag'])
    self.set_points(int(data['points']))
    if data['image']:
        self._on_image_select_dialog_file_selected(data['image'])
