package org.wildrabbit.roach;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.util.FlxColor;
import haxe.ds.Vector;
import openfl.Assets;
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
	OVER;
}

enum Result
{
	WON;
	DIED;
	TIMEDOUT;
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
	private var result:Result;
	
	private var selectedToolIdx:Int;
	private var selectedPlaceable:PlaceableItem;
	

	public var player:Player;
	public var goal:Goal;
	
	public var actors: Array<Actor>;
	public var placedItems: FlxTypedGroup<PlaceableItem>;
	
	public var thisLevelTools: Array<PlaceableItemTool>;
	public var currentTools:Array<PlaceableItemTool>;
	public var toolLibrary: Map<Int,PlaceableItemData>;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
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
		selectedToolIdx = -1;

		
		levelData = new LevelData("assets/data/level1.tmx");
		levelData.build(this);
		
		thisLevelTools = [
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 },
		];
		currentTools = [
			{id:0, amount:2 },
			{id:1, amount:2 },
			{id:2, amount:2 },
			{id:3, amount:2 }
		];
		
		//thisLevelTools = [
			//{id:0, amount:1 },
			//{id:1, amount:2 },
		//];
		//currentTools = [
			//{id:0, amount:1 },
			//{id:1, amount:2 },
		//];
		hud = new HUD(this);
		hud.buildToolButtons(currentTools, toolLibrary);
		
		add(hud);
		
		title = new FlxText(850, 44, 0, "TOOLS", 24);
		title.color.setRGB(130, 0, 37);
		add(title);
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
		
		remove(player);
		add(player);
		
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
		//FlxMouseEventManager.add(bgLayer, click, null, null, null, false, true);
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
	
	public function getItemAtPos(coords:FlxPoint): PlaceableItem
	{
		var pos:FlxPoint = FlxPoint.get();
		var newPos:FlxPoint = FlxPoint.get();
		var ret:PlaceableItem = null;
		for (item in placedItems)
		{
			item.getPosition(pos);
			pos.x += item.width/2;
			pos.y += item.height/2;
			
			newPos = levelData.getTilePositionFromWorld(Math.round(pos.x), Math.round(pos.y));
			var x1:Int = Std.int(coords.x);
			var y1:Int = Std.int(coords.y);
			var x2:Int = Std.int(newPos.x);
			var y2:Int = Std.int(newPos.y);
			if (x1 == x2 && y1 == y2)
			{
				ret = item;
				break;
			}
			newPos.put();
		}
		pos.put();
		return ret;
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(dt:Float):Void
	{
		super.update(dt);
		
		var pos:FlxPoint = FlxG.mouse.getWorldPosition();			
		FlxG.log.add(stageMode);
		FlxG.log.add("mouse: " + pos.x + "," + pos.y);
		var fits:Bool = pos.x >= bgLayer.x && pos.x < bgLayer.x + bgLayer.width && pos.y >= bgLayer.y && pos.y < bgLayer.y + bgLayer.height;
		var mouseReleased:Bool = FlxG.mouse.justReleased;
		FlxG.log.add("pos Inside" + fits);
		FlxG.log.add("released? " + mouseReleased);
		if (stageMode == StageMode.EDIT)
		{
			if (fits && mouseReleased)
			{
				var coords:FlxPoint = null;
				pos.subtract(bgLayer.x, bgLayer.y);
				coords = levelData.getTilePositionFromWorld(Math.round(pos.x), Math.round(pos.y));
				trace("click! (" + coords.x + "," + coords.y + ")");
				
				var tile:TileData = levelData.getTileAt(coords);
				if (tile.type != TileType.EMPTY)
				{
					var entity:PlaceableItem = getItemAtPos(coords);
					if (entity != null)
					{
						var selectedToolData:PlaceableItemData = selectedToolIdx >= 0 ? toolLibrary.get(currentTools[selectedToolIdx].id) : null;
						var entityData:PlaceableItemData = entity.itemData;
						
						var existsOther:Bool = selectedToolIdx >= 0 
							&& currentTools[selectedToolIdx].id != entityData.templateID 
							&& currentTools[selectedToolIdx].amount > 0;
						var willReplace:Bool = existsOther && tile.type == selectedToolData.allowedTileType;
						var removeScheduled:Bool = !existsOther || (existsOther && tile.type == selectedToolData.allowedTileType);
						
						if (removeScheduled)
						{
							var templateID:Int = entityData.templateID;
							for (i in 0...currentTools.length)
							{
								if (currentTools[i].id == templateID && currentTools[i].amount < thisLevelTools[i].amount)
								{
									currentTools[i].amount++;
									hud.updateTool(i, currentTools[i].amount);
								}
							}
							trace ("Entity #" + entity.itemData.templateID);
							placedItems.remove(entity);
							actors.remove(entity);
							entity.destroy();							
						}
						
						if (willReplace)
						{
							var item:PlaceableItem = new PlaceableItem();
							item.init(this, selectedToolData);
							var newCoords:FlxPoint = levelData.getWorldPositionFromTileCoords(coords);
							item.setPosition(newCoords.x, newCoords.y);
							newCoords.put();
							currentTools[selectedToolIdx].amount--;
							hud.updateTool(selectedToolIdx, currentTools[selectedToolIdx].amount);
							placedItems.add(item);
							actors.push(item);
						}

					}
					else {
						trace ("No entity!");
						if (selectedToolIdx >= 0 && currentTools[selectedToolIdx].amount > 0)
						{
							var item:PlaceableItem = new PlaceableItem();
							item.init(this, toolLibrary.get(currentTools[selectedToolIdx].id));
							var newCoords:FlxPoint = levelData.getWorldPositionFromTileCoords(coords);
							item.setPosition(newCoords.x, newCoords.y);
							newCoords.put();							
							currentTools[selectedToolIdx].amount--;
							hud.updateTool(selectedToolIdx, currentTools[selectedToolIdx].amount);							
							placedItems.add(item);
							actors.push(item);
						}
					}
				}
				coords.put();
			}
			pos.put();
		}
		
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
			var tool:PlaceableItemTool = currentTools[i];
			if (i >= currentTools.length) return;
			
			if (selectedToolIdx == i || tool.amount == 0)
			{
				selectedToolIdx = -1;
				trace("Deselected tool");			
			}
			else 
			{
				selectedToolIdx = i;
				trace("current tool: " + toolLibrary.get(currentTools[selectedToolIdx].id).templateID);			
			}
			
			
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
				selectedToolIdx = -1;
				selectedPlaceable = null;
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
			case StageMode.OVER: 
			{ 
				stageMode = StageMode.EDIT; 
				timeToAwake = -1;
				for (a in actors)
				{
					a.resetToDefaults();
				}
			}	
		}
	}
	private function resetTools():Void
	{
		for (i in placedItems)
		{
			actors.remove(i);
		}
		placedItems.forEach(function(x:PlaceableItem):Void { x.destroy(); } );
		placedItems.clear();
		selectedToolIdx = -1;
		selectedPlaceable = null;
		currentTools.splice(0, currentTools.length);
		for (i in 0...thisLevelTools.length)
		{					
			currentTools.push( { id: thisLevelTools[i].id, amount:thisLevelTools[i].amount } );
			hud.updateTool(i, currentTools[i].amount);
		}

	}
	public function resetPressed(): Void 
	{
		switch(stageMode)
		{
			case StageMode.EDIT:
			{
				// Clear placed items
				resetTools();
			}
			case StageMode.PAUSE:
			{
				stageMode = StageMode.EDIT;
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
				resetTools();
			}
			case StageMode.PLAY:
			{
				stageMode = StageMode.EDIT;
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
				resetTools();
			}
			case StageMode.OVER:
			{
				// Clear placed items
				// TO MENU?
				stageMode = StageMode.EDIT;
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
				resetTools();
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
		var allowedTypes:Array<TileType> = [TileType.GROUND, TileType.GROUND, TileType.GROUND, TileType.GROUND];
		
		var spritePath:String = "assets/images/entities_00.png";
		var spriteAnims:Array<Array<Int>> = [[10,11], [6,7], [8,9], [12,13]];
		
		for (i in 0...4)
		{
			var placeable:PlaceableItemData = new PlaceableItemData();
			placeable.templateID = i;
			placeable.type = types[i];
			placeable.subtype = subtypes[i];
			placeable.linkedEntityType = linkedEntities[i];
			placeable.btnName = btnNames[i];
			placeable.spritePath = spritePath;
			placeable.spriteAnims = spriteAnims[i];
			placeable.allowedTileType = allowedTypes[i];
			toolLibrary[i] = placeable;
		}
	}
	
	public function onReachedGoal():Void
	{
		stageMode = StageMode.OVER;
		result = Result.WON;
		for (a in actors)
		{
			a.pause(true);		
		}
		trace("YOU WON!");
	}
	
	public function onFellDown():Void
	{
		stageMode = StageMode.OVER;
		result = Result.DIED;
		player.visible = false;
		for (a in actors)
		{
			a.pause(true);		
		}
		trace("YOU WON!");
	}
}