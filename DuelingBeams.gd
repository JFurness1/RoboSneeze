extends Node2D

var window_size: Vector2i

const EDGE_OFFSET: int = 80  # Sprite offset from edge in pixels
const ARC_OFFSET: int = 10  # Offset of energy arc sprite from center of team sprite in pixels
const BEAM_OFFSET_FROM_ARC: int = -30
const SPRITE_MAX_DIM: int = 150  # Size of the sprite's largest dimension in pixels
const TEXT_OFFSET: int = -10

# Called when the node enters the scene tree for the first time.
func _ready():
    window_size = get_viewport().size

    var img_A = Image.load_from_file("res://Assets/DuelingBeams/Noot.png")
    var tex_A = ImageTexture.create_from_image(img_A)
    $TeamA/TeamSprite.texture = tex_A
    $TeamA/Label.text = "Team Noot"

    var img_B = Image.load_from_file("res://Assets/DuelingBeams/Doot.png")
    var tex_B = ImageTexture.create_from_image(img_B)
    $TeamB/TeamSprite.texture = tex_B

    self.setup_sprites($TeamA, true)
    self.setup_sprites($TeamB, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass

func setup_sprites(team: Node2D, is_left_side: bool):
    var energy_color: Color
    if is_left_side:
        energy_color = Color.PALE_VIOLET_RED
    else:
        energy_color = Color.CYAN

    var offset: float = self.window_size.x/2.0 - EDGE_OFFSET
    if is_left_side:
        offset *= -1

    team.position.x = offset
    var sprite = team.find_child("TeamSprite")
    var max_dim = max(sprite.texture.get_width(), sprite.texture.get_height())
    var scale_fac = SPRITE_MAX_DIM/float(max_dim)
    sprite.scale = Vector2(scale_fac, scale_fac)

    # Set up energy arc
    var arc = team.find_child("EnergyArc")
    arc.position.x = -(SPRITE_MAX_DIM/2.0 + ARC_OFFSET)
    if is_left_side:
        arc.scale.x = -1
        arc.position.x *= -1

    # Shift label
    var label: Label = team.find_child("Label")
    label.position.y = -SPRITE_MAX_DIM/2.0 + TEXT_OFFSET

    # Set beam to center
    var start_point: Vector2 = Vector2(BEAM_OFFSET_FROM_ARC, 0)
    var end_point: Vector2 = Vector2(-int(arc.global_position.x), 0)
    if is_left_side:
        end_point.x *= -1

    team.set_color(energy_color)
    team.spread_beam(start_point, end_point)

    # Collision particles
    var collision_particles = arc.find_child("MeetingParticles")
    collision_particles.position.x = end_point.x

    var collision_sprite: AnimatedSprite2D = arc.find_child("CollisionSprite")
    collision_sprite.position.x = end_point.x

    var animation: String
    if is_left_side:
        animation = "red"
    else:
        animation = "blue"
    collision_sprite.position.y = -collision_sprite.sprite_frames.get_frame_texture(animation, 0).get_size().y/2.0
    collision_sprite.frame = randi_range(0,4)
    collision_sprite.play(animation)


