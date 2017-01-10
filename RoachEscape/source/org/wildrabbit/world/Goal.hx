package org.wildrabbit.world;
import org.wildrabbit.roach.states.PlayState;

import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState.StageMode;

/**
 * ...
 * @author ith1ldin
 */
class Goal extends Actor
{

	public function new() 
	{
		super(0, 0);
		blend = BlendMode.NORMAL;
		loadGraphic(AssetPaths.entities_00__png, true, 64, 64);
		animation.add("idle", [15], 1, false);
		animation.add("shiny", [2, 3, 4, 5], 8, true);
		animation.play("idle");
	}
	
	public override function pause(value:Bool):Void
	{
		animation.play(value ? "idle" : "shiny");
		blend = value ? BlendMode.NORMAL : BlendMode.SCREEN;
	}
	
	public override function resetToDefaults()
	{
		animation.play("idle");
		blend = BlendMode.NORMAL;		
	}
	
	public override function startPlaying():Void
	{
		animation.play("shiny");
		blend = BlendMode.SCREEN;
	}
}