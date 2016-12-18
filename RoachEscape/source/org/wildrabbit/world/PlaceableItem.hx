package org.wildrabbit.world;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.roach.PlayState.StageMode;

using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ith1ldin
 */
class PlaceableItem extends Actor
{
	public var parent:PlayState;
	public var itemData:PlaceableItemData;
	
	var facingSound:FlxSound;
	
	public function new() 
	{
		super();
		facingSound = new FlxSound();
		facingSound.loadEmbedded(AssetPaths.changeDir__wav);
		facingSound.stop();
	}
	
	public function init(parent:PlayState, item:PlaceableItemData):Void
	{
		this.parent = parent;
		this.itemData = item;
		initGfx();
	}
	
	private function initGfx():Void
	{
		loadGraphic(itemData.spritePath, true, 64, 64, false );
		animation.add("default", [itemData.spriteAnims[0]], 10, true);
		animation.add("play", itemData.spriteAnims, 10, true);
		animation.play("default");

		//if (itemData.type == "changeDir")
		//{
			//loadGraphic(itemData.spritePath, true, 64, 64, false );
			//animation.add("default", [itemData.spriteAnims[0]], 10, true);
			//animation.add("play", itemData.spriteAnims, 10, true);
			//animation.play("default");
		//}
		//else if (itemData.type == "teleporter")
		//{
			//loadGraphic(itemData.spritePath, true, 64, 64, false );
			//animation.add("default", [itemData.spriteAnims[0]], 10, true);
			//animation.add("play", itemData.spriteAnims, 10, true);
			//animation.play("default");			
		//}
	}
	
	/* INTERFACE org.wildrabbit.world.Actor */
	
	public override function startPlaying():Void 
	{
		animation.play("play");
	}
	
	public override function pause(value:Bool):Void 
	{
		animation.play(value ? "default" : "play");
	}
	public override function resetToDefaults():Void 
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
				if (!facingSound.playing)
				{
					facingSound.play();
				}
				//myCoords.put();
				//midCoords.put();
			}
		}
	}
	
}