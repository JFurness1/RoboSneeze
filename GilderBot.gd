extends Control

const component_name = "ROOT"
const Bidwar = preload("res://Bidwar.tscn")

signal message_emitted(sender: String, message: String)
# Called when the node enters the scene tree for the first time.
func _ready():
    pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func _on_new_bid_war_name_box_text_changed(new_text: String):
    validate_name_and_set_button(new_text, %AdminRoot/NewFeatureGrid/AddNewBidWarButton)

func _on_new_tug_of_war_name_box_text_changed(new_text: String):
    validate_name_and_set_button(new_text, %AdminRoot/NewFeatureGrid/AddNewTugOfWarButton)

func validate_name_and_set_button(new_text: String, button: Button) -> bool:
    var box_disabled: bool = false
    if new_text:
        box_disabled = false
        for panel in %AdminRoot/TabContainer.get_children():
            if panel.name == new_text:
                box_disabled = true
                break
    else:
        box_disabled = true

    button.disabled = box_disabled
    return not box_disabled

func _on_add_new_bid_war_button_pressed():
    # Input should be valid or box would be disabled.
    var name: String = %AdminRoot/NewFeatureGrid/NewBidWarName.text
    var new_bidwar = Bidwar.instantiate()
    new_bidwar.set_properties(name)
    %AdminRoot/TabContainer.add_child(new_bidwar)
    message_emitted.emit(component_name, "Added new bid war: '%s'." % [name])
    %AdminRoot/NewFeatureGrid/NewBidWarName.text = ""
    %AdminRoot/NewFeatureGrid/AddNewBidWarButton.disabled = true


func _on_new_bid_war_name_text_submitted(new_text):
    # Match submitting to hitting button
    if validate_name_and_set_button(new_text, %AdminRoot/NewFeatureGrid/AddNewBidWarButton):
        _on_add_new_bid_war_button_pressed()
    else:
        if new_text:
            message_emitted.emit(
                component_name,
                "WARNING: Can't create new Bid War as name '%s' already exists." % [new_text])
        else:
            message_emitted.emit(
                component_name,
                "WARNING: Must have a Bid War name."

            )

func _on_new_tug_of_war_name_text_submitted(new_text):
    pass # Replace with function body.
