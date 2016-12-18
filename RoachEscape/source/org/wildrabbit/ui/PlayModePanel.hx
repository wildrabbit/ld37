package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.world.PlaceableItemData;

import org.wildrabbit.ui.Orientation;

typedef PlayOrientationData = 
{
	 var titleRect: FlxRect;
	 var statsRect: FlxRect;
	 var specialTitleRect: FlxRect;
	 
	 var pauseRect: FlxRect;
	 var ffRect: FlxRect;
	 var editRect: FlxRect;
	 
	 var baseX:Int;
	 var baseY:Int;
	 var buttonWidth:Int;
	 var buttonHeight:Int;
	 var spaceX:Int;
	 var spaceY:Int;
	 var colour:FlxColor;
	 var buttonColour:FlxColor;
	 var buttonSize:Int;
}

/**
 * ...
 * @author ith1ldin
 */
class PlayModePanel extends FlxTypedSpriteGroup<FlxSprite>
{
	private var parent:PlayState;
	
	public var panelTitle: FlxText;
	
	public var title: FlxText;
	
	public var specialTitle: FlxText;
	
	// TODO: 
	// Stats
	// Special stats for level
	
	public var button1: ActionButton;
	public var button2: ActionButton;
	public var button3:ActionButton;
	
		private var orientations: Array<PlayOrientationData> = [
		{
			titleRect: FlxRect.get(0, 0, 0, 0),
			specialTitleRect: FlxRect.get(0,0,0,0),
			statsRect: FlxRect.get(0,0,0,0),
			pauseRect: FlxRect.get(12,583,168,56),
			ffRect: FlxRect.get(12, 656, 168, 56),
			editRect: FlxRect.get(12, 720, 168, 56),
			baseX: 12,
			baseY: 91,
			buttonWidth: 72,
			buttonHeight: 96,
			spaceX:24,
			spaceY:24,
			colour:FlxColor.fromString("#AF980B"),
			buttonColour:FlxColor.fromRGB(130,0,37),
			buttonSize:20
		},
		{
			titleRect: FlxRect.get(0, 0, 0, 0),
			specialTitleRect: FlxRect.get(0,0,0,0),
			statsRect: FlxRect.get(0,0,0,0),
			pauseRect: FlxRect.get(12,583,168,56),
			ffRect: FlxRect.get(12, 656, 168, 56),
			editRect: FlxRect.get(12, 720, 168, 56),
			baseX: 12,
			baseY: 91,
			buttonWidth: 72,
			buttonHeight: 96,
			spaceX:24,
			spaceY:24,
			colour:FlxColor.fromString("#AF980B"),
			buttonColour:FlxColor.fromRGB(130,0,37),
			buttonSize:20			
		}
	];
	
	private var currentOrientation:Orientation = Orientation.LANDSCAPE;
	
	public function new(parent:PlayState) 
	{
		super(800, 0);
		this.parent = parent;
		
		var config:PlayOrientationData = orientations[Type.enumIndex(currentOrientation)];
		
		button1 = initButton(config.pauseRect, onPauseToggle, config.buttonColour, AssetPaths.pause__png);
		
		button2 = initButton(config.ffRect, onFastForward, config.buttonColour, AssetPaths.fastforward__png);
		
		button3 = initButton( config.editRect, onEdit, config.buttonColour, AssetPaths.build__png);
	}
	
	private function initButton(rect:FlxRect, callback:Void->Void, bgColour:FlxColor ,icon:Dynamic):ActionButton
	{
		var btn:ActionButton = new ActionButton(rect.x, rect.y);
		btn.build(rect,bgColour, icon, callback);
		add(btn);
		return btn;
	}
		
	//-----------------------------------
	public function onPauseToggle():Void 
	{
		parent.togglePause();
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onFastForward():Void
	{
		parent.onFastForward();
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onEdit(): Void 
	{
		parent.setStageMode(StageMode.EDIT);
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onPlay():Void
	{
		parent.playPressed();
		FlxG.sound.play(AssetPaths.play__wav);

	}
	
	public function onMenu():Void
	{
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onNextLevel():Void
	{
		
	}
	//-----------------------------------
	
	public function goToEdit():Void
	{
		visible = false;
		active = false;
	}
	
	public function goToPlay():Void
	{
		visible = true;
		active = true;

		// update action buttons:
		button1.updateBehaviour(AssetPaths.pause__png, onPauseToggle);
		button2.updateBehaviour(AssetPaths.fastforward__png, onFastForward);
		button3.updateBehaviour(AssetPaths.build__png, onEdit);
	}
	
	public function goToGameLost():Void
	{
		// update action buttons:
		button1.updateBehaviour(AssetPaths.play__png, onPlay);
		button2.updateBehaviour(AssetPaths.menu__png, onMenu);
		button3.updateBehaviour(AssetPaths.build__png, onEdit);
	}
	
	public function goToGameWon():Void
	{
		button1.updateBehaviour(AssetPaths.next__png, onNextLevel);
		button2.updateBehaviour(AssetPaths.play__png, onPlay);
		button3.updateBehaviour(AssetPaths.build__png, onEdit);
	}
	
	public function goToPause():Void
	{
		button1.updateBehaviour(AssetPaths.play__png, onPauseToggle);
		button2.updateBehaviour(AssetPaths.menu__png, onMenu);
		button3.updateBehaviour(AssetPaths.build__png, onEdit);
	}
}