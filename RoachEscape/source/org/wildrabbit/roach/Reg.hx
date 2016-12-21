package org.wildrabbit.roach;

import flixel.util.FlxSave;
import org.wildrabbit.roach.PlayState.PlaceableItemTool;
import org.wildrabbit.world.GameStats;
import org.wildrabbit.world.GameWorldState;
import org.wildrabbit.data.WorldData;

/**
 * Handy, pre-built Registry class that can be used to store
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	public static var worlds:Array<Dynamic> = [AssetPaths.world00__json];
	
	public static var worldDatabase:Map<Int,WorldData> = new Map<Int,WorldData>();

	/** Persistent state info! */
	public static var gameWorld: GameWorldState = new GameWorldState();
	
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [AssetPaths.level0__tmx, AssetPaths.level1__tmx, AssetPaths.level2__tmx, AssetPaths.level3__tmx, AssetPaths.level4__tmx, AssetPaths.level5__tmx];
	
	/**
	 * Tools array with the loadouts per level
	 * Example usage: Storing the levels of a platformer.
	 * TODO: Defer to json (the level itself or wherever we also put the goals
	 */	
	public static var levelToolLoadouts:Array<Array<PlaceableItemTool>> = [
		[
			{id:0, amount:1 },
			{id:1, amount:1 }
		], 		
		[
			{id:0, amount:1 },
			{id:1, amount:1 },
			{id:2, amount:1 },
			{id:3, amount:1 }
		], 				
		[
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 }
		], 				
		[
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 }
		]
		, 				
		[
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 }
		]
		, 				
		[
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 }
		]		
	];
	
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;
	/**
	 * Generic bucket for storing different FlxSaves.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];
	
	/**
	 * Stats tracking register
	 */
	public static var stats:GameStats = new GameStats();
}