extends Window

const BidwarTeam = preload("res://ScrollerText.tscn")

const SCROLL_RATE: float = 15 # In pixels per second.
const SPACING: float = 3
const COLOR_BAR_MIN: float = 0.0
const COLOR_BAR_MAX: float = 0.9

const COLOR_SATURATION: float = 0.6
const COLOR_VALUE: float = 0.8
const COLOR_HUE_PARTITIONS: int = 10

var upper_offset: float = 0 # Dynamically set by the number and size of scroller entries
var team_list: Array

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if self.visible and self.team_list.size() > 0:
        var max_y: float = 0
        for team in self.team_list:
            team.position.y -= delta*SCROLL_RATE

        var last = self.team_list[-1]
        if last.position.y + last.size.y + SPACING < 0:
            self.reset_scroller_positions()
            # Now uniform shift to the bottom of the window.
            for team in self.team_list:
                team.position.y += self.size.y

        self.update_color_bars()

func update_color_bars():
    var max_points: int = 0
    for team in self.team_list:
        max_points = max(max_points, team.points)

    for team in team_list:
        team.set_color_bar_size(max_points, COLOR_BAR_MIN, COLOR_BAR_MAX)

func _add_team_to_scroller(team_name: String, points: int):
    var new_team = BidwarTeam.instantiate()
    var color_hue = float(self.get_children().size() % COLOR_HUE_PARTITIONS)/float(COLOR_HUE_PARTITIONS)
    var color = Color.from_hsv(color_hue, COLOR_SATURATION, COLOR_VALUE)
    new_team.init(team_name, points, color)
    self.add_child(new_team)
    self.reset_scroller_positions()

func reset_scroller_positions():
    self.team_list = self.get_children()
    self.team_list.sort_custom(_order_teams)

    # First collect how
    self.upper_offset = 0
    for i in range(self.team_list.size()):
        team_list[i].position.y = self.upper_offset
        self.upper_offset += team_list[i].size.y + SPACING
    self.update_color_bars()

func _order_teams(a, b) -> bool:
     return a.points > b.points

func _on_size_changed():
    for team in self.team_list:
        team.size.x = self.size.x
    reset_scroller_positions()
