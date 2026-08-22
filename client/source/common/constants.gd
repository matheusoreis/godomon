extends Node


const CHARACTER_SPRITE_DIRECTORY: String = "res://assets/gfx/characters/"


const NETWORK_HOST: String = "127.0.0.1"
const NETWORK_PORT: int = 7001


const CELL_SIZE: int = 32

const CELL_NONE: int = 0
const CELL_FULL_BLOCK: int = 1
const CELL_UP: int = 2
const CELL_RIGHT: int = 4
const CELL_DOWN: int = 8
const CELL_LEFT: int = 16


const DIRECTION_SPRITE_ROW: Dictionary[Vector2i, int] = {
	Vector2i.DOWN: 0,
	Vector2i.LEFT: 2,
	Vector2i.RIGHT: 3,
	Vector2i.UP: 1,
}


const IDENTIFIER_REGEX: String = ""
const EMAIL_REGEX: String = ""
const PASSWORD_REGEX: String = ""


const SPRITESHEET_COLUMNS: int = 3
const SPRITESHEET_ROWS: int = 4

const WALKING_SPEED: float = 5.0

const ANIMATION_STEP_THRESHOLD: float = 0.5
const MAX_PENDING_MOVES: int = 8
