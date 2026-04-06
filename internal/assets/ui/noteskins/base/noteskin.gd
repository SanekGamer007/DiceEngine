extends Resource
class_name NoteSkinResource
@export_group("General", "g")
@export var g_is_pixel: bool = false
@export var g_separation: int = 160

@export_group("Notes", "note")
@export var note_frames: Array[SpriteFrames] ## Order: Left, Down, Up, Right.
@export var note_skins: Array[Texture2D] ## Order: Left, Down, Up, Right.
@export var note_scale: Vector2 = Vector2.ONE
@export_group("Sustains", "sust")
@export var sust_body: Array[Texture2D] ## Order: Left, Down, Up, Right.
@export var sust_end: Array[Texture2D] ## Order: Left, Down, Up, Right.
@export_group("Splashes", "splsh")
@export var splsh_frames: SpriteFrames
@export var splsh_scale: Vector2 = Vector2.ONE
