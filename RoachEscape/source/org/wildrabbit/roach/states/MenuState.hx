package org.wildrabbit.roach.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	var cover:FlxSprite;
	var msg:FlxSprite = null;
	
	var continueText:FlxText = null;
	var version:FlxText = null;
	
	var delay:Float = 0.8;

	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();	
		cover = new FlxSprite(0, 0, AssetPaths.menu__jpg);
		add(cover);
		version = new FlxText(0, 742, 400, "LD37 Post-compo - Ithildin", 24);
		add(version);
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
			if (continueText == null)
			{
/*				msg = new FlxSprite(166, 148, AssetPaths.start__png);
				add(msg);
				t = FlxTween.tween(msg.scale, { x:1.15, y:1.15 }, 0.7, { type:FlxTween.PINGPONG } );*/
				continueText = new FlxText(700, 746, 368, "Press any key to continue...", 20);
				continueText.font = AssetPaths.small_text__ttf;
				continueText.color = FlxColor.WHITE;		
				FlxTween.color(continueText, 0.8, FlxColor.WHITE, FlxColor.BLACK, { type:FlxTween.PINGPONG } );
				add(continueText);				
			}
			if (FlxG.keys.justPressed.ANY|| FlxG.mouse.justPressed)
			{
				FlxG.sound.play(AssetPaths.ui_select__wav, 1, false, null, true, function():Void
					{
						FlxG.switchState(new HowtoState());
					});				
			}
			
		}
	}
}