package org.wildrabbit.data;

import flixel.util.FlxStringUtil;
import haxe.EnumTools;
import haxe.Json;

/**
 * ...
 * @author ith1ldin
 */

enum ObjectiveType
{
	REACH_GOAL; // 0
	MAX_TILES_PLACED; // 1
	ALL_TILES_PLACED; // 2
	MAX_BUMPS; // 3
	MAX_TIME; // 4
	MIN_TILES_TRAVERSED; // 5
	MAX_TILES_TRAVERSED; // 6
	ALL_COLLECTABLES_PICKED; // 7
	MIN_COLLECTABLES_PICKED; // 8
	COMPLETE_SEQUENCE; // 9
}

class ObjectiveData
{
	private static var OBJ_TYPE_TEXTS: Array<String> = [
		"Reach the goal",
		"Use at most #IPARAM0# tiles",
		"Use all the tiles",
		"Bump less than #IPARAM0# times",
		"Complete in less than #TPARAM0#",
		"Step on at least #IPARAM0# tiles",
		"Step on less than #IPARAM0# tiles",
		"Pick all the #SPARAM0#",
		"Pick at least #IPARAM0# #SPARAM0#",
		"Pick #SPARAM0# in order"		
	];
	
	public var type:ObjectiveType;
	public var value:Int;
	public var paramId:Int;	// For "Pick X stuff" types, or "take N teleporters"
	public var sequence:Array<Int> = new Array<Int>();
	
	public function new(obj:Dynamic)
	{
		if (Reflect.hasField(obj, "type"))
		{
			type = Type.createEnumIndex(ObjectiveType, obj.type);	
		}
		
		value = (Reflect.hasField(obj, "value")) ? obj.value : 0;
		paramId = (Reflect.hasField(obj, "paramId")) ? obj.paramId : 0;
		
		for (objSeq in Reflect.fields(obj.sequence))
		{
			sequence.push(Reflect.field(obj.sequence, objSeq));
		}
	}
	
	
	public function getText():String 
	{
		var str:String = OBJ_TYPE_TEXTS[Type.enumIndex(type)];
		if (type == ObjectiveType.REACH_GOAL || type == ObjectiveType.ALL_TILES_PLACED)
		{
			return str;
		}
		else if (type == ObjectiveType.MAX_TIME)
		{
			str = StringTools.replace(str, "#TPARAM0#", FlxStringUtil.formatTime(value, false));
			return str;
		}
		else if (type == ObjectiveType.ALL_COLLECTABLES_PICKED)
		{
			return str; // TODO
		}
		else if (type == ObjectiveType.MIN_COLLECTABLES_PICKED)
		{
			return str; // TODO
		}
		else if (type == ObjectiveType.COMPLETE_SEQUENCE)
		{
			return str; // TODO
		}
		return StringTools.replace(str, "#IPARAM0#", Std.string(value));
	}
}
