package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class ToolButton extends FlxSpriteGroup
{
	public var baseButton:FlxButton;
	public var txt:FlxText;
	private var col:FlxColor;
	private var w:Int;
	private var h:Int;

	public function new(?X:Float = 0, ?Y:Float = 0, txtID:String,callback:Void->Void)
	{
		super(X,Y);		
		baseButton = new FlxButton(0, 0, txtID, callback);
		add(baseButton);
		
		baseButton.label.visible = false;
		txt = new FlxText(0, 0, 0, "", 14);
		add(txt);
		w = 72;
		h = 96;
	}
	
	public function resetGraphic(W:Int, H:Int, colour:FlxColor):Void
	{
		baseButton.loadGraphic(AssetPaths.empty_tool__png);
		txt.text = "";		
	}
	
	public function setToolData(path:String, anims:Array<Int>, name:String, amount:Int):Void
	{
		baseButton.loadGraphic(path, true, 64, 64, false);
		baseButton.setPosition(x + 4, y + 4);
		baseButton.animation.add("normal",  [anims[0]], 1, false);
		baseButton.animation.add("highlight", [anims[1]], 1, false);
		baseButton.animation.add("pressed", [anims[1]], 1, false);
		
		baseButton.animation.play("normal");
		baseButton.text = "";

		txt.visible = true;
		txt.text = Std.string(amount);
		txt.alignment = FlxTextAlign.CENTER;
		txt.size = 14;
		txt.x = x + w / 2 - txt.width / 2;
		txt.y = y + h - txt.height;
	}
	
}