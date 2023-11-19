extends Node


func make_filename(panel_name: String) -> String:
    var filter = RegEx.new()
    filter.compile("[^A-Za-z0-9|_-]")
    var out = panel_name.replace(" ", "_")
    out = filter.sub(out, "", true)
    var path = DirAccess.open("./").get_current_dir()
    return "%s/%s.json" % [path, out]
