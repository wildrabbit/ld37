package org.wildrabbit.data;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.data.ObjectiveData;


class LevelData
{
	public static inline var NUM_OBJECTIVES: Int = 3;
	
	public var id:Int;
	public var file:String;
	public var loadouts:Array<PlaceableItemTool> = new Array<PlaceableItemTool>();
	
	// Defeat conditions
	public var maxTiles:Int = 999;
	public var maxTime:Float = 180;
	
	public var objectives:Array<ObjectiveData> = new Array<ObjectiveData>();	

	
	public function new(obj:Dynamic)
	{
		id = Reflect.hasField(obj, "id") ? obj.id : -1;
		file = Reflect.hasField(obj, "file") ? obj.file : "";
		maxTiles = Reflect.hasField(obj, "maxTiles") ? obj.maxTiles: 0;
		maxTime = Reflect.hasField(obj, "maxTime") ? obj.maxTime: 0;
		
		if (Reflect.hasField(obj, "loadouts"))
		{
			var loadoutArray:Array<Dynamic> = obj.loadouts;
			for (l in loadoutArray)
			{
				var tool:PlaceableItemTool = { id:l.id, amount:l.amount };
				loadouts.push(tool);
			}
		}
		if (Reflect.hasField(obj, "objectives"))
		{
			var objArray:Array<Dynamic> = obj.objectives;
			for (o in objArray)
			{
				var objective:ObjectiveData= new ObjectiveData(o);				
				objectives.push(objective);
			}			
		}
	}
}


class WorldData
{
	public var id:Int;
	public var file:String;
	public var levels:Array<LevelData> = new Array<LevelData>();
	
	public function new(obj:Dynamic) 
	{
		id = Reflect.hasField(obj, "id") ? obj.id : -1;
		file = Reflect.hasField(obj, "file") ? obj.file : "";
		
		var levelArray:Array<Dynamic> = obj.levels;
		for (lv in levelArray)
		{
			var l:LevelData = new LevelData(lv);
			levels.push(l);
		}
	}
}
