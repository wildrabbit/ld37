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
	private var iconT:FlxTween = null;
	
	private var counter:FlxText = null;
	private var counterT:FlxTween = null;
	
	private var statType:StatType;
	
	
	public function new(x:Float, y:Float, atlas: FlxAtlasFrames, statType:StatType) 
	{
		super(x, y);
		
		this.statType = statType;
		
		icon = new FlxSprite(0, 0);
		icon.frame = atlas.getByName(STAT_ICONS[Type.enumIndex(statType)]);
		icon.origin.set(icon.frameWidth/ 2, icon.frameHeight/ 2);
		add(icon);
		
		counter = new FlxText(40, 8, 160, "", 16);
		counter.font = AssetPaths.small_text__ttf;
		counter.wordWrap = true;
		counter.origin.set(counter.width/ 2, counter.height / 2);
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
	
	public function resetScale():Void
	{
		if (iconT != null) iconT.cancel();
		icon.scale.set(1, 1);
		
		if (counterT != null) counterT.cancel();		
		counter.scale.set(1, 1);		
	}
	
	public function playFail():Void
	{
		counterT = FlxTween.tween(counter.scale, { y:1.2 }, 0.25, { ease:FlxEase.backOut, 
			onComplete: function(t:FlxTween):Void 
			{
				counterT = FlxTween.tween(counter.scale, { y:1 }, 0.15, { ease:FlxEase.quadIn , onComplete:function(t:FlxTween) { counterT = null; }} );
			}		
		});		
		
		iconT = FlxTween.tween(icon.scale, { x:1.2, y:1.2 }, 0.25, { ease:FlxEase.backOut, onComplete: function(t:FlxTween):Void 
			{
				iconT = FlxTween.tween(icon.scale, { x:1, y:1 }, 0.15, { ease:FlxEase.quadIn, onComplete:function(t:FlxTween) { iconT = null; } } );
			}		
		});		
	}
}