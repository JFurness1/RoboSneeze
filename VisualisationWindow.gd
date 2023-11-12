extends Window

const BidwarTeam = preload("res://ScrollerText.tscn")

const SCROLL_RATE: float = 10 # In pixels per second.
const SPACING: float = 3

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
            for team in self.team_list:
                team.position.y += self.size.y

func _add_team_to_scroller(team_name: String, points: int):
    var new_team = BidwarTeam.instantiate()
    new_team.init(team_name, points)
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

func _order_teams(a, b) -> bool:
     return a.points > b.points
