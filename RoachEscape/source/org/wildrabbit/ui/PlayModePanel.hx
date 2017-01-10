package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.data.ObjectiveData;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.roach.Reg;
import org.wildrabbit.world.GameStats.StatType;
import org.wildrabbit.world.GameWorldState.ObjectiveState;
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
	
	// Goals
	private var goals:Array<ObjectivePanel>;
	// Special stats for level
	private var stats:Array<StatPanel>;
	
	public var button1: ActionButton;
	public var button2: ActionButton;
	public var button3:ActionButton;
	
	private var atlas: FlxAtlasFrames;
	
	private static inline var GOALS_TEXT:String = "GOALS";
	private static inline var STATS_TEXT:String = "STATS";
	
	private var orientations: Array<PlayOrientationData> = [
	{
		titleRect: FlxRect.get(0, 0, 0, 0),
		specialTitleRect: FlxRect.get(0,350,0,0),
		statsRect: FlxRect.get(0,0,0,0),
		pauseRect: FlxRect.get(36,574,168,56),
		ffRect: FlxRect.get(36, 638, 168, 56),
		editRect: FlxRect.get(36, 702, 168, 56),
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
		pauseRect: FlxRect.get(36,574,168,56),
		ffRect: FlxRect.get(36, 638, 168, 56),
		editRect: FlxRect.get(36, 702, 168, 56),
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
		super(768, 0);
		this.parent = parent;

		atlas = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		var config:PlayOrientationData = orientations[Type.enumIndex(currentOrientation)];

		panelTitle = new FlxText(config.titleRect.x, config.titleRect.y, 256, "", 32);
		panelTitle.alignment = FlxTextAlign.CENTER;
		panelTitle.text = GOALS_TEXT;
		add(panelTitle);

		initGoalsPanel();
		initStatsPanel();

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
	
	private function initGoalsPanel():Void 
	{
		goals = new Array<ObjectivePanel>();
		
		var objRef:Array<ObjectiveData> = Reg.currentLevel.objectives;
		var height:Float = 36;
		var medalIdx:Int = 0;
		var offset:Float = 60;
		var objStateList:Array<ObjectiveState> = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx].objectives;
		for (objectiveData in objRef)
		{
			var objState:ObjectiveState = objStateList[medalIdx];
			var revealed:Bool = medalIdx < 2 || objState.completed || objStateList[medalIdx - 1].completed;
			var obj:ObjectivePanel = new ObjectivePanel(5, offset, atlas, medalIdx, objectiveData.getText(), revealed, objState.completed);
			add(obj);	
			medalIdx++;
			offset += height;
			goals.push(obj);
		}		
	}
	
	private function initStatsPanel():Void
	{
		var config:PlayOrientationData = orientations[Type.enumIndex(currentOrientation)];
		specialTitle = new FlxText(config.specialTitleRect.x, config.specialTitleRect.y, 256, "", 32);
		specialTitle.alignment = FlxTextAlign.CENTER;
		specialTitle.text = STATS_TEXT;
		add(specialTitle);
		var offset:Float = 400;
		var height:Float = 36;
		
		stats = new Array<StatPanel>();

		var stat:Array<StatType> = [StatType.TILES_TRAVERSED, StatType.TILES_PLACED, StatType.TIME_SPENT];
		for (st in stat)
		{
			var stPanel:StatPanel = new StatPanel(5, offset, atlas, st);
			add(stPanel);
			offset += height;
			stats.push(stPanel);
		}
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
		for (stat in stats)
		{
			stat.resetScale();
		}
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
		
		var objStateList:Array<ObjectiveState> = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx].objectives;
		var medalIdx:Int = 0;
		
		for (goal in goals)
		{
			var objState:ObjectiveState = objStateList[medalIdx];
			var revealed:Bool = medalIdx < 2 || objState.completed || objStateList[medalIdx - 1].completed;
			goal.setRevealed(revealed, objState.completed);
			medalIdx++;						
		}						

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
	
	public function updateObjective(idx:Int, completed:Bool):Void
	{
		var revealed:Bool = goals[idx].tickBox.visible;
		goals[idx].setRevealed(completed ? true : revealed, completed);		
	}
	
	public function setGoalRevealed(idx:Int, revealed:Bool, completed:Bool):Void
	{
		goals[idx].setRevealed(revealed, completed);
	}
	
	public function playStatFail(type:StatType):Void
	{
		var stPanel:StatPanel = stats[Type.enumIndex(type)];
		if (stPanel == null) return;
		stPanel.playFail();
	}
}