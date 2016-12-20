package org.wildrabbit.world;

/**
 * ...
 * @author ith1ldin
 */

enum ObjectiveType
{
	MAX_TILES_PLACED;
	ALL_TILES_PLACED;
	MAX_BUMPS;
	MAX_TIME;
	MIN_ITEMS;
	ALL_ITEMS;
	COMPLETE_SEQUENCE;
}

class ObjectiveData
{
	public var type:ObjectiveType;
	public var value:Int;
	public var paramIdentifier:Int;
	public var sequenceIdentifiers:Array<Int>;
}

class LevelObjectiveData
{
	public static inline var NUM_OBJECTIVES: Int = 3;
	var objective:Array<ObjectiveData>;
}

class SaveInfo
{
	private var objectiveState:Map<Int,ObjectiveState>; // LEVELID => Obj
	public var totalStars (default,null):Int; // Calculated field!	
}