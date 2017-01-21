package org.wildrabbit.roach;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.Json;
import openfl.Assets;
import org.wildrabbit.data.WorldData;
import org.wildrabbit.roach.states.MenuState;
import org.wildrabbit.roach.states.TabTest;

class Main extends Sprite 
{
	var gameWidth:Int = 1024; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 768; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = MenuState; // TabTest; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = false; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	
	// You can pretty much ignore everything from here on - your code should go in your states.
	
	public static function main():Void
	{	
		Lib.current.addChild(new Main());
	}
	
	public function new() 
	{
		super();
		
		if (stage != null) 
		{
			init();
		}
		else 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}
	
	private function init(?E:Event):Void 
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		setupGame();
	}
	
	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		
		// Load database
		Reg.worldDatabase = new Map<Int, WorldData>();
		for (mapFile in Reg.worlds)
		{
			var wObject:Dynamic = Json.parse(Assets.getText(mapFile));
			var w:WorldData = new WorldData(wObject);
			Reg.worldDatabase[w.id] = w;
		}
		
		// Initialise state
		Reg.gameWorld.currentWorldIdx = 0;
		Reg.gameWorld.currentLevelIdx = 0;
		Reg.currentWorld = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx];
		Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
		
		Reg.gameWorld.load();
		if (!Reg.worldDatabase.exists(Reg.gameWorld.currentWorldIdx) || Reg.gameWorld.currentLevelIdx < 0 || Reg.gameWorld.currentLevelIdx >= Reg.worldDatabase[Reg.gameWorld.currentWorldIdx].levels.length)
		{
			Reg.gameWorld.clearSave();
			Reg.gameWorld.currentWorldIdx = 0;
			Reg.gameWorld.currentLevelIdx = 0;
		}
		Reg.currentWorld = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx];
		Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		FlxG.sound.volume = 0.1;

		FlxG.log.redirectTraces = true;
	}
}