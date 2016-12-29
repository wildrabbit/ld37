package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class PauseLayer extends FlxSpriteGroup
{
	private var bg:FlxSprite;
	private var pauseGfx:FlxSprite;
	
	private var pauseTween:FlxTween;
	
	public function new() 
	{
		super(0, 0);
		
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(768, 768, 0x80000000);
		add(bg);
		
		pauseGfx = new FlxSprite(288, 288, AssetPaths.screen_pause__png);
		pauseGfx.alpha = 0.8;
		add(pauseGfx);		
	}

	public function setPaused(value:Bool):Void
	{
		if (value)
		{
			pauseTween = FlxTween.tween(pauseGfx.scale, { x:1.15, y:1.15 }, 0.8, { type:FlxTween.PINGPONG, ease:FlxEase.quadIn} );
		}
		else 
		{
			pauseTween.cancel();
			pauseTween = null;
		}
	}
}