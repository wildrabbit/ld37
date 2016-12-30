package org.wildrabbit.roach;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var cover:FlxSprite;
	var msg:FlxSprite = null;
	var delay:Float = 2;
	var t:FlxTween;
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();	
		cover = new FlxSprite(0, 0, AssetPaths.menu__jpg);
		add(cover);
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(dt:Float):Void
	{
		super.update(dt);
		if (delay >= 0)
		{
			delay -= dt;			
		}
		else 
		{
			if (msg == null)
			{
				msg = new FlxSprite(166, 148, AssetPaths.start__png);
				add(msg);
				t = FlxTween.tween(msg.scale, { x:1.15, y:1.15 }, 0.7, { type:FlxTween.PINGPONG } );
			}
			if (FlxG.keys.justPressed.ANY|| FlxG.mouse.justPressed)
			{
				t.cancel();
				Reg.gameWorld.currentWorldIdx = Reg.gameWorld.currentLevelIdx = 0;
				Reg.currentWorld = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx];
				Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
				FlxG.sound.play(AssetPaths.play__wav);
				FlxG.switchState(new PlayState());
			}
			
		}
	}
}