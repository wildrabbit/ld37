package org.wildrabbit.ui.pages;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxSpriteAniRot;
import flixel.addons.ui.FlxButtonPlus;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.ActionButton;
import org.wildrabbit.ui.TabPage;

/**
 * ...
 * @author ith1ldin
 */
class SettingsPage extends TabPage
{
	private var parent:PlayState;
	
	private var resetButton:FlxButton;
	private var globalSoundMuteTickBox:FlxButton;
	private var globalSoundMuteTick:FlxSprite;
	private var globalSoundMuteText:FlxText;
	
	public function new(state:PlayState, ?x:Float=0, ?y:Float=0) 
	{
		super(x, y);
		parent = state;
		
		var atlas:FlxAtlasFrames = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		
		globalSoundMuteText = new FlxText(64, 32, 180, "SOUND ENABLED", 20);
		globalSoundMuteText.color = FlxColor.WHITE;
		globalSoundMuteText.font = AssetPaths.small_text__ttf;
		add(globalSoundMuteText);
		
		globalSoundMuteTickBox = new FlxButton(32, 32, "", onToggleSound);
		globalSoundMuteTickBox.loadGraphic(FlxGraphic.fromFrame(atlas.getByName(UIAtlasNames.TICK_BOX)));
		add(globalSoundMuteTickBox);
		
		globalSoundMuteTick = new FlxSprite(32, 32);
		globalSoundMuteTick.frame = atlas.getByName(UIAtlasNames.TICK);
		add(globalSoundMuteTick);
		globalSoundMuteTick.visible = !FlxG.sound.muted;
		
		resetButton = new FlxButton(32, 96, "RESET SAVE", onResetSaveButton);
		resetButton.loadGraphic(AssetPaths.reset_btn__png);
		resetButton.label.fieldWidth = 160;
		resetButton.label.color = FlxColor.WHITE;
		resetButton.label.size = 18;
		add(resetButton);
	}
	
	public function onResetSaveButton():Void
	{
		parent.resetSave();
	}
	
	public function onToggleSound():Void
	{
		FlxG.sound.muted = !FlxG.sound.muted;
		globalSoundMuteTick.visible = !FlxG.sound.muted;
	}
	
}