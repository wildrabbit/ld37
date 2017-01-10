package org.wildrabbit.ui;

import flash.display3D.textures.TextureBase;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.world.PlaceableItemData;

/**
 * ...
 * @author ith1ldin
 */
class HUD extends FlxTypedSpriteGroup<FlxSprite>
{
	private static inline var EDIT_TEXT:String = "EDITING...";
	private static inline var PLAY_TEXT:String = "PLAYING";
	private static inline var PAUSE_TEXT:String = "PAUSED";
	private static inline var YOU_WON_TEXT:String = "VICTORY!";
	private static inline var YOU_LOST_TEXT:String = "UH OH...";

	public var gameModeTitle: FlxText;

	public var editPanel: EditModePanel;
	public var playPanel: PlayModePanel;
	
	public var playDeco: FlxSpriteGroup;
	public var editDeco: FlxSpriteGroup;
	
	//private var playButton:FlxButton;
	//private var resetButton:FlxButton;	
	private var parent: PlayState;
	
	//private var playRect:FlxRect = FlxRect.get(812, 583, 168, 56);
	//private var resetRect:FlxRect = FlxRect.get(812, 656, 168, 56);
	//
	//
	//var baseX: Int = 812;
	//var baseY: Int = 91;
	//var buttonWidth: Int = 72;
	//var buttonHeight: Int = 96;
	//var spaceX: Int = 24;
	//var spaceY: Int = 24;
	//var colour: FlxColor = FlxColor.fromString("#af980b");
	//var buttonColour:FlxColor = FlxColor.fromRGB(130, 0, 37);
	//var buttonSize:Int = 20;
		//
		//
	//private static inline var MAX_BUTTONS:Int = 4;
	
	public function new(parent:PlayState) 
	{
		super(0,0,0);

		this.parent = parent;
		
		gameModeTitle = new FlxText(384 - 192, 0, 384, EDIT_TEXT, 48);
		gameModeTitle.alignment = FlxTextAlign.CENTER;
		add(gameModeTitle);
		
		editPanel = new EditModePanel(parent);
		add(editPanel);
		
		playPanel = new PlayModePanel(parent);
		add(playPanel);
		
		playDeco = new FlxSpriteGroup();
		buildPlayDeco();
		add(playDeco);
		
		editDeco = new FlxSpriteGroup();
		buildEditDeco();
		add(editDeco);
	}
	
	public function onStageModeChanged(stageMode:StageMode)
	{
		//showDecoration(EDIT);
		switch(stageMode)
		{
			case StageMode.EDIT:
			{				
				gameModeTitle.text = EDIT_TEXT;
				editPanel.goToEdit();
				editDeco.visible = true;
				playPanel.goToEdit();	
				playDeco.visible = false;
			}
			case StageMode.OVER:
			{
				if (parent.result == Result.WON)
				{
					gameModeTitle.text =  YOU_WON_TEXT;
					playPanel.goToGameWon();					
					playPanel.active = false;
				}
				else 
				{
					gameModeTitle.text = YOU_LOST_TEXT;
					playPanel.goToGameLost();					
					playPanel.active = false;
				}						
				// change decoration state
				
				// show Layer
				
				// show Menu depending on the result
			}
			case StageMode.PAUSE:
			{
				// show pause panel
				gameModeTitle.text =  PAUSE_TEXT;
				playPanel.goToPause();
			}
			case StageMode.PLAY:
			{
				gameModeTitle.text =  PLAY_TEXT;
				// hide pause panel
				
				// show decoration
				editDeco.visible = false;
				playDeco.visible = true;
				
				editPanel.goToPlay();
				playPanel.goToPlay();
			}
		}
	}
	
	private function buildEditDeco():Void
	{
		var top:FlxSprite = new FlxSprite(16, 28, AssetPaths.deco_construction_top__png);
		editDeco.add(top);
		
		var bot:FlxSprite = new FlxSprite(61, 731, AssetPaths.deco_construction_bottom__png);
		editDeco.add(bot);
		
		var left:FlxSprite = new FlxSprite(16, 37, AssetPaths.deco_construction_left__png);
		editDeco.add(left);
		
		var right:FlxSprite = new FlxSprite(732, 38, AssetPaths.deco_construction_right__png);
		editDeco.add(right);
	}
	
	private function buildPlayDeco():Void
	{
		var small1:FlxSprite = new FlxSprite(22, 16, AssetPaths.deco_yellow_small_right__png);
		playDeco.add(small1);
		
		var small2:FlxSprite = new FlxSprite(614, 16, AssetPaths.deco_yellow_small_right__png);
		playDeco.add(small2);
		
		var large:FlxSprite = new FlxSprite(22, 726, AssetPaths.deco_yellow_full_h__png);
		playDeco.add(large);
		
		var up:FlxSprite = new FlxSprite(0, 0, AssetPaths.deco_yellow_full_v__png);
		up.origin.set(0,0);
		up.angle = -90;
		up.setPosition(22, 696);
		playDeco.add(up);
		
		var down:FlxSprite = new FlxSprite(0, 0, AssetPaths.deco_yellow_full_v__png);
		down.origin.set(0, down.height);
		down.angle = 90;
		down.x = 727;
		down.y = 48;
		playDeco.add(down);
	}
}