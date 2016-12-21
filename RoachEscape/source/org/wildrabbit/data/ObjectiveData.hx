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
	REACH_GOAL;
	MAX_TILES_PLACED;
	ALL_TILES_PLACED;
	MAX_BUMPS;
	MAX_TIME;
	MIN_TILES_TRAVERSED;
	ALL_COLLECTABLES_PICKED;
	MIN_COLLECTABLES_PICKED;
	COMPLETE_SEQUENCE;
}

class ObjectiveData
{
	private static var OBJ_TYPE_TEXTS: Array<String> = [
		"Reach the goal",
		"Use at most #IPARAM0# tiles",
		"Use all the tiles",
		"Complete in less than #IPARAM0# bumps",
		"Complete in less in less than #TPARAM0# mins",
		"Complete traversing less than #IPARAM0# tiles",
		"Complete picking all the #SPARAM0",
		"Complete picking at least #IPARAM0 #SPARAM0",
		"Complete picking #SPARAM0 in order"		
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
			StringTools.replace(str,"#TPARAM0", FlxStringUtil.formatTime(value, false));
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
		return StringTools.replace(str, "#IPARAM0", Std.string(value));
	}
}
