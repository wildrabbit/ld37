package org.wildrabbit.world;
import org.wildrabbit.world.LevelData.TileType;

/**
 * ...
 * @author ith1ldin
 */
class PlaceableItemData
{
	public var templateID: Int;
	public var type:String;
	public var subtype:String;
	public var linkedEntityType:String;
	public var btnName:String;
	public var allowedTileType:TileType;
	public var spritePath:String;
	public var spriteAnims:Array<Int> = null;
	public var name:String = null;
	
	public function new() 
	{
	}	
}