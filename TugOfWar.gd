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

func make_filename(filename: String) -> String:
    var out = filename.replace(" ", "_")
    var path = DirAccess.open("./").get_current_dir()
    return "%s/%s.txt" % [path, out]

func _on_close_button_pressed():
    message_emitted.emit(self.name, "Panel remove requested.")
    remove_requested.emit(self)

