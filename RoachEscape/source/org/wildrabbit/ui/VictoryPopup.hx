package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.EndState;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.roach.Reg;

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
	
	private var popupBg:FlxSprite;
	private var popupDeco:FlxSprite;
	private var roachie:FlxSprite;
	
	private var title:FlxText;
	private var popupInfo:FlxText;
	
	private var buttons:Array<ActionButton>;
	
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
		
		// TODO: Deco + roachie
		
		title = new FlxText(266, 212, 278, TITLE_TEXT,48);		
		
		title.alignment = FlxTextAlign.CENTER;
		container.add(title);
		
		buttons = new Array<ActionButton>();
		
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
		buttons[BTN_MENU].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(130, 0, 37), AssetPaths.menu__png, onMenuClick);
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
		
		FlxTween.tween(scale, { x:0, y:0 }, 0.15, { ease:FlxEase.backIn, onComplete: function(t:FlxTween):Void 
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
	
	public function start():Void
	{
		container.scale.set(0.25, 0.25);
		var t:FlxTween = FlxTween.tween(container.scale, { "x": 1, "y":1 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut, onComplete:null} );
	}
}