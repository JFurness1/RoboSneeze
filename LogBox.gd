extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func add_message(message: String):
    self.text += "%s\n" % [message]

func _on_mesage_emitted(content: String):
    self.add_message(content)

func _on_gift_twitch_connected():
    self.add_message("Connected to Twitch IRC.")

func _on_gift_user_token_invalid():
    self.add_message("ERROR: User Token invalid.")

func _on_gift_twitch_disconnected():
    self.add_message("Disconnected from Twitch IRC.")

func _on_gift_twitch_unavailable():
    self.add_message("Twitch IRC is unavailable.")
