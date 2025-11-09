extends Node2D

@onready var txt: Label = $DeathText

func _ready() -> void:
	txt.text = "\nMondes complétés : %d" % Data.mondeComp
