package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.EndState;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.roach.Reg;
import org.wildrabbit.world.GameWorldState.ObjectiveState;

/**
 * TODO: Implement full sequence
 * @author ith1ldin
 */
class VictoryPopup extends FlxSpriteGroup
{
	private static inline var TITLE_TEXT:String = "You win!!";
	
	private static inline var BTN_NEXT:Int = 0;
	private static inline var BTN_EDIT:Int = 1;
	private static inline var BTN_MENU:Int = 2;
	private static inline var NUM_BUTTONS:Int = 3;
	
	private var bgLayer:FlxSprite;
	
	private var container:FlxSpriteGroup;
	private var clippingRect:FlxRect = FlxRect.get(148, 176, 512, 416);
	
	private var popupBg:FlxSprite;
	private var popupDeco:FlxSprite;
	private var roachie:FlxSprite;
	private var cropRoachie:FlxSprite;
	
	private var title:FlxText;
	private var popupInfo:FlxText;
	
	private var init:Bool = false;
	
	private var buttons:Array<ActionButton>;
	private var newGoals:Array<GoalPanel>;
	private var currentGoal:Int = -1;
	
	private var goalTimer:FlxTimer;
	
	public function new() 
	{
		super(0, 0);
		
		bgLayer = new FlxSprite(0, 0);
		bgLayer.makeGraphic(FlxG.width, FlxG.height, 0x80000000);		
		add(bgLayer);
		
		container = new FlxSpriteGroup();
		add(container);
		
		popupBg = new FlxSprite(148, 176);
		popupBg.makeGraphic(512, 416, FlxColor.BLACK);
		container.add(popupBg);		
		
		popupDeco = new FlxSprite(148, 310, AssetPaths.popup_deco__png);
		container.add(popupDeco);
		
		title = new FlxText(266, 212, 278, TITLE_TEXT,48);				
		title.alignment = FlxTextAlign.CENTER;
		container.add(title);
		

		newGoals = new Array<GoalPanel>();
		buttons = new Array<ActionButton>();
		goalTimer = new FlxTimer();
	}
	
	override public function update(dt:Float):Void
	{
		super.update(dt);
		if (!init) return;
		if (roachie.x > 596)
		{
			container.remove(roachie);
			roachie.moves = false;
		}
		else 
		{
			var r:FlxRect = FlxRect.get(60,16,64,64);
			var old:FlxRect = roachie.clipRect;
			
			roachie.clipRect = r;
			r.put();
			if (old != null) old.put();	
		}
	}
	

	public function onNextClick():Void 
	{
		// TODO: Replace copy-pasted code with some proper level logic :/
		if (Reg.gameWorld.currentLevelIdx >= Reg.currentWorld.levels.length - 1)
		{
			if (Reg.gameWorld.currentWorldIdx >= Reg.worlds.length - 1)
			{
				FlxG.switchState(new EndState());				
			}
			else 
			{
				Reg.gameWorld.currentWorldIdx++;
				Reg.gameWorld.currentLevelIdx = 0;
				Reg.currentWorld = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx];
				Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
			}
		}
		else 
		{
			Reg.gameWorld.currentLevelIdx++;
			Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
		}
		
		FlxTween.tween(scale, { x:0, y:0 }, 0.25, { ease:FlxEase.backIn, onComplete: function(t:FlxTween):Void 
			{ 
				destroy(); 
				FlxG.switchState(new PlayState()); 				
			}			
		} );
	}
	
	public function onEditClick():Void
	{
		FlxTween.tween(scale, { x:0, y:0 }, 0.15, { ease:FlxEase.backIn, onComplete: function(t:FlxTween):Void 
			{ 
				destroy(); 
				cast(FlxG.state, PlayState).setStageMode(StageMode.EDIT);
				//FlxG.switchState(new PlayState()); 				
			}			
		} );
	}
	
	public function onMenuClick():Void
	{
		trace("Menu!");
	}
	
	public function start(completedObjectives:Array<Int>):Void
	{
		init = false;
		popupBg.scale.set(0.25, 0.25);
		var t:FlxTween = FlxTween.tween(popupBg.scale, { "x": 1, "y":1 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut, onComplete:onIntroAnimFinished } );
		
		popupDeco.scale.set(0.25, 0.25);
		var t:FlxTween = FlxTween.tween(popupDeco.scale, { "x": 1, "y":1 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut } );
		
		title.scale.set(0.25, 0.25);
		var t:FlxTween = FlxTween.tween(title.scale, { "x": 1, "y":1 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut } );
		
		var atlas:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		var objStateList:Array<ObjectiveState> = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx].objectives;
		for (i in completedObjectives)
		{			
			var medalIdx:Int = i;
			var objState:ObjectiveState = objStateList[medalIdx];
			var revealed:Bool = medalIdx < 2 || objState.completed || objStateList[medalIdx - 1].completed;
			newGoals.push(new GoalPanel(300, 400, atlas, medalIdx, Reg.currentLevel.objectives[medalIdx].getText(), revealed, false));
		}
	}
	
	public function onIntroAnimFinished(t:FlxTween):Void
	{
		
		roachie = new FlxSprite(148, 310, AssetPaths.roachie_win__png);
		roachie.moves = true;
		roachie.velocity.set(256,0);
		roachie.angularVelocity = 360;
		container.add(roachie);
		
		var btnStart:FlxPoint = new FlxPoint(174, 508);
		var btnWidth:Float = 146;
		var btnHeight = 56;
		var btnSpace:Float = 8;
		for (i in 0...NUM_BUTTONS)
		{
			buttons.push(new ActionButton(btnStart.x, btnStart.y));			
			btnStart.x += (btnWidth + btnSpace);
			container.add(buttons[buttons.length - 1]);
		}
		
		buttons[BTN_NEXT].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(130, 0, 37), AssetPaths.next__png, onNextClick);
		buttons[BTN_EDIT].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(130, 0, 37), AssetPaths.build__png, onEditClick);
		buttons[BTN_MENU].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(128, 128, 128), AssetPaths.menu__png, onMenuClick);		
		
		init = true;
		
		if (newGoals.length > 0 && currentGoal == -1)
		{
			currentGoal = 0;
			container.add(newGoals[currentGoal]);
			
			goalTimer.start(0.2, onRevealGoal, 1);
		}		
	}
	
	public function onRevealGoal(timer:FlxTimer):Void
	{
		newGoals[currentGoal].setRevealed(true, true);
		if (currentGoal != newGoals.length - 1)
		{
			goalTimer.start(0.5, onNextGoal, 1);
		}
		else 
		{
			goalTimer.start(0.5, onLastGoal, 1);
		}
	}
	public function onNextGoal(timer:FlxTimer):Void
	{
		container.remove(newGoals[currentGoal]);
		currentGoal++;
		container.add(newGoals[currentGoal]);
		goalTimer.start(0.2, onRevealGoal, 1);
	}
	
	public function onLastGoal(timer:FlxTimer):Void
	{
		container.remove(newGoals[currentGoal]);
	}
}