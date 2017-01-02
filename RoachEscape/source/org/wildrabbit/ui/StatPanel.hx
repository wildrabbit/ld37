package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.Reg;
import org.wildrabbit.world.GameStats.StatType;

/**
 * ...
 * @author ith1ldin
 */
class StatPanel extends FlxSpriteGroup
{

	// TODO: Rename the images to proper, meaningful names! (or refactor this into a loop using ui_icons_XXX
	private static var STAT_ICONS:Array<String> = [UIAtlasNames.STAT_ICON_TILES_MOVED, UIAtlasNames.STAT_ICON_TILES_PLACED, UIAtlasNames.STAT_ICON_TIME, UIAtlasNames.STAT_ICON_BREADCRUMBS]; 
	private static inline var TEXT_WIDTH:Float = 136;
	
	private var icon:FlxSprite = null;
	private var counter:FlxText = null;
	
	private var statType:StatType;
	
	
	public function new(x:Float, y:Float, atlas: FlxAtlasFrames, statType:StatType) 
	{
		super(x, y);
		
		this.statType = statType;
		
		icon = new FlxSprite(0, 0);
		icon.frames = atlas;
		icon.animation.frameName = STAT_ICONS[Type.enumIndex(statType)];
		add(icon);
		
		counter = new FlxText(40, 8, 160, "", 16);
		counter.font = AssetPaths.small_text__TTF;
		counter.wordWrap = true;
		counter.origin.set(120, 16);
		add(counter);	
		
		updateValue();
	}
	
	public override function update(dt:Float):Void
	{
		super.update(dt);
		updateValue();
	}
	private function updateValue():Void
	{		
		switch(statType)
		{
			case StatType.BREADCUMBS:
			{
				counter.text = Std.string(Reg.stats.breadcumbsCounter);
			}
			case StatType.TILES_PLACED:
			{
				counter.text = Std.string(Reg.stats.tilesPlaced);
			}
			case StatType.TILES_TRAVERSED:
			{
				var ratio:Float = cast(Reg.stats.tilesTraversed / cast(Reg.currentLevel.maxTiles, Float), Float);
				var colour:FlxColor = ratio > 0.85 ? FlxColor.RED: FlxColor.WHITE;
				
				counter.text = Std.string(Reg.stats.tilesTraversed) + "/" + Std.string(Reg.currentLevel.maxTiles);
				counter.color = colour;
			}
			case StatType.TIME_SPENT:
			{
				var ratio:Float = cast(Reg.stats.timeSpent/ cast(Reg.currentLevel.maxTime, Float), Float);
				var colour:FlxColor = ratio > 0.85 ? FlxColor.RED: FlxColor.WHITE;
				
				var timeLimit:String = FlxStringUtil.formatTime(Reg.currentLevel.maxTime);
				counter.text = FlxStringUtil.formatTime(Reg.stats.timeSpent) + "/" + timeLimit;
				counter.color = colour;
			}
		}
	}
	public function playFail():Void
	{
		FlxTween.tween(counter.scale, { x:1.4, y:1.4 }, 0.15, { ease:FlxEase.backOut, onComplete: function(t:FlxTween):Void 
			{
				FlxTween.tween(counter.scale, { x:1, y:1 }, 0.15, { ease:FlxEase.quadIn } );
			}		
		});		
	}
}