extends VBoxContainer

const BidwarUser = preload("res://BidwarUser.tscn")

var team_name: String = "PLACEHOLDER_NAME"
var team_tag: String = "PLACEHOLDER_TAG"
var user_group: String = "PLACEHOLDER_TAG_users"
var points: int = 0
var image_path: String = ""

const MATCH_COLOR = Color.FOREST_GREEN

var unassigned_user: Node

signal name_changed(old_name: String, new_name: String)
signal tag_changed(old_tag: String, new_tag: String)
signal points_changed(name: String, old_points: int, new_points: int)
signal bidwar_team_removal_request(team_name: String, points: int)

# Called when the node enters the scene tree for the first time.
func _ready():
    $UserScroller.visible = false
    self.unassigned_user = self.add_user("Unassigned", 0, false)
    self.unassigned_user.set_disabled()


func _on_delete_button_pressed():
    bidwar_team_removal_request.emit(self.name, self.points)


func set_details(name: String, tag: String, points: int):
    self.set_team_name(name)
    self.set_team_tag(tag)
    self.set_points(points)


func set_points(new_points: int):
    var old_points = self.points
    self.points = new_points
    $Details/CurrentPoints.value = self.points
    if new_points != old_points:
        points_changed.emit(self.team_name, old_points, new_points)
    if unassigned_user:
        update_unassigned()
        sort_users()


func update_unassigned():
    # count points from users
    var user_points = self.count_user_points()
    var unassigned = self.points - user_points
    if unassigned_user:
        unassigned_user.set_points(unassigned)


func count_user_points() -> int:
    var total = 0
    var tree = get_tree()
    if tree:
        for node in tree.get_nodes_in_group(self.user_group):
            total += node.points
    return total


func add_points(points: int, user: String = ""):
    if len(user) > 0:
        var node = get_user_by_name(user)
        if node:
            node.add_points(points)
        else:
            add_user(user, points)
    set_points(self.points + points)


func _on_user_add_points_requested(points: int, user: String):
    add_points(points, user)


func add_user(username: String, points: int, add_to_group: bool = true) -> Node:
    var new_user = BidwarUser.instantiate()
    new_user.init(username, points)
    $UserScroller/UserContainer.add_child(new_user)
    new_user.add_points_requested.connect(_on_user_add_points_requested)
    new_user.removal_requested.connect(remove_user)
    if add_to_group:
        new_user.add_to_group(self.user_group)
        self.sort_users()
    return new_user


func remove_user(username: String):
    var node = get_user_by_name(username)
    if node:
        $UserScroller/UserContainer.remove_child(node)
        node.remove_from_group(user_group)
        add_points(-node.points)
    else:
        printerr("Tried to remove user '%s' from team '%s' and failed to find it." % [username, team_name])


func get_user_by_name(username: String) -> Node:
    for node in get_tree().get_nodes_in_group(self.user_group):
        if node.username == username:
            return node
    return null


func sort_users():
    var tree = get_tree()
    if tree:
        var sorted_users = tree.get_nodes_in_group(self.user_group)
        sorted_users.sort_custom(func(a: Node, b: Node): return a.username < b.username)

        for node in sorted_users:
            $UserScroller/UserContainer.remove_child(node)

        for node in sorted_users:
            $UserScroller/UserContainer.add_child(node)


func set_team_name(new_name: String):
    var old_name = self.team_name
    self.team_name = new_name
    $Details/TeamNameInput.text = new_name
    if old_name != new_name:
        name_changed.emit(old_name, new_name)


func set_team_tag(new_tag: String):
    var old_tag = self.team_tag
    new_tag = sanitize_team_tag(new_tag)
    self.team_tag = new_tag
    $Details/TeamTagInput.text = new_tag
    self.user_group = "%s_users" % new_tag
    if old_tag != new_tag:
        tag_changed.emit(old_tag, new_tag)


func sanitize_team_tag(tag: String):
    tag = tag.replace("#", "")
    tag = tag.replace(" ", "_")
    tag = tag.to_lower()
    return tag


func _on_team_tag_input_text_focus_exit():
    set_team_tag($Details/TeamTagInput.text)


func _on_change_button_pressed():
    var change = $Details/ChangePoints.value
    set_points(points + change)
    var username = $Details/UserInput.text

    # If we have a username then assign to user, otherwise it goes in unassigned
    if username:
        var node = get_user_by_name(username)
        if node:
            node.add_points(change)
        else:
            add_user(username, change)
    update_unassigned()


func _on_current_points_value_changed(value):
    set_points(value)


func _on_team_name_input_text_submitted(new_text):
    set_team_name(new_text)


func _on_team_tag_input_text_submitted(new_text):
    set_team_tag(new_text)


func _on_set_image_button_pressed():
    $Details/ImageSelectDialog.visible = true


func _on_image_select_dialog_close_requested():
    $Details/ImageSelectDialog.visible = false


func _on_image_select_dialog_file_selected(path):
    if not FileAccess.file_exists(path):
        self.image_path = ""
    else:
        var new_image = Image.load_from_file(path)
        var texture = ImageTexture.create_from_image(new_image)
        $Details/TeamImage.texture = texture
        self.image_path = path


func get_data() -> Dictionary:
    var user_dict = Dictionary()
    for node in get_tree().get_nodes_in_group(user_group):
        user_dict[node.username] = node.points

    return {
        "name": self.team_name,
        "tag": self.team_tag,
        "points": self.points,
        "image": self.image_path,
        "users": user_dict
    }


func set_from_data(data: Dictionary):
    self.set_team_name(data['name'])
    print('Data: tag = %s' % data['tag'])
    self.set_team_tag(data['tag'])
    self.set_points(int(data['points']))
    if data['image']:
        self._on_image_select_dialog_file_selected(data['image'])

    for username in data['users']:
        add_user(username, data['users'][username])


func _on_contributors_button_pressed():
    $UserScroller.visible = !$UserScroller.visible


func _on_user_input_text_changed(new_text: String):
    if new_text == "Unassigned":
        $Details/ChangeButton.disabled = true
    else:
        $Details/ChangeButton.disabled = false

    for node in get_tree().get_nodes_in_group(self.user_group):
        if node.username == new_text:
            $Details/UserInput.add_theme_color_override("font_color", MATCH_COLOR)
            return
    $Details/UserInput.remove_theme_color_override("font_color")
