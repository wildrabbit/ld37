package org.wildrabbit.ui;

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
		baseButton.makeGraphic(W, H, colour);
		txt.setPosition(x + W / 2, y + H - 16);
		txt.visible = false;
		baseButton.text = "??";
	}
	
	public function setToolData(gfx:FlxGraphicAsset, name:String, amount:Int):Void
	{
		txt.visible = true;
		txt.text = Std.string(amount);
		baseButton.text = name;
		if (gfx != null)
		{
			baseButton.loadGraphic(gfx);
		}
		else 
		{
			// makeGraphic(width, height,color);	
		}
	}
	
}