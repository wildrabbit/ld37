package org.wildrabbit.world;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import org.wildrabbit.roach.Reg;


//-------------- PERSISTENCE

typedef ObjectiveSaveEntry = 
{
	var completed:Bool;
	var bestValue: Int;
	var bestFloat:Float;
	var bestSequence: Array<Int>;
}
typedef LevelSaveEntry =
{
	var id:Int;
	var state:Array<ObjectiveSaveEntry>;
}

typedef WorldSaveEntry =
{
	var id:Int;
	var levelListState:Array<LevelSaveEntry>;
}

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
	public var worldTable:Map<Int,WorldStateEntry> = new Map<Int,WorldStateEntry>();
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
		
		// TODO: Replace with worldTable.destroy(); worldTable = null;
				
		worldTable = null;
		worldTable = new Map<Int,WorldStateEntry>();
		var saveData:Array<WorldSaveEntry> = saveFile.data.worldTable;
		if (saveData == null) return;

		if (saveData== null) return;
		for (saveEntry in saveData)
		{
			var worldState:WorldStateEntry = new WorldStateEntry();
			worldState.levelObjectiveTable = new Map<Int,LevelState>();
			
			var iKey:Int = saveEntry.id;
			var levelObjData:Array<LevelSaveEntry> = saveEntry.levelListState;
			for (levelSave in levelObjData)
			{
				var levelState:LevelState = new LevelState();
				var array:Array<ObjectiveSaveEntry> = levelSave.state;
				var i:Int = 0;
				for (obj in array)
				{
					var objState:ObjectiveState = new ObjectiveState();
					objState.completed = obj.completed;
					objState.bestFloat = obj.bestFloat;
					objState.bestValue = obj.bestValue;
					objState.bestSequence.splice(0, objState.bestSequence.length);
					var seqList:Array<Int> = obj.bestSequence;
					for (item in seqList)
					{
						objState.bestSequence.push(item);
					}
					levelState.objectives.push(objState);
					i++;
				}
				worldState.levelObjectiveTable[levelSave.id] = levelState;
			}			
			worldTable[iKey] = worldState;
		}
	}
	
	public function save():Void
	{
		saveFile.bind(SAVE_SLOT);
		saveFile.data.worldIdx = currentWorldIdx;
		saveFile.data.levelIdx = currentLevelIdx;
		var saveTable:Array<WorldSaveEntry> = new Array<WorldSaveEntry>();
		for (key in worldTable.keys())
		{
			var worldState:WorldSaveEntry = { id : -1, levelListState : new Array<LevelSaveEntry>() };
			for (levelKey in worldTable[key].levelObjectiveTable.keys())
			{
				var saveEntry:LevelSaveEntry = { id : levelKey, state : new Array<ObjectiveSaveEntry>() };
				for (obj in worldTable[key].levelObjectiveTable[levelKey].objectives)
				{
					var objState:ObjectiveSaveEntry = {
						completed: obj.completed,
						bestFloat: obj.bestFloat,
						bestValue:obj.bestValue,
						bestSequence: obj.bestSequence.copy()
					};
					saveEntry.state.push(objState);
				}
				worldState.levelListState.push(saveEntry);
			}			
			worldState.id = key;
			saveTable.push(worldState);
		}
		saveFile.data.worldTable = saveTable;
		saveFile.flush();
		saveFile.close();
	}
	
	public function clearSave():Void
	{
		saveFile.bind(SAVE_SLOT);
		trace(saveFile.data);
		new FlxTimer().start(1, function clear(t:FlxTimer):Void {
			saveFile.erase();
			saveFile.close();			
		});
	}
}