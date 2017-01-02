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
 * TODO: Refactor so that both (and potentially other similar) popups reuse the same logic (except for the obvious differences)
 * @author ith1ldin
 */
class DefeatPopup extends FlxSpriteGroup
{
	private static inline var TITLE_TEXT:String = "Keep trying!!";
	
	private static inline var BTN_EDIT:Int = 0;
	private static inline var BTN_MENU:Int = 1;
	private static inline var NUM_BUTTONS:Int = 2;
	
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
		
		popupBg = new FlxSprite(128, 176);
		popupBg.makeGraphic(512, 416, FlxColor.BLACK);
		container.add(popupBg);
		
		// TODO: Deco + roachie
		
		title = new FlxText(128, 212, 512, TITLE_TEXT,48);				
		title.alignment = FlxTextAlign.CENTER;
		container.add(title);
		
		buttons = new Array<ActionButton>();
		
		var btnStart:FlxPoint = new FlxPoint(230, 508);
		var btnWidth:Float = 146;
		var btnHeight = 56;
		var btnSpace:Float = 16;
		for (i in 0...NUM_BUTTONS)
		{
			buttons.push(new ActionButton(btnStart.x, btnStart.y));			
			btnStart.x += (btnWidth + btnSpace);
			container.add(buttons[buttons.length - 1]);
		}
		
		buttons[BTN_EDIT].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(130, 0, 37), AssetPaths.build__png, onEditClick);
		buttons[BTN_MENU].build(FlxRect.weak(0, 0, btnWidth, btnHeight), FlxColor.fromRGB(130, 0, 37), AssetPaths.menu__png, onMenuClick);
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