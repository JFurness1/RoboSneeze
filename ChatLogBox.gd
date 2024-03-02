extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func add_message(message: String):
    self.text += "%s\n" % [message]
    var cl = get_line_count()
    set_caret_line(cl)

func _on_gift_chat_message(sender_data: SenderData, message: String):
    self.add_message("[%s]: %s" % [sender_data.user, message])
