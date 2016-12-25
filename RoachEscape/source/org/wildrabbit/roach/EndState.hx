package org.wildrabbit.roach;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the game's menu.
 */
class EndState extends FlxState
{
	var txt:FlxText;
	var delay:Float = 2;
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();	
		txt = new FlxText(0, 0, 0, "Thanks for playing!", 48);
		txt.alignment = FlxTextAlign.CENTER;
		txt.setPosition(FlxG.width / 2 - txt.width / 2, FlxG.height / 2 - txt.height / 2);
		txt.color = FlxColor.WHITE;
		add(txt);
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
			if (FlxG.keys.justPressed.ANY|| FlxG.mouse.justPressed)
			{
				Reg.gameWorld.currentWorldIdx = Reg.gameWorld.currentLevelIdx = 0;
				Reg.currentWorld = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx];
				Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
				FlxG.switchState(new MenuState());
				FlxG.sound.play(AssetPaths.goal__wav);
			}
			
		}
	}
}