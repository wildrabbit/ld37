package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import openfl.Assets;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class ObjectivePanel extends FlxSpriteGroup
{
	// TODO: Rename the images to proper, meaningful names! (or refactor this into a loop using ui_icons_XXX
	private static var MEDALS:Array<String> = [UIAtlasNames.MEDAL_BRONZE, UIAtlasNames.MEDAL_SILVER, UIAtlasNames.MEDAL_GOLD]; 
	private static inline var TEXT_WIDTH:Float = 136;
	private var medal:FlxSprite = null;
	private var description:FlxText= null;
	private var tickBox:FlxSprite = null;
	private var tick:FlxSprite = null;
	
	public function new(x:Float, y:Float, atlas: FlxAtlasFrames, medalType:Int, objText:String, completed:Bool, revealed:Bool = false) 
	{
		super(x, y);
		
		medal = new FlxSprite(0, 0);
		medal.frames = atlas;
		medal.animation.frameName = MEDALS[medalType];
		add(medal);
		
		description = new FlxText(medal.width + 4, 0, TEXT_WIDTH, objText, 16);
		description.font = AssetPaths.small_text__TTF;
		description.wordWrap = true;
		add(description);
		
		var totalW:Float = medal.width + 4 + TEXT_WIDTH;
		
		tickBox = new FlxSprite(totalW, 0);
		tickBox.frames = atlas;
		tickBox.animation.frameName = UIAtlasNames.TICK_BOX;
		add(tickBox);
		
		tick = new FlxSprite(totalW, 0);
		tick.frames = atlas;
		tick.animation.frameName = UIAtlasNames.TICK;
		add(tick);
		setRevealed(revealed, completed);
	}
	
	public function setCompleted(value:Bool):Void
	{
		tick.visible = value;
	}
	
	public function setRevealed(value:Bool, completed:Bool = false):Void
	{
		tickBox.visible = value;
		tick.visible = value && completed;
	}
	
}