extends Node

var mondeComp: int = 0
var enemie: int = 40

func inc(by: int = 1) -> void:
	mondeComp += by

func reset() -> void:
	mondeComp = 0

func minus() -> void:
	enemie -= 1
	
func res() -> void:
	enemie = 40	
