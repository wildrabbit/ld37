package org.wildrabbit.world;

import flixel.FlxObject;
import flixel.FlxSprite;
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
	var parent:PlayState;
	var itemData:PlaceableItemData;
	
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
			makeGraphic(54, 54, FlxColor.TRANSPARENT);
			var col: FlxColor = FlxColor.WHITE;
			switch(itemData.subtype)
			{
				case "left": 
				{ 
					col = FlxColor.GREEN;				
				}
				case "right": { col = FlxColor.PINK; }
				case "down": { col = FlxColor.BLUE; }
				case "up": { col = FlxColor.YELLOW; }	
			}
			var lStyle: LineStyle = { color: FlxColor.BLACK, thickness: 4 };
			var dStyle: DrawStyle = { smoothing: true };
			
			FlxSpriteUtil.drawRoundRect(this, 7, 7, 50, 50, 30, 10, col, lStyle, dStyle);
		}
	}
	
	/* INTERFACE org.wildrabbit.world.Actor */
	
	public function startPlaying():Void 
	{
		
	}
	
	public function pause(value:Bool):Void 
	{}
	public function resetToDefaults():Void 
	{
		
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
			}
		}
	}
	
}