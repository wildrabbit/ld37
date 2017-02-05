package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxRect;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */


class ActionButton extends FlxSpriteGroup
{
	private var icon:FlxSprite;
	private var button:FlxButton;
	private var callback:Void->Void;
	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X,Y);
		button = new FlxButton(0, 0, "", onClick);
		add(button);
	}

	
	public function build(rect:FlxRect, colour:FlxColor, iconGraphic:FlxGraphicAsset, callback:Void->Void):Void
	{
		this.callback = callback;
		button.makeGraphic(Std.int(rect.width), Std.int(rect.height), colour);
		icon = new FlxSprite((rect.width - 64)/2, (rect.height - 64)/2, iconGraphic);
		add(icon);
	}
	
	public function updateBehaviour(iconGraphic:FlxGraphicAsset, newCallback:Void->Void):Void
	{
		callback = newCallback;
		icon.loadGraphic(iconGraphic);
	}
	
	private function onClick():Void
	{
		FlxG.sound.play(AssetPaths.ui_select__wav);
		if (callback != null)
		{
			callback();
		}
	}
	
	public function stampButton(source:FlxSprite, srcX:Float, srcY:Float):Void
	{
		source.stamp(button, Std.int(srcX + button.x - x), Std.int(srcY + button.y - y));
		source.stamp(icon, Std.int(srcX + icon.x - x), Std.int(srcY + icon.y - y));
	}
}