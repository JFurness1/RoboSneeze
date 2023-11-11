extends TextEdit

const root_name: String = "BOT"

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func add_message(sender: String, message: String):
    self.text += "[%s] %s\n" % [sender, message]

func _on_mesage_emitted(sender: String, content: String):
    self.add_message(sender, content)

func _on_gift_twitch_connected():
    self.add_message(root_name, "Connected to Twitch IRC.")

func _on_gift_user_token_invalid():
    self.add_message(root_name, "ERROR: User Token invalid.")

func _on_gift_twitch_disconnected():
    self.add_message(root_name, "Disconnected from Twitch IRC.")

func _on_gift_twitch_unavailable():
    self.add_message(root_name, "Twitch IRC is unavailable.")
