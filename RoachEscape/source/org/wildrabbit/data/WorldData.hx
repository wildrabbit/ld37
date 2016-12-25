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
	var maxTiles:Int = 999;
	var maxTime:Float = 180;
	
	public var objectives:Array<ObjectiveData> = new Array<ObjectiveData>();	

	
	public function new(obj:Dynamic)
	{
		id = Reflect.hasField(obj, "id") ? obj.id : -1;
		file = Reflect.hasField(obj, "file") ? obj.file : "";
		maxTiles = Reflect.hasField(obj, "maxTiles") ? obj.maxTiles: 0;
		maxTime = Reflect.hasField(obj, "maxTime") ? obj.maxTime: 0;
		
		for (l in Reflect.fields(obj.loadouts))
		{
			var tool:PlaceableItemTool = Reflect.field(obj.loadouts, l);
			loadouts.push(tool);
		}
		
		for (o in Reflect.fields(obj.objectives))
		{
			var objective:ObjectiveData= new ObjectiveData(Reflect.field(obj.objectives,o));				
			objectives.push(objective);
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
		for (l in Reflect.fields(obj.levels))
		{
			var l:LevelData = new LevelData(Reflect.field(obj.levels, l));
			levels.push(l);
		}
	}
}
