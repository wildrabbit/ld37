package org.wildrabbit.world;


//-------------- PERSISTENCE

class ObjectiveState
{
	public var completed:Bool;
	public var bestValue: Int;
	public var bestFloat:Float;
	public var bestSequence: Array<Int> = new Array<Int>();
	public function new(){}
}
class LevelState
{
	public var objectives:Array<ObjectiveState> = new Array<ObjectiveState>();
	// TODO: Additional stats;
	public function new(){}
}

class WorldStateEntry
{
	private var levelObjectiveTable:Map<Int,LevelState>; // LEVELID => Obj
	public var worldStars (default, null):Int; // Calculated field!	
	public function new(){}
}
class GameWorldState
{
	public var currentWorldIdx:Int;
	public var currentLevelIdx:Int;
	public var worldTable:Map<Int,WorldStateEntry>; // LEVELID => Obj
	public var totalStars (default, null):Int; // Calculated field!	
	
	public function new(){}
}