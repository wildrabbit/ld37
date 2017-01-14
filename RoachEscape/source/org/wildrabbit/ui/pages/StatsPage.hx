package org.wildrabbit.ui.pages;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.TabPage;
import flixel.text.FlxText;
import org.wildrabbit.world.GameStats.StatType;
import org.wildrabbit.roach.AssetPaths;
/**
 * ...
 * @author ith1ldin
 */
class StatsPage extends TabPage
{
	// Special stats for level
	private var stats:Array<StatPanel>;
	private var atlas: FlxAtlasFrames;
		
	private var parent:PlayState;
	public function new(state:PlayState, ?x:Float=0, ?y:Float=0) 
	{
		super(x, y);
		parent = state;		
		atlas = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		initStatsPanel();
	}
	
	private function initStatsPanel():Void
	{
		var offsetX:Float = 32;
		var offsetY:Float = 32;
		var height:Float = 36;
		var padding:Float = 4;
		
		stats = new Array<StatPanel>();

		var stat:Array<StatType> = [StatType.TILES_TRAVERSED, StatType.TILES_PLACED, StatType.TIME_SPENT];
		for (st in stat)
		{
			var stPanel:StatPanel = new StatPanel(offsetX, offsetY, atlas, st);
			add(stPanel);
			offsetY += height + padding;
			stats.push(stPanel);
		}
	}
	
	public function resetScale():Void
	{
		for (stat in stats)
		{
			stat.resetScale();
		}
	}
	
	public function playFail(type:StatType):Void
	{
		var stPanel:StatPanel = stats[Type.enumIndex(type)];
		if (stPanel == null) return;
		stPanel.playFail();
	}
}