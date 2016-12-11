package org.wildrabbit.roach;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.effects.FlxTrail;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
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
	private static inline var AWAKE_DELAY:Float = 0.3;
	public var levelData:LevelData;
	
	private var layerVec: Array<FlxTilemapExt>;
	
	// HACK to control the entities depths
	private var bgLayers = new FlxTypedGroup<FlxTilemapExt>();
	private var mapLayers:FlxTypedGroup<FlxTilemapExt>;
	public var placedItems: FlxTypedGroup<PlaceableItem>;
	private var playerLayer: FlxTypedGroup<Player>;
	private var goalLayer: FlxTypedGroup<Goal>;
	
	private var bgLayer:FlxTilemapExt;
	
	private var hud:HUD;
	
	private var title:FlxText;
	
	private var stageMode:StageMode;
	private var timeToAwake:Float;
	private var result:Result;
	
	private var selectedToolIdx:Int;
	private var selectedPlaceable:PlaceableItem;
	
	private var back:FlxButton;
	private var next:FlxButton;
	private var toggleSpeed:FlxButton;
	
	private var stageTxt:FlxText;
	private var toolTxt:FlxText;
	private var lvTxt:FlxText;
	
	private var select:FlxSprite;

	public var player:Player;
	public var goal:Goal;
	
	public var actors: Array<Actor>;
	
	public var currentTools:Array<PlaceableItemTool>;
	public var toolLibrary: Map<Int,PlaceableItemData>;
	
	private var goalSound:FlxSound;
	private var toolClick:FlxSound;
	private var playClick:FlxSound;
	private var placeClick:FlxSound;
	private var wrongPlaceClick:FlxSound;
	
	private var playerTrail:FlxTrail;
	private var playerTrailLayer:FlxTypedGroup<FlxTrail>;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		currentTools = new Array<PlaceableItemTool>();
		
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
		
		
		goalLayer = new FlxTypedGroup<Goal>();
		add(goalLayer);
		
		playerTrailLayer = new FlxTypedGroup<FlxTrail>();
		add(playerTrailLayer);

		playerLayer = new FlxTypedGroup<Player>();
		add(playerLayer);
		selectedToolIdx = -1;

		mapLayers = new FlxTypedGroup<FlxTilemapExt>();
		add(mapLayers);

		
		levelData = new LevelData(Reg.levels[Reg.level]);
		levelData.build(this);
		
		resetToolLoadout();
		
		//thisLevelTools = [
			//{id:0, amount:1 },
			//{id:1, amount:2 },
		//];
		//currentTools = [
			//{id:0, amount:1 },
			//{id:1, amount:2 },
		//];
		
		select = new FlxSprite(0, 0, AssetPaths.select__png);
		
		hud = new HUD(this);
		hud.buildToolButtons(currentTools, toolLibrary);
		hud.onStageModeChanged(stageMode);
		add(hud);
		
		title = new FlxText(850, 44, 0, "TOOLS", 24);
		title.color.setRGB(130, 0, 37);
		add(title);
		
		back = new FlxButton(5, 5, "prev", function():Void
		{
			Reg.level = (Reg.levels.length + Reg.level - 1) % Reg.levels.length;
			FlxG.switchState(new PlayState());
		});
		
		add(back);
		
		next = new FlxButton(80, 5, "next", function():Void 
		{
			Reg.level = (Reg.level + 1) % Reg.levels.length;
			FlxG.switchState(new PlayState());
		} );
		add(next);
		
		stageTxt = new FlxText(5, 30, 0, "stage: " + stageMode, 14);
		stageTxt.color = FlxColor.WHITE;
		add(stageTxt);
		
		var toolIdx:Int = selectedToolIdx == -1 ? -1 : toolLibrary.get(currentTools[selectedToolIdx].id).templateID;
		toolTxt = new FlxText(5, 50, 0, "tool: " + ((selectedToolIdx == -1) ? "none" : Std.string(toolIdx)), 14);
		stageTxt.color = FlxColor.WHITE;
		add(toolTxt);
		
		lvTxt = new FlxText(5, 70, 0, "Level  " + Reg.level + " - " + Reg.levels[Reg.level], 14);
		lvTxt.color = FlxColor.WHITE;
		add(lvTxt);
		
		goalSound = new FlxSound();
		goalSound.loadEmbedded(AssetPaths.goal__wav);
		goalSound.stop();
		
	}
	
	public function buildPlayer(playerData: PlayerData):Void
	 {					
		player = new Player();
		player.init(this, playerData);
		playerLayer.add(player);
		playerTrail = new FlxTrail(player);

		
		actors.push(player);
	 }
	 
	 public function buildGoal(startCoords: FlxPoint):Void
	 {
		goal = new Goal();
		var pos:FlxPoint = levelData.getWorldPositionFromTileCoords(startCoords);
		goal.setPosition(pos.x, pos.y);
		goalLayer.add(goal);
		
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
		actors = null;
		layerVec = null;
		player = null;
		goal = null;
		placedItems = null;
		mapLayers = null;
		bgLayer = null;
		bgLayers = null;
		hud = null;
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
								if (currentTools[i].id == templateID && currentTools[i].amount < Reg.levelToolLoadouts[Reg.level][i].amount)
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
				playerTrail.resetTrail();
				playerTrailLayer.add(playerTrail);
				for (a in actors)
				{
					a.startPlaying();
				}
			}
		}
		
		stageTxt.text = "stage: " + stageMode;
		var toolIdx:Int = selectedToolIdx == -1 ? -1 : toolLibrary.get(currentTools[selectedToolIdx].id).templateID;
		toolTxt.text = "tool: " + (selectedToolIdx == -1 ? "none" : Std.string(toolIdx));
		
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
				remove(select);
			}
			else 
			{
				selectedToolIdx = i;
				trace("current tool: " + toolLibrary.get(currentTools[selectedToolIdx].id).templateID);			
				add(select);
				var pos:FlxPoint = hud.tools[i].getMidpoint();
				pos.subtract(select.width / 2, select.height / 2);
				select.setPosition(pos.x, pos.y);
				FlxTween.tween(select.scale, { x:1.1, y:1.1}, 0.5, { type:FlxTween.PINGPONG } );
				pos.put();
			}
			
			
		}
		else 
		{
			for (child in this)
			{
				if (child == select)
				{
					remove(select);
				}
			}
		}
	}
	
	public function playPressed():Void
	{
		switch(stageMode)
		{
			case StageMode.EDIT:
			{
				setStageMode(StageMode.PLAY);
			}
			case StageMode.PAUSE: 
			{ 
				setStageMode(StageMode.PLAY);
			}
			case StageMode.PLAY: 
			{ 
				setStageMode(StageMode.PAUSE);
			}	
			case StageMode.OVER: 
			{ 
				setStageMode(StageMode.EDIT);
			}	
		}
	}
	private function resetToolLoadout():Void
	{		
		currentTools.splice(0, currentTools.length);
		var levelLoadout:Array<PlaceableItemTool> = Reg.levelToolLoadouts[Reg.level];
		for (i in 0...levelLoadout.length)
		{					
			currentTools.push( { id: levelLoadout[i].id, amount:levelLoadout[i].amount } );
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
		resetToolLoadout();
		for (i in 0...currentTools.length)
		{
			hud.updateTool(i, currentTools[i].amount);
		}
	}
	public function resetPressed(): Void 
	{
		if (stageMode == StageMode.EDIT)
		{
			resetTools();
		}
		setStageMode(StageMode.EDIT);
		// TODO: On Over we should probably do something different
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
		result = Result.WON;
		setStageMode(StageMode.OVER);
		
		if (!goalSound.playing)
		{
			goalSound.play();
		}
		trace("YOU WON!");
	}
	
	public function onFellDown():Void
	{
		result = Result.DIED;
		player.visible = false;
		
		setStageMode(StageMode.OVER);
	}
	
	public function setStageMode(newMode:StageMode)
	{
		switch(newMode)
		{
			case StageMode.EDIT:
			{
				playerTrailLayer.remove(playerTrail);
				// Clear everything
				for (a in actors)
				{
					a.resetToDefaults();
				}
			}
			case StageMode.PLAY:
			{
				if (stageMode == EDIT)
				{
					timeToAwake = AWAKE_DELAY;
					selectedToolIdx = -1;
					selectedPlaceable = null;					
				}
				else if (stageMode == PAUSE)
				{
					for (a in actors)
					{
						a.pause(false);

					}
				playerTrail.resetTrail();
				playerTrailLayer.add(playerTrail);
				}
			}
			case StageMode.PAUSE:
			{
				for (a in actors)
				{
					a.pause(true);
				}
				playerTrailLayer.remove(playerTrail);
			}
			case StageMode.OVER:
			{
				playerTrailLayer.remove(playerTrail);
				for (a in actors)
				{
					a.pause(true);		
				}
					
				if (result == Result.WON)
				{
					var youWon:FlxText = new FlxText((bgLayer.x + bgLayer.width) / 2, (bgLayer.y + bgLayer.height) / 2, 0, "WELL DONE!", 72);
					youWon.alignment = FlxTextAlign.CENTER;
					youWon.x -= youWon.width / 2;
					youWon.y -= youWon.height /2;
					add(youWon);
					youWon.scale.set(0.25, 0.25);
					var t:FlxTween = FlxTween.tween(youWon.scale, { "x": 1.25, "y":1.25 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut, onComplete:onNextLevel } );
				}
			}
		}
		stageMode = newMode;
		hud.onStageModeChanged(stageMode);
	}
	
	public function onNextLevel(t:FlxTween):Void
	{
		if (Reg.level >= Reg.levels.length - 1)
		{
			// NO MOAR. Restart or back to menu
			Reg.level = 0;
		}
		else 
		{
			Reg.level++;
		}
		FlxTween.num(0, 100, 1, { onComplete: function(t:FlxTween):Void { FlxG.switchState(new PlayState()); }} );
	}
	
	public function loadLevel(levelID:String):Void
	{
		
	}
	
}