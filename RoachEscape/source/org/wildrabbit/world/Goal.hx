package org.wildrabbit.world;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState.StageMode;

/**
 * ...
 * @author ith1ldin
 */
class Goal extends FlxSprite implements Actor
{

	public function new() 
	{
		super(0,0);
		loadGraphic(AssetPaths.entities_00__png, true, 64, 64);
		animation.add("idle", [2], 1, false);
		animation.add("shiny", [3, 2, 4, 2], 15, true);
		animation.play("idle");
	}
	
	public function pause(value:Bool):Void
	{
		animation.play(value ? "idle" : "shiny");
	}
	
	public function resetToDefaults()
	{
		animation.play("idle");
	}
	
	public function startPlaying():Void
	{
		animation.play("shiny");
	}
}