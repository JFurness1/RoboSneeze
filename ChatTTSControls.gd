extends HBoxContainer

var read_chat: bool = false
var voices: PackedStringArray

func _ready():
    $TTSSliders/SpeedContainer/CurrentSpeedLabel.text = "%d" % $TTSSliders/SpeedContainer/WordRateSlider.value
    $TTSSliders/VolumeContainer/CurrentVolumeLabel.text = "%d" % $TTSSliders/VolumeContainer/VolumeSlider.value
    $TTSSliders/PitchContainer/CurrentPitchLabel.text = "%d" % $TTSSliders/PitchContainer/PitchSlider.value

    voices = DisplayServer.tts_get_voices_for_language("en")

    for voice in voices:
        var voice_str = voice.split('\\')[-1]
        $VoiceList.add_item(voice_str)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_tts_start_stop_pressed():
    if read_chat:
        read_chat = false
        $TTSStartStop.text = "Start"
        DisplayServer.tts_stop()
    else:
        read_chat = true
        $TTSStartStop.text = "Pls Stop"


func _on_gift_chat_message(sender_data, message):
    if not read_chat:
        return

    # Consider this for TTS https://github.com/DougDougGithub/ChatGodApp/blob/main/azure_text_to_speech.py

    DisplayServer.tts_stop()
    var voice_is = voices[$VoiceList.selected]
    var rate = $TTSSliders/SpeedContainer/WordRateSlider.value
    var volume = $TTSSliders/VolumeContainer/VolumeSlider.value
    var pitch = $TTSSliders/PitchContainer/PitchSlider.value
    DisplayServer.tts_speak(message, voice_is, volume, pitch, rate)

func _on_volume_slider_value_changed(value):
    $TTSSliders/VolumeContainer/CurrentVolumeLabel.text = "%.1f" % $TTSSliders/VolumeContainer/VolumeSlider.value


func _on_word_rate_slider_value_changed(value):
    $TTSSliders/SpeedContainer/CurrentSpeedLabel.text = "%.1f" % $TTSSliders/SpeedContainer/WordRateSlider.value


func _on_pitch_slider_value_changed(value):
    $TTSSliders/PitchContainer/CurrentPitchLabel.text = "%.1f" % $TTSSliders/PitchContainer/PitchSlider.value
