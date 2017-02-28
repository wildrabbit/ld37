package org.wildrabbit.roach.states;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import org.wildrabbit.ui.ActionButton;

/**
 * ...
 * @author ith1ldin
 */
class HowtoState extends FlxState
{
	private static inline var START_DELAY:Float = 0.8;
	
	// Batch 1:
	private static inline var TEXT_1:String = "Hi ! I'm Roachie!";
	private static inline var TEXT_2:String = "I need to get here\n=>";
	private static inline var TEXT_3:String = "I'm fast!";
	private static inline var TEXT_4:String = "...and when I bump\nI always turn right";
	private static inline var TEXT_5:String = "...and right";
	private static inline var TEXT_6:String = "...and right!";
	private static inline var TEXT_7:String = "Getting close now\n:)";
	private static inline var TEXT_8:String = "Whoa!";
	private static inline var TEXT_9:String = "Nononono!";
	private static inline var TEXT_10:String = ":(";
	private static inline var TEXT_11:String = "Guess I'm going to need your help";
	
	// Batch 2:		
	private static inline var TEXT_12:String = "Let's go into \"Edit mode\"";
	private static inline var TEXT_13:String = "See that tile?";
	private static inline var TEXT_14:String = "Tiles are neat!";
	private static inline var TEXT_15:String = "When I step on them I'll change direction";
	private static inline var TEXT_16:String = "Let's try again, shall we?";
	private static inline var TEXT_17:String = "The \"Play\" button will get me moving again";
	private static inline var TEXT_18:String = "Here we go!";
	private static inline var TEXT_19:String = "Blazing fast!";
	private static inline var TEXT_20:String = "Okay...let's see what happens now";
	private static inline var TEXT_21:String = "Yay!";
	
	// Batch 3
	private static inline var TEXT_22:String = "These are the basics, but there'll be more surprises.";
	private static inline var TEXT_23:String = "Get me through all the levels!";
	
	private var textX:Array<Float> = [290];
	private var textY:Array<Float> = [192];
	
	private var roachie:FlxSprite;
	private var goal:FlxSprite;
	
	private var playButton:ActionButton;
	
	private var tile:FlxSprite;
	
	private var title:FlxText;
	private var text:FlxText;
	private var bg:FlxSprite;
	private var skipText:FlxText;
	

	private var delay:Float;
	
	private var tween:FlxTween;
	
	private var seqTimer:FlxTimer;
	
	private var construction:FlxSprite;
	
	override public function create():Void
	{
		super.create();	
		bg = new FlxSprite(0, 0, AssetPaths.bg_howto__png);
		add(bg);

		title = new FlxText(312, 36, 400, "HOW TO PLAY", 36);
		title.alignment = FlxTextAlign.CENTER;
		add(title);

		delay = START_DELAY;
		
		startStage1();
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(dt:Float):Void
	{
		super.update(dt);
		
		if (delay >= 0)
		{
			delay -= dt;			
		}
		else 
		{
			if (skipText == null)
			{
/*				msg = new FlxSprite(166, 148, AssetPaths.start__png);
				add(msg);
				t = FlxTween.tween(msg.scale, { x:1.15, y:1.15 }, 0.7, { type:FlxTween.PINGPONG } );*/
				skipText = new FlxText(700, 700, 368, "Press any key to skip...", 20);
				skipText.font = AssetPaths.small_text__ttf;
				skipText.color = FlxColor.WHITE;		
				FlxTween.color(skipText, 0.8, FlxColor.WHITE, FlxColor.BLACK, { type:FlxTween.PINGPONG } );
				add(skipText);				
			}
			if (FlxG.keys.justPressed.ANY|| FlxG.mouse.justPressed)
			{
				finishHowto();
			}
			
		}
	}	
	
	private function startStage1():Void
	{
		var introRoachieCB = function(t:FlxTimer):Void
		{
			roachie = new FlxSprite(318,224);
			roachie.loadGraphic(AssetPaths.entities_00__png, true, 64, 64,false);
			roachie.setFacingFlip(FlxObject.LEFT, true, false);
			roachie.setFacingFlip(FlxObject.RIGHT, false, false);
			roachie.setFacingFlip(FlxObject.UP, false, false);
			roachie.setFacingFlip(FlxObject.DOWN, false, true);
			roachie.animation.add("horizontal", [1], 1, false);
			roachie.animation.add("vertical", [0], 1, false);
			roachie.animation.play("horizontal");
			add(roachie);
			
			seqTimer.start(0.4, startStage2);
		}
		
		seqTimer = new FlxTimer().start(0.5, introRoachieCB);
	}
	
		
	private function startStage2(t:FlxTimer):Void
	{
		text = new FlxText(290, 192, 300, TEXT_1, 20);
		text.font = AssetPaths.small_text__ttf;
		text.color = FlxColor.WHITE;
		add(text);
			

		seqTimer.start(0.8, startStage3);
	}
	
	private function startStage3(t:FlxTimer):Void
	{
		text.setPosition(62, 364); 
		text.alignment = FlxTextAlign.RIGHT; 
		text.text = TEXT_2; 
		goal = new FlxSprite(388, 352);
		goal.loadGraphic(AssetPaths.entities_00__png, true, 64, 64, false);
		goal.animation.add("goal", [15], 1, false);
		goal.animation.play("goal");
		add(goal);
		
		var showText3 = function(t:FlxTimer):Void
		{
			text.setPosition(290, 192); 
			text.alignment = FlxTextAlign.CENTER; 
			text.text = TEXT_3; 
			tween = FlxTween.tween(roachie, { x:640, y:224 }, 1.5, { onComplete:startStage4 } );
		}
		seqTimer = new FlxTimer().start(1, showText3);
	}
	
	private function startStage4(t:FlxTween):Void
	{
		roachie.facing = FlxObject.DOWN;
		roachie.animation.play("vertical");
		
		text.setPosition(730, 220); 
		text.alignment = FlxTextAlign.LEFT; 
		text.text = TEXT_4; 
		
		tween = FlxTween.tween(roachie, { x:640, y:484}, 1.5, { onComplete:startStage5 } );
	}
	
	private function startStage5(t:FlxTween):Void
	{		
		text.setPosition(730, 500); 
		text.alignment = FlxTextAlign.LEFT; 
		text.text = TEXT_5; 
		
		roachie.facing = FlxObject.LEFT;
		roachie.animation.play("horizontal");
		tween = FlxTween.tween(roachie, { x:444, y:484}, 1.5, { onComplete:startStage6 } );
	}
	
	private function startStage6(t:FlxTween):Void
	{
		text.setPosition(120, 518); 
		text.alignment = FlxTextAlign.RIGHT; 
		text.text = TEXT_6; 
		
		var showText7 = function(t:FlxTimer):Void
		{
			text.setPosition(522, 364); 
			text.alignment = FlxTextAlign.LEFT; 
			text.text = TEXT_7; 
		}
		seqTimer.start(0.4, showText7);
		
		roachie.facing = FlxObject.UP;
		roachie.animation.play("vertical");
		tween = FlxTween.tween(roachie, { x:444, y:354}, 1.0, { onComplete:startStage7 } );
	}
	
	private function startStage7(t:FlxTween):Void
	{
		text.setPosition(522, 364); 
		text.alignment = FlxTextAlign.LEFT; 
		text.text = TEXT_8; 
		
		roachie.facing = FlxObject.DOWN;
		roachie.animation.play("vertical");
		tween = FlxTween.tween(roachie, { x:444, y:484}, 0.8 );
		seqTimer.start(0.3, startStage8,1);
	}
	
	private function startStage8(t:FlxTimer):Void
	{
		text.setPosition(522, 424);
		text.text = TEXT_9; 
		
		seqTimer.start(1, startStage9);
	
	}
	private function startStage9(t:FlxTimer):Void
	{
		text.setPosition(460, 560);
		text.text = TEXT_10;
		
		var showText11 = function(t:FlxTimer):Void
		{
			text.text = TEXT_11; 
			seqTimer.start(1.5, startStage10);
		}
		seqTimer.start(0.7, showText11);
	}
	
	private function startStage10(t:FlxTimer):Void
	{
		roachie.setPosition(322, 224);
		text.setPosition(290, 192);
		text.text = TEXT_12;
		
		roachie.facing = FlxObject.RIGHT;
		roachie.animation.play("horizontal");
		
		seqTimer.start(1.0, startStage11);
	}
	
	private function startStage11(t:FlxTimer):Void
	{
		tile = new FlxSprite(440, 120);
		tile.loadGraphic(AssetPaths.entities_00__png, true, 64, 64, false);
		tile.animation.add("tile", [10], 1, false);
		tile.animation.play("tile");
		add(tile);
		
		text.text = TEXT_13;
		
		seqTimer.start(0.6, startStage12);
	}
	
	private function startStage12(t:FlxTimer):Void
	{
		text.text = TEXT_14;
		seqTimer.start(0.6, startStage13);
	}
	
	private function startStage13(t:FlxTimer):Void
	{
		text.text = TEXT_14;
		seqTimer.start(0.6, startStage14);
	}
	
	private function startStage14(t:FlxTimer):Void
	{
		tile.setPosition(450, 354);
		
		text.y -= 16;
		text.text = TEXT_15;
		seqTimer.start(1, startStage15);
	}
	
	private function startStage15(t:FlxTimer):Void
	{
		text.text = TEXT_16;
		seqTimer.start(0.8, startStage16);
	}
	
	private function startStage16(t:FlxTimer):Void
	{
		var r:FlxRect = FlxRect.get(440,100,68,68);
		playButton = new ActionButton(r.x, r.y);
		playButton.build(r,FlxColor.fromRGB(130,0,37), AssetPaths.play__png, null);
		add(playButton);
		
		text.text = TEXT_17;
		seqTimer.start(0.8, startStage17);
	}
	
	private function startStage17(t:FlxTimer):Void
	{
		text.text = TEXT_18;
		remove(roachie);
		remove(tile);
		add(tile);
		add(roachie);
		tween = FlxTween.tween(roachie, { x:640, y:224 }, 1.5, { onComplete:startStage18 } );
	}
	
	private function startStage18(t:FlxTween):Void
	{
		text.text = TEXT_19;
		text.setPosition(730, 220);
		roachie.facing = FlxObject.DOWN;
		roachie.animation.play("vertical");
		tween = FlxTween.tween(roachie, { x:640, y:484}, 1.0, { onComplete:startStage19 } );
	}
	
	private function startStage19(t:FlxTween):Void
	{
		remove(playButton);
		roachie.facing = FlxObject.LEFT;
		roachie.animation.play("horizontal");
		tween = FlxTween.tween(roachie, { x:444, y:484}, 0.8, { onComplete:startStage20 } );
	}
	
	private function startStage20(t:FlxTween):Void
	{
		text.setPosition(120, 518); 
		text.alignment = FlxTextAlign.RIGHT; 
		text.text = TEXT_20; 
		
		roachie.facing = FlxObject.UP;
		roachie.animation.play("vertical");
		tween = FlxTween.tween(roachie, { x:444, y:354}, 0.6, { onComplete:startStage21 } );
	}
	
	private function startStage21(t:FlxTween):Void
	{
		text.setPosition(522, 364); 
		text.alignment = FlxTextAlign.LEFT; 
		text.text = TEXT_21; 
		
		roachie.facing = FlxObject.LEFT;
		roachie.animation.play("horizontal");
		tween = FlxTween.tween(roachie, { x:388, y:352 }, 0.4, { onComplete:startStage22 } );
	}
	
	private function startStage22(t:FlxTween):Void
	{
		text.setPosition(62, 364); 
		text.alignment = FlxTextAlign.RIGHT; 
		text.text = TEXT_22; 
		
		seqTimer.start(0.8, startStage23);
	}
	
	private function startStage23(t:FlxTimer):Void
	{
		text.text = TEXT_23; 
		
		seqTimer.start(0.8, finishHowto);
	}
	
	private function finishHowto(?t:FlxTimer):Void
	{
		FlxG.sound.play(AssetPaths.ui_select__wav, 1, false, null, true, function():Void
		{
			FlxG.switchState(new PlayState());
		});			
	}
}
