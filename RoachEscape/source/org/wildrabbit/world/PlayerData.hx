package org.wildrabbit.world;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class PlayerData
{
	public var start: FlxPoint = new FlxPoint(0, 0);
	public var facing: Int = FlxObject.LEFT;	
	public var speed: Float = 0;
	public var type: String = "player";
	public var path: String = AssetPaths.entities_00__png;
	public var startIdx: Int = 0;

	public function new() 
	{
		
	}
	
}