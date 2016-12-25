package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
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
				counter.text = Std.string(Reg.stats.tilesTraversed);
			}
			case StatType.TIME_SPENT:
			{
				counter.text = FlxStringUtil.formatTime(Reg.stats.timeSpent);
			}
		}
	}
}