package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
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
	private static inline var YOU_LOST_TEXT:String = "KEEP TRYING!";

	public var gameModeTitle: FlxText;

	public var editPanel: EditModePanel;
	public var playPanel: PlayModePanel;
	
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
		
		gameModeTitle = new FlxText(384 - 150, 0, 0, EDIT_TEXT, 36);
		add(gameModeTitle);
		
		editPanel = new EditModePanel(parent);
		add(editPanel);
		
		playPanel = new PlayModePanel(parent);
		add(playPanel);
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
				playPanel.goToEdit();				
			}
			case StageMode.OVER:
			{
				if (parent.result == Result.WON)
				{
					gameModeTitle.text =  YOU_WON_TEXT;
					playPanel.goToGameWon();					
				}
				else 
				{
					gameModeTitle.text = YOU_LOST_TEXT;
					playPanel.goToGameLost();					
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
				
				editPanel.goToPlay();
				playPanel.goToPlay();
			}
		}
	}
}