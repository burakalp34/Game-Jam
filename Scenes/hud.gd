extends Control

@onready var life_label: Label = %LifeLabel
@onready var ammo_label: Label = %AmmoLabel
@onready var dash_label: Label = %DashLabel

func set_health(h:int, max_h:int) -> void:
	life_label.text = "Vie: %d/%d" % [h, max_h]

func set_ammo(am:int, mag:int) -> void:
	ammo_label.text = "Balles: %d/%d" % [am, mag]

func set_dash(ch:int, max_ch:int) -> void:
	dash_label.text = "Dash: %d/%d" % [ch, max_ch]
