package org.wildrabbit.roach;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxPointer;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import org.wildrabbit.ui.HUD;
import org.wildrabbit.world.Actor;
import org.wildrabbit.world.Goal;
import org.wildrabbit.world.LevelData;
import org.wildrabbit.world.PlaceableItem;
import org.wildrabbit.world.PlaceableItemData;
import org.wildrabbit.world.Player;
import org.wildrabbit.world.PlayerData;

enum StageMode
{
	EDIT;
	PLAY;
	PAUSE;
}

typedef PlaceableItemTool =
{
	var id:Int;
	var amount:Int;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private static inline var AWAKE_DELAY:Float = 1.5;
	public var levelData:LevelData;
	
	private var layerVec: Array<FlxTilemapExt>;
	
	private var bgLayers = new FlxTypedGroup<FlxTilemapExt>();
	private var bgLayer:FlxTilemapExt;
	private var mapLayers:FlxTypedGroup<FlxTilemapExt>;
	
	private var hud:HUD;
	
	private var title:FlxText;
	
	private var stageMode:StageMode;
	private var timeToAwake:Float;
	

	public var player:Player;
	public var goal:Goal;
	
	public var actors: Array<Actor>;
	public var placedItems: FlxTypedGroup<PlaceableItem>;
	
	public var currentTools: Array<PlaceableItemTool>;
	public var toolLibrary: Map<Int,PlaceableItemData>;
	
	private var mouseMgr: FlxMouseEventManager;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		FlxG.plugins.add(new FlxMouseEventManager());
		
		buildItemLibrary();
		
		actors = new Array<Actor>();
		
		stageMode = StageMode.EDIT;
		timeToAwake = -1;
		
		player = null;
		goal = null;
		layerVec = new Array<FlxTilemapExt>();
		
		bgLayers = new FlxTypedGroup<FlxTilemapExt>();
		add(bgLayers);
		bgLayer = null;
		
		placedItems = new FlxTypedGroup<PlaceableItem>();
		add(placedItems);
		
		mapLayers = new FlxTypedGroup<FlxTilemapExt>();
		add(mapLayers);

		
		levelData = new LevelData("assets/data/level0.tmx");
		levelData.build(this);	
		
		currentTools = [
			{id:0, amount:1 },
			{id:1, amount:2 },
		];
		hud = new HUD(this);
		hud.buildToolButtons(currentTools, toolLibrary);
		
		add(hud);
		
		title = new FlxText(850, 44, 0, "TOOLS", 24);
		title.color.setRGB(130, 0, 37);
		add(title);
	}
	
	public function click(layer:FlxTilemapExt):Void
	{
		trace(layer);
	}
	
	public function buildPlayer(playerData: PlayerData):Void
	 {				
		player = new Player();
		player.init(this, playerData);
		add(player);
		
		actors.push(player);
	 }
	 
	 public function buildGoal(startCoords: FlxPoint):Void
	 {
		goal = new Goal();
		var pos:FlxPoint = levelData.getWorldPositionFromTileCoords(startCoords);
		goal.setPosition(pos.x, pos.y);
		add(goal);
		
		actors.push(goal);
	 }
	
	public function addTileLayer(layer:FlxTilemapExt):Void
	{
		mapLayers.add(layer);
		layerVec.push(layer);
	}
	
	public function setBgLayer(layer:FlxTilemapExt):Void
	{
		if (bgLayer != null)
			bgLayers.remove(bgLayer);
		bgLayer = layer;
		FlxMouseEventManager.add(bgLayer, click, null, null, null, false, true);
		layerVec.push(layer);
		bgLayers.add(bgLayer);
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
		
		if (timeToAwake >= 0)
		{
			timeToAwake -= dt;
			if (timeToAwake <= 0)
			{
				for (a in actors)
				{
					a.startPlaying();
				}
			}
		}
	}
	
	public function toggleTool(i:Int):Void
	{
		if (stageMode == StageMode.EDIT)
		{
		}
	}
	
	public function playPressed():Void
	{
		switch(stageMode)
		{
			case StageMode.EDIT:
			{
				stageMode = StageMode.PLAY;
				timeToAwake = AWAKE_DELAY;
			}
			case StageMode.PAUSE: 
			{ 
				stageMode  = StageMode.PLAY; 
				for (a in actors)
				{
					a.pause(false);
				}
			}
			case StageMode.PLAY: 
			{ 
				stageMode = StageMode.PAUSE; 
				for (a in actors)
				{
					a.pause(true);
				}
			}			
		}
	}
	
	public function resetPressed(): Void 
	{
		switch(stageMode)
		{
			case StageMode.EDIT:
			{
				// Clear placed items
			}
			case StageMode.PAUSE:
			{
				stageMode = StageMode.EDIT;
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
			}
			case StageMode.PLAY:
			{
				stageMode = StageMode.EDIT;
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
				
			}
		}	
	}
	
	public function isPlaying():Bool
	{
		return stageMode == StageMode.PLAY && timeToAwake < 0;
	}
	
	public function buildItemLibrary():Void
	{
		toolLibrary = new Map<Int,PlaceableItemData>();
		var types: Array<String> = ["changeDir", "changeDir", "changeDir", "changeDir"];
		
		var subtypes:Array<String> = ["left", "right", "up", "down"];
		var btnNames:Array<String> = ["DIR-L", "DIR-R", "DIR-U", "DIR-D"];
		var linkedEntities:Array<String> = ["", "", "", ""];
		for (i in 0...4)
		{
			var placeable:PlaceableItemData = new PlaceableItemData();
			placeable.templateID = i;
			placeable.type = types[i];
			placeable.subtype = subtypes[i];
			placeable.linkedEntityType = linkedEntities[i];
			placeable.btnName = btnNames[i];
			toolLibrary[i] = placeable;
		}
	}
}