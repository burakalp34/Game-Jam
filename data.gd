extends Node

var mondeComp: int = 0

func inc(by: int = 1) -> void:
	mondeComp += by

func reset() -> void:
	mondeComp = 0
