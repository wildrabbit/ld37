package org.wildrabbit.world;

/**
 * ...
 * @author ith1ldin
 */
enum StatType
{
	TILES_TRAVERSED;
	TILES_PLACED;
	TIME_SPENT;
	BREADCUMBS;
	//BUMP_COUNT;
}
class GameStats
{
	public var tilesTraversed:Int;
	public var tilesPlaced:Int;
	public var timeSpent:Float;
	public var breadcumbsCounter:Int;
	public var bumps:Int;
	public var sequenceArray:Array<Int> = new Array<Int>();
	
	public function new() 
	{
		
	}	
	
	public function reset():Void
	{
		tilesTraversed = tilesPlaced = 0;
		bumps = 0;
		timeSpent = 0;
		breadcumbsCounter = 0;
		sequenceArray.splice(0, sequenceArray.length);
	}
}