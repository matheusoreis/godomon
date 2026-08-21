extends Node


const MAPS_DATA_DIRECTORY: String = "res://data/maps/"


const DATABASE_PATH: String = "user://database/"
const DATABASE_FILENAME: String = "database"
const DATABASE_POLL_TIME: int = 1


const NETWORK_HOST: String = "0.0.0.0"
const NETWORK_PORT: int = 7001


const MAX_PEERS: int = 100


const CELL_SIZE: int = 32

const CELL_NONE: int = 0
const CELL_FULL_BLOCK: int = 1
const CELL_UP: int = 2
const CELL_RIGHT: int = 4
const CELL_DOWN: int = 8
const CELL_LEFT: int = 16


const START_MAP: int = 0
const START_MAP_POSITION: Vector2i = Vector2i(68, 64)
const START_MAP_FACING: Vector2i = Vector2i.DOWN


const AVALIABLE_SPRITES: Array[String] = ["red"]


const IDENTIFIER_REGEX: String = ""
const EMAIL_REGEX: String = ""
const PASSWORD_REGEX: String = ""
