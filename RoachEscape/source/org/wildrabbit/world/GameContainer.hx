package org.wildrabbit.world;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.addons.tile.FlxTilemapExt;
import flixel.animation.FlxBaseAnimation;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;

/**
 * ...
 * @author ith1ldin
 */
class GameContainer extends FlxGroup
{
	public static inline var BACKGROUND_IDX:Int = 0;
	public static inline var EDGES_IDX:Int = 1;

	public static inline var ACTORS_IDX:Int = 0;
	
	public static inline var SPRITE_PLAYER_BG_IDX:Int = 0;
	public static inline var SPRITE_PLAYER_FG_IDX:Int = 1;
	
	public var x(default,null):Float;
	public var y(default,null):Float;
		
	public var mapBGLayer: FlxTypedGroup<FlxTilemapExt>;
	public var edgeLayer: FlxTypedGroup<FlxTilemapExt>;
	
	public var placedItemsLayer: FlxTypedSpriteGroup<PlaceableItem>;
	public var actorsLayer: FlxTypedSpriteGroup<Actor>;
	
	public var playerBGSpriteLayer: FlxSpriteGroup ;
	public var playerLayer: FlxTypedSpriteGroup<Player>;
	public var playerFGSpriteLayer: FlxSpriteGroup ;
	
	// SPRITE LAYERS:
	
	
	public function new(?x:Float = 0, ?y:Float = 0)
	{
		super();
		this.x = x;
		this.y = y;
		createLayers();
	}
	
	public function getPosition():FlxPoint
	{
		return FlxPoint.get(x, y);
	}
	
	private function updateMapOffset(m:FlxTilemapExt, oldX:Float, oldY:Float):Void
	{
		m.setPosition(m.x + (x - oldX));
		m.setPosition(m.y + (y - oldY));
	}
	
	private function updateActorOffset(a:Actor):Void
	{
		a.setOffset(x, y);
	}
	
	private function updateSpritesOffset(s:FlxSprite, oldX:Float, oldY:Float):Void
	{
		var relX: Float = s.x - oldX;
		var relY: Float = s.y - oldY;
		
		s.x = relX + x;
		s.y = relY + y;
	}
	
	public function setPosition(x:Float, y:Float):Void
	{
		var oldX:Float = this.x;
		var oldY:Float = this.y;
		
		this.x = x;
		this.y = y;
		mapBGLayer.forEach(function (m:FlxTilemapExt):Void { updateMapOffset(m, oldX, oldY); } );
		edgeLayer.forEach(function (m:FlxTilemapExt):Void { updateMapOffset(m, oldX, oldY); } );
		
	
		// Adjust offset on actor layers
		placedItemsLayer.forEach(function (a:PlaceableItem):Void { updateActorOffset(a); } );
		actorsLayer.forEach(function (a:Actor):Void { updateActorOffset(a); } );
		playerLayer.forEach(function (a:Player):Void { updateActorOffset(a); } );
		
		// And do the same for sprite layers
		playerBGSpriteLayer.forEach(function (s:FlxSprite):Void { updateSpritesOffset(s, oldX, oldY); } );
		playerFGSpriteLayer.forEach(function (s:FlxSprite):Void { updateSpritesOffset(s, oldX, oldY);});
	}
	
	public function createLayers():Void
	{
		
		mapBGLayer = new FlxTypedGroup<FlxTilemapExt>();
		add(mapBGLayer);
		
		placedItemsLayer = new FlxTypedSpriteGroup<PlaceableItem>();
		add(placedItemsLayer);
		
		edgeLayer = new FlxTypedGroup<FlxTilemapExt>();
		add(edgeLayer);
		
		actorsLayer = new FlxTypedSpriteGroup<Actor>();
		add(actorsLayer);
		
		playerBGSpriteLayer = new FlxSpriteGroup();
		add(playerBGSpriteLayer);
		
		playerLayer = new FlxTypedSpriteGroup<Player>();
		add(playerLayer);
		
		playerFGSpriteLayer = new FlxSpriteGroup();
		add(playerFGSpriteLayer);
	}
	
	public function addToMapLayer(baseX:Float, baseY:Float, map: FlxTilemapExt, layerID:Int):Void
	{
		map.setPosition(x + baseX, y + baseY);
		if (layerID == BACKGROUND_IDX)
		{
			mapBGLayer.add(map);
		}
		else if (layerID == EDGES_IDX)
		{
			edgeLayer.add(map);
		}
	}
	
	public function removeMapLayer(map: FlxTilemapExt, layerID:Int):Void
	{
		if (layerID == BACKGROUND_IDX)
		{
			mapBGLayer.remove(map);
		}
		else if (layerID == EDGES_IDX)
		{
			edgeLayer.remove(map);
		}
	}
	
	public function addToActorLayer(entity:Actor):Void
	{
		entity.setOffset(x, y);
		actorsLayer.add(entity);
	}
	
	public function addToPlaceableLayer(entity:PlaceableItem):Void
	{
		entity.setOffset(x, y);
		placedItemsLayer.add(entity);
	}
	
	public function addToPlayerLayer(entity:Player):Void
	{
		entity.setOffset(x, y);
		playerLayer.add(entity);
	}
	
	public function addToSpriteLayer(entity:FlxSprite, layerID:Int):Void	
	{
		entity.x += x;
		entity.y += y;
		if (layerID == SPRITE_PLAYER_BG_IDX)
		{
			playerBGSpriteLayer.add(entity);
		}
		else if (layerID == SPRITE_PLAYER_FG_IDX)
		{
			playerFGSpriteLayer.add(entity);
		}
	}

	public function removePlaceableItem(item:PlaceableItem):Void
	{
		placedItemsLayer.remove(item);
	}
	
	
	public function resetPlaceableItems():Void
	{
		placedItemsLayer.forEach(function(x:PlaceableItem):Void { x.destroy(); } );
		placedItemsLayer.clear();		
	}
	
	public function removeActor(entity:Actor):Void
	{
		actorsLayer.remove(entity);
	}
	
	public function removeFromSpriteLayer(entity:FlxSprite, layerID:Int):Void
	{
		if (layerID == SPRITE_PLAYER_BG_IDX)
		{
			playerBGSpriteLayer.remove(entity);
		}
		else if (layerID == SPRITE_PLAYER_FG_IDX)
		{
			playerFGSpriteLayer.remove(entity);
		}
	}
}