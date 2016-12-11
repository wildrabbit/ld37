package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

/**
 * ...
 * @author ith1ldin
 */
class ToolButton extends FlxSpriteGroup
{
	public var baseButton:FlxButton;
	public var txt:FlxText;
	private var col:FlxColor;

	public function new(?X:Float = 0, ?Y:Float = 0, txtID:String,callback:Void->Void)
	{
		super(X,Y);		
		baseButton = new FlxButton(0, 0, txtID, callback);
		add(baseButton);
		
		
		txt = new FlxText(0, 0, 0, "", 12);
		add(txt);
	}
	
	public function resetGraphic(W:Int, H:Int, colour:FlxColor):Void
	{
		col = colour;
		baseButton.makeGraphic(W, H, col);
		txt.setPosition(x + W / 2, y + H - 16);
		txt.visible = false;
		baseButton.text = "??";
	}
	
	public function setToolData(path:String, anims:Array<Int>, name:String, amount:Int):Void
	{
		txt.visible = true;
		txt.text = Std.string(amount);
		baseButton.text = name;
		baseButton.loadGraphic(path,true,64,64,false);
		baseButton.animation.add("normal",  [anims[0]], 1, false);
		baseButton.animation.add("highlight", [anims[1]], 1, false);
		baseButton.animation.add("pressed", [anims[1]], 1, false);
		
		baseButton.animation.play("normal");
	}
	
}