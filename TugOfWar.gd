extends VBoxContainer

var file_name: String

signal message_emitted(sender: String, content: String)
signal remove_requested(to_remove)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func set_properties(name: String):
    self.name = name
    self.file_name = make_filename(name)
    $TitleContainer/Title.text = "%s" % [self.file_name]
#    $VisualisationWindow.title = self.name
    self.save_data()

func make_filename(filename: String) -> String:
    var out = filename.replace(" ", "_")
    var path = DirAccess.open("./").get_current_dir()
    return "%s/%s_tow.txt" % [path, out]

func _on_close_button_pressed():
    self.save_data()
    message_emitted.emit(self.name, "Panel remove requested.")
    remove_requested.emit(self)

func save_data():
    var outfile = FileAccess.open(self.file_name, FileAccess.WRITE)
    outfile.store_string("%s\n" % self.name)
    outfile.store_string("%s: %d\n" % [%TeamA.team_name, %TeamA.points])
    outfile.store_string("%s: %d\n" % [%TeamB.team_name, %TeamB.points])
    outfile.close()
    message_emitted.emit(self.name, "Data saved to '%s'." % self.file_name)


func _on_team_name_changed(old_name: String, new_name: String):
    message_emitted.emit(self.name, "Team '%s' name changed to '%s'." % [old_name, new_name])


func _on_team_points_changed(name: String, old_points: int, new_points: int):
    message_emitted.emit(self.name, "Team %s points changed from %d to %d." % [name, old_points, new_points])
