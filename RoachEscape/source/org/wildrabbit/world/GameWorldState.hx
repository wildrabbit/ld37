package org.wildrabbit.world;
import flixel.util.FlxSave;
import org.wildrabbit.roach.Reg;


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
	public var levelObjectiveTable:Map<Int,LevelState>; // LEVELID => Obj
	public var worldStars (get, null):Int; // Calculated field!	
	
	function get_worldStars():Int
	{
		var amount:Int = 0;
		for (key in levelObjectiveTable.keys())
		{
			for (obj in levelObjectiveTable[key].objectives)
			{
				if (obj.completed)
				{
					amount++;
				}
			}
		}
		return amount;
	}
	public function new(){}
}
class GameWorldState
{
	public static inline var SAVE_SLOT:String = "RoachEscape.sav";

	public var currentWorldIdx:Int;
	public var currentLevelIdx:Int;
	public var worldTable:Map<Int,WorldStateEntry>; // LEVELID => Obj
	public var totalStars (get, null):Int; // Calculated field!	
	public var saveFile:FlxSave;
	
	function get_totalStars():Int
	{
		var amount:Int = 0;
		for (key in worldTable.keys())
		{
			amount += worldTable[key].worldStars;
		}
		return amount;
	}
	
	public function new() 
	{
		saveFile = new FlxSave();
	}

	public function load():Void
	{
		saveFile.bind(SAVE_SLOT);
		
		currentWorldIdx = saveFile.data.worldIdx;
		currentLevelIdx = saveFile.data.levelIdx;
		
		worldTable = null;
		worldTable = new Map<Int,WorldStateEntry>();
		var worldData:Dynamic = saveFile.data.worldTable.h;		
		if (worldData == null) return;
		
		for (key in Reflect.fields(worldData))
		{
			var worldState:WorldStateEntry = new WorldStateEntry();
			worldState.levelObjectiveTable = new Map<Int,LevelState>();
			
			var iKey:Int = Std.parseInt(key);
			var levelObjData:Dynamic = worldData[iKey].levelObjectiveTable.h;
			for (levelKey in Reflect.fields(levelObjData))
			{
				var iLevelKey:Int = Std.parseInt(levelKey);
				var levelState:LevelState = new LevelState();
				var array:Array<Dynamic> = levelObjData[iLevelKey].objectives;
				for (obj in array)
				{
					var objState:ObjectiveState = new ObjectiveState();
					objState.completed = obj.completed;
					objState.bestFloat = obj.bestFloat;
					objState.bestValue = obj.bestValue;
					objState.bestSequence = obj.bestSequence.copy();
					levelState.objectives.push(objState);
				}
				worldState.levelObjectiveTable[iLevelKey] = levelState;
			}			
			worldTable[iKey] = worldState;
		}		

	}
	
	public function save():Void
	{
		saveFile.bind(SAVE_SLOT);
		saveFile.data.worldIdx = currentWorldIdx;
		saveFile.data.levelIdx = currentLevelIdx;
		var saveTable:Map<Int,WorldStateEntry> = new Map<Int,WorldStateEntry>();
		for (key in worldTable.keys())
		{
			var worldState:WorldStateEntry = new WorldStateEntry();
			worldState.levelObjectiveTable = new Map<Int,LevelState>();
			for (levelKey in worldTable[key].levelObjectiveTable.keys())
			{
				var levelState:LevelState = new LevelState();
				for (obj in worldTable[key].levelObjectiveTable[levelKey].objectives)
				{
					var objState:ObjectiveState = new ObjectiveState();
					objState.completed = obj.completed;
					objState.bestFloat = obj.bestFloat;
					objState.bestValue = obj.bestValue;
					objState.bestSequence = obj.bestSequence.copy();
					levelState.objectives.push(objState);
				}
				worldState.levelObjectiveTable[levelKey] = levelState;
			}			
			saveTable[key] = worldState;
		}
		saveFile.data.worldTable = saveTable;
		saveFile.flush();
	}
}