package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class TabWidget extends FlxSpriteGroup
{
	var tabButtons:Array<TabButton> = new Array<TabButton>();
	var tabPages:Array<TabPage> = new Array<TabPage>();
	var pageBackground:FlxSprite;
	
	var nextButtonsPos:FlxPoint = FlxPoint.get().set(12,0);
	var pagePos:FlxPoint = FlxPoint.get().set(0,66);
	
	var tabPageBackground:FlxGraphicAsset = AssetPaths.tab_bg__png;
	
	var currentPageIdx:Int = -1;
	
	var atlas:FlxAtlasFrames = null;
	
	public function new(?x:Float = 0, ?y:Float = 0, ?config:Dynamic = null) 
	{
		super(x,y);
		
		atlas = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		pageBackground = new FlxSprite(pagePos.x, pagePos.y, tabPageBackground);
		add(pageBackground);
	}	
	
	public function addPage(buttonGfx:String, txt:String, page:TabPage):Void
	{
		var btn:TabButton = new TabButton(this, nextButtonsPos, atlas, buttonGfx, txt, tabButtons.length);
		btn.setInactive();
		nextButtonsPos.x += btn.width + 2;
		
		tabButtons.push(btn);
		add(tabButtons[tabButtons.length -1]);
		
		page.setPosition(pagePos.x, pagePos.y);
		tabPages.push(page);
		
		setPage(tabButtons.length - 1);
		// Don't add.
	}
	
	public function setPage(pageIdx:Int):Void
	{
		if (currentPageIdx >= 0)
		{
			tabButtons[currentPageIdx].setInactive();
			tabPages[currentPageIdx].disable();
			remove(tabPages[currentPageIdx]);
		}
		
		currentPageIdx = pageIdx;
		
		add(tabPages[currentPageIdx]);		
		tabButtons[currentPageIdx].setActive();
		tabPages[currentPageIdx].enable();
		tabPages[currentPageIdx].refreshVisibility();
	}
	
	public function setPageEnabled(pageIdx:Int, value:Bool):Void
	{
		if (value)
		{			
			tabButtons[pageIdx].setActive();
			tabPages[pageIdx].enable();
			tabPages[pageIdx].refreshVisibility();
		}
		else 
		{
			tabButtons[pageIdx].setInactive();
			tabPages[pageIdx].disable();	
		}
	}
	
	public function setActivePageEnabled(value:Bool):Void
	{
		setPageEnabled(currentPageIdx, value);
	}
	
	public function refreshVisibility():Void
	{
		for (page in tabPages)
		{
			page.refreshVisibility();
		}		
	}
}