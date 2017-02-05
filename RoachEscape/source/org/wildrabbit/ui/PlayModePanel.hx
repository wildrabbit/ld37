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
import org.wildrabbit.ui.pages.GoalsPage;
import org.wildrabbit.ui.pages.SettingsPage;
import org.wildrabbit.ui.pages.StatsPage;
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
	
	public var button1: ActionButton;
	public var button2: ActionButton;
	public var button3:ActionButton;
	
	private var atlas: FlxAtlasFrames;
	
	public var tabWidget: TabWidget;
	
	public var statsPage: StatsPage;
	public var goalsPage: GoalsPage;
	public var settingsPage: SettingsPage;
	
	private static inline var TITLE_TEXT:String = "PLAYBACK";
	
	private static inline var PAGE_GOALS:Int = 0;
	private static inline var PAGE_STATS:Int = 1;
	
	private var orientations: Array<PlayOrientationData> = [
	{
		titleRect: FlxRect.get(0, 48, 0, 0),
		specialTitleRect: FlxRect.get(0,350,0,0),
		statsRect: FlxRect.get(0,0,0,0),
		pauseRect: FlxRect.get(0,100,68,68),
		ffRect: FlxRect.get(88, 100, 68, 68),
		editRect: FlxRect.get(176, 100, 68, 68),
		baseX: 12,
		baseY: 4,
		buttonWidth: 72,
		buttonHeight: 96,
		spaceX:24,
		spaceY:16,
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

		var config:PlayOrientationData = orientations[Type.enumIndex(currentOrientation)];

		panelTitle = new FlxText(config.titleRect.x, config.titleRect.y, 256, "", 30);
		panelTitle.alignment = FlxTextAlign.CENTER;
		panelTitle.text = TITLE_TEXT;
		add(panelTitle);

		//initGoalsPanel();
		//initStatsPanel();
		
		goalsPage = new GoalsPage(parent);
		statsPage = new StatsPage(parent);
		settingsPage = new SettingsPage(parent);
		
		tabWidget = new TabWidget(0, 210);
		add(tabWidget);
		tabWidget.addPage(UIAtlasNames.ICON_GOALS, "GOALS", goalsPage);
		tabWidget.addPage(UIAtlasNames.ICON_STATS, "STATS", statsPage);
		tabWidget.addPage(UIAtlasNames.ICON_SETTINGS, "SETTINGS", settingsPage);
		tabWidget.setPage(0);

		button1 = initButton(config.pauseRect, onPauseToggle, config.buttonColour, AssetPaths.pause__png);		
		button2 = initButton(config.ffRect, onFastForward, config.buttonColour, AssetPaths.fastforward__png);		
		button3 = initButton( config.editRect, onEdit, config.buttonColour, AssetPaths.stop__png);
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
	}
	
	public function onFastForward():Void
	{
		parent.onFastForward();
	}
	
	public function onEdit(): Void 
	{
		parent.setStageMode(StageMode.EDIT);
	}
	
	public function onPlay():Void
	{
		parent.playPressed();
		FlxG.sound.play(AssetPaths.play__wav);
		statsPage.resetScale();
	}
	
	public function onMenu():Void
	{
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
		
		tabWidget.setPage(PAGE_STATS);
		tabWidget.refreshVisibility();
		
		// update action buttons:
		button1.updateBehaviour(AssetPaths.pause__png, onPauseToggle);
		button2.updateBehaviour(AssetPaths.fastforward__png, onFastForward);
		button3.updateBehaviour(AssetPaths.stop__png, onEdit);
	}
	
	public function goToGameLost():Void
	{
		tabWidget.setPage(PAGE_GOALS);
		// update action buttons:
		button1.updateBehaviour(AssetPaths.play__png, onPlay);
		button2.updateBehaviour(AssetPaths.menu__png, onMenu);
		button3.updateBehaviour(AssetPaths.stop__png, onEdit);
	}
	
	public function goToGameWon():Void
	{
		tabWidget.setPage(PAGE_GOALS);
		button1.updateBehaviour(AssetPaths.next__png, onNextLevel);
		button2.updateBehaviour(AssetPaths.play__png, onPlay);
		button3.updateBehaviour(AssetPaths.stop__png, onEdit);
	}
	
	public function goToPause():Void
	{
		button1.updateBehaviour(AssetPaths.play__png, onPauseToggle);
		button2.updateBehaviour(AssetPaths.menu__png, onMenu);
		button3.updateBehaviour(AssetPaths.build__png, onEdit);
	}

	
	public function playStatFail(type:StatType):Void
	{
		statsPage.playFail(type);
	}
	
	public function updateObjective(idx:Int, completed:Bool):Void
	{
		goalsPage.updateObjective(idx, completed);
	}
	
	public function setGoalRevealed(idx:Int, revealed:Bool, completed:Bool):Void
	{
		goalsPage.setGoalRevealed(idx, revealed, completed);
	}
}