extends Gift

var AUTH_FILENAME: String = "./auth.txt"

const component_name: String = "TWITCH"

signal message_emitted(sender: String, content: String)

func _ready() -> void:
    cmd_no_permission.connect(no_permission)
    chat_message.connect(on_chat)
    event.connect(on_event)

    read_saved_auth_data()

func _on_connect_button_pressed():
    # When calling this method, a browser will open.
    # Log in to the account that should be used.

    client_id = %LoginGridContainer/ClientIDInput.text
    client_secret = %LoginGridContainer/SecretInput.text
    var initial_channel = %LoginGridContainer/ChannelInput.text

    message_emitted.emit(component_name, "Attempting to connect to Twitch IRC")

    await(authenticate(client_id, client_secret))
    var success = await(connect_to_irc())
    if (success):
        request_caps()
        join_channel(initial_channel)
        await(channel_data_received)
    await(connect_to_eventsub()) # Only required if you want to receive EventSub events.
    # Refer to https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/ for details on
    # what events exist, which API versions are available and which conditions are required.
    # Make sure your token has all required scopes for the event.

    # We want to connect to the cheer event.
    # First get the streamer's details.
    var streamer = await(user_data_by_name(initial_channel))
    if streamer.has('id'):
        subscribe_event("channel.cheer", 1, {"broadcaster_user_id": streamer['id']})
        message_emitted.emit(component_name, "Successfully fetched streamer information for \"%s\"." % [streamer['display_name']])
    else:
        message_emitted.emit(component_name, "Failed to fetch streamer information for %s." % initial_channel)

#    # Adds a command with a specified permission flag.
#    # All implementations must take at least one arg for the command info.
#    # Implementations that recieve args requrires two args,
#    # the second arg will contain all params in a PackedStringArray
#    # This command can only be executed by VIPS/MODS/SUBS/STREAMER
#    add_command("test", command_test, 0, 0, PermissionFlag.NON_REGULAR)
#
#    # These two commands can be executed by everyone
#    add_command("helloworld", hello_world)
#    add_command("greetme", greet_me)
#
#    # This command can only be executed by the streamer
#    add_command("streamer_only", streamer_only, 0, 0, PermissionFlag.STREAMER)
#
#    # Command that requires exactly 1 arg.
#    add_command("greet", greet, 1, 1)
#
#    # Command that prints every arg seperated by a comma (infinite args allowed), at least 2 required
#    add_command("list", list, -1, 2)
#
#    # Adds a command alias
#    add_alias("test","test1")
#    add_alias("test","test2")
#    add_alias("test","test3")
#    # Or do it in a single line
#    # add_aliases("test", ["test1", "test2", "test3"])
#
#    # Remove a single command
#    remove_command("test2")
#
#    # Now only knows commands "test", "test1" and "test3"
#    remove_command("test")
#    # Now only knows commands "test1" and "test3"
#
#    # Remove all commands that call the same function as the specified command
#    purge_command("test1")
    # Now no "test" command is known

    # Send a chat message to the only connected channel (<channel_name>)
    # Fails, if connected to more than one channel.
#	chat("TEST")

    # Send a chat message to channel <channel_name>
#	chat("TEST", initial_channel)

    # Send a whisper to target user (requires user:manage:whispers scope)
#	whisper("TEST", initial_channel)

func on_event(type : String, data : Dictionary) -> void:
    match(type):
        "channel.follow":
            print("%s followed your channel!" % data["user_name"])
        "channel.cheer":
            print("%s just cheered!" % data["user_name"])

func on_chat(data : SenderData, msg : String) -> void:
    pass

# Check the CommandInfo class for the available info of the cmd_info.
func command_test(cmd_info : CommandInfo) -> void:
    print("A")

func hello_world(cmd_info : CommandInfo) -> void:
    chat("HELLO WORLD!")

func streamer_only(cmd_info : CommandInfo) -> void:
    chat("Streamer command executed")

func no_permission(cmd_info : CommandInfo) -> void:
    chat("NO PERMISSION!")

func greet(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
    chat("Greetings, " + arg_ary[0])

func greet_me(cmd_info : CommandInfo) -> void:
    chat("Greetings, " + cmd_info.sender_data.tags["display-name"] + "!")

func list(cmd_info : CommandInfo, arg_ary : PackedStringArray) -> void:
    var msg = ""
    for i in arg_ary.size() - 1:
        msg += arg_ary[i]
        msg += ", "
    msg += arg_ary[arg_ary.size() - 1]
    chat(msg)

func save_auth_data(initial_channel: String):
    message_emitted.emit(component_name, "Saving auth data to: '%s'" % AUTH_FILENAME)

    var authfile := FileAccess.open(AUTH_FILENAME, FileAccess.WRITE)
    authfile.store_string("%s\n%s\n%s\n" % [client_id, client_secret, initial_channel])
    authfile.close()
    message_emitted.emit(component_name, "Auth data saved." % AUTH_FILENAME)


func read_saved_auth_data():
    if FileAccess.file_exists(AUTH_FILENAME):
        message_emitted.emit(component_name, "Loading auth data from %s" % AUTH_FILENAME)
        var authfile := FileAccess.open(AUTH_FILENAME, FileAccess.READ)
        var client_id = authfile.get_line()
        var client_secret = authfile.get_line()
        var initial_channel = authfile.get_line()
        print("cid: %s, cs: %s, ic: %s" % [client_id, client_secret, initial_channel])
        # Populate the login boxes
        %LoginGridContainer/ClientIDInput.text = client_id
        %LoginGridContainer/SecretInput.text = client_secret
        %LoginGridContainer/ChannelInput.text = initial_channel
    else:
        message_emitted.emit(component_name, "Auth data file does not exist at %s" % AUTH_FILENAME)

