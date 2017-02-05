package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class TabButton extends FlxSpriteGroup
{
	var state:TabButtonState;
	
	var parent:TabWidget;
	var pageIdx:Int;
	
	var button:FlxButton;
	var img:FlxSprite;	
	
	
	public function new(parentWdg:TabWidget, pos:FlxPoint, atlas:FlxAtlasFrames, gfxName:String, txt:String, idx:Int) 
	{
		super(pos.x, pos.y);
		parent = parentWdg;
		pageIdx = idx;
		
		button = new FlxButton(0, 0, txt, tabButtonClicked);		
		add(button);
		setInactive();
		
		img = new FlxSprite(0, 0);
		img.frame = atlas.getByName(gfxName);
		img.x = (button.width - img.frameWidth) / 2;
		img.y = (button.height - img.frameHeight) / 2;
		add(img);
		
		button.label.font = AssetPaths.small_text__ttf;
		button.label.fieldWidth = 72;
		button.label.alignment = FlxTextAlign.CENTER;
		button.label.color = FlxColor.WHITE;
		button.label.setPosition(button.x + 7, button.y + 47);
	}
	
	function tabButtonClicked():Void
	{
		trace("Clicked button " + pageIdx);
		FlxG.sound.play(AssetPaths.ui_tab_tap__wav);
		parent.setPage(pageIdx);
	}	
	
	public function setActive():Void
	{
		state = TabButtonState.ACTIVE;
		button.loadGraphic(AssetPaths.tab_btn_on__png);
		button.active = false;
	}
	
	public function setInactive():Void
	{
		state = TabButtonState.INACTIVE;
		button.loadGraphic(AssetPaths.tab_btn_off__png);
		button.active = true;
	}
}

@:enum
abstract TabButtonState(Int)
{
	var ACTIVE = 0;
	var INACTIVE = 1;
}