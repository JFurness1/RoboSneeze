extends Node2D

const BEAM_SEGMENT_COUNT = 10
const BEAM_JIGGLE_RATE_MIN = 0.1
const BEAM_JIGGLE_RATE_MAX = 0.3
const BEAM_JIGGLE_AMPLITUDE = 10.0

var color: Color
var beam_offsets: Array
var beam_elapseds:Array[float]
var beam_remainings: Array[float]
var beam_times: Array[float]

var RNG: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
    self.RNG = RandomNumberGenerator.new()
    self.beam_offsets = []
    for i in range(BEAM_SEGMENT_COUNT):
        %EnergyBeam.add_point(Vector2(i, 0.0))
        self.beam_offsets.append([
            self.RNG.randf_range(-BEAM_JIGGLE_AMPLITUDE, BEAM_JIGGLE_AMPLITUDE),
            self.RNG.randf_range(-BEAM_JIGGLE_AMPLITUDE, BEAM_JIGGLE_AMPLITUDE)
            ])
        self.beam_remainings.append(self.RNG.randf_range(BEAM_JIGGLE_RATE_MIN, BEAM_JIGGLE_RATE_MAX))
        self.beam_elapseds.append(0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    for i in range(BEAM_SEGMENT_COUNT - 1):
        self.beam_elapseds[i] += delta
        if self.beam_elapseds[i] > self.beam_remainings[i]:
            self.beam_remainings[i] = self.RNG.randf_range(BEAM_JIGGLE_RATE_MIN, BEAM_JIGGLE_RATE_MAX)
            self.beam_elapseds[i] = 0.0
            self.beam_offsets[i][0] = self.beam_offsets[i][1]
            self.beam_offsets[i][1] = self.RNG.randf_range(-BEAM_JIGGLE_AMPLITUDE, BEAM_JIGGLE_AMPLITUDE)
        var mu: float = self.beam_elapseds[i]/self.beam_remainings[i]
        %EnergyBeam.points[i].y = mu*self.beam_offsets[i][1] + (1 - mu)*self.beam_offsets[i][0]

func set_color(color: Color):
    self.color = color
    %EnergyBeam.default_color = color

func spread_beam(start: Vector2, end: Vector2):
    var step_x: float = (end.x - start.x)/(BEAM_SEGMENT_COUNT - 1)

    for i in range(BEAM_SEGMENT_COUNT):
        %EnergyBeam.points[i].x = start.x + step_x*i
        if i < BEAM_SEGMENT_COUNT - 1:
            %EnergyBeam.points[i].y = self.beam_offsets[i][0]
        else:
            %EnergyBeam.points[i].y = 0.0
