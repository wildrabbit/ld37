package org.wildrabbit.world;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.roach.PlayState.StageMode;

using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ith1ldin
 */
class PlaceableItem extends FlxSprite implements Actor
{
	public var parent:PlayState;
	public var itemData:PlaceableItemData;
	
	public function new() 
	{
		super();
	}
	
	public function init(parent:PlayState, item:PlaceableItemData):Void
	{
		this.parent = parent;
		this.itemData = item;
		initGfx();
	}
	
	private function initGfx():Void
	{
		if (itemData.type == "changeDir")
		{
			loadGraphic(itemData.spritePath, true, 64, 64, false );
			animation.add("default", [itemData.spriteAnims[0]], 10, true);
			animation.add("play", itemData.spriteAnims, 10, true);
			animation.play("default");
		}
	}
	
	/* INTERFACE org.wildrabbit.world.Actor */
	
	public function startPlaying():Void 
	{
		animation.play("play");
	}
	
	public function pause(value:Bool):Void 
	{
		animation.play(value ? "default" : "play");
	}
	public function resetToDefaults():Void 
	{
		animation.play("default");
	}
	
	public function onEntityInteracted(a:Actor):Void
	{
		if (Std.is(a, Player))
		{
			var p:Player = cast a;
			if (itemData.type == "changeDir")
			{
				//var myCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(x), Math.round(y));
				//var midCoords:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(myCoords);
				//p.setPosition(midCoords.x, midCoords.y);
				switch(itemData.subtype)
				{
					case "left": 
					{ 
						p.changeFacing(FlxObject.LEFT);				
					}
					case "right": { p.changeFacing(FlxObject.RIGHT); }
					case "down": { p.changeFacing(FlxObject.DOWN); }
					case "up": { p.changeFacing(FlxObject.UP); }	
				}
				//myCoords.put();
				//midCoords.put();
			}
		}
	}
	
}