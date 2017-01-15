package org.wildrabbit.roach.states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.effects.FlxTrail;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.transition.FlxTransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.Transition;
import flixel.addons.transition.TransitionData;
import flixel.group.FlxGroup;
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
import flixel.util.FlxStringUtil;
import haxe.ds.Vector;
import openfl.Assets;
import org.wildrabbit.data.ObjectiveData;
import org.wildrabbit.data.WorldData.LevelData;
import org.wildrabbit.roach.states.EndState;
import org.wildrabbit.roach.states.MenuState;
import org.wildrabbit.ui.DefeatPopup;
import org.wildrabbit.ui.HUD;
import org.wildrabbit.ui.PauseLayer;
import org.wildrabbit.ui.VictoryPopup;
import org.wildrabbit.world.Actor;
import org.wildrabbit.world.GameContainer;
import org.wildrabbit.world.GameStats;
import org.wildrabbit.world.GameWorldState.LevelState;
import org.wildrabbit.world.GameWorldState.ObjectiveState;
import org.wildrabbit.world.GameWorldState.WorldStateEntry;
import org.wildrabbit.world.Goal;
import org.wildrabbit.world.MapData;
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
	public static inline var X_OFFSET:Int = 64;
	public static inline var Y_OFFSET:Int = 64;
	
	private static inline var AWAKE_DELAY:Float = 0.3;
	public var levelData:MapData;
	
	public var gameContainer:GameContainer;
	
	private var baseBackgroundLayer:FlxTilemapExt;
	
	private var hud:HUD;
	private var pauseLayer:PauseLayer;
	
	private var stageMode:StageMode;
	private var timeToAwake:Float;
	public var result (default,null):Result;
	
	private var selectedToolIdx:Int;
	private var selectedPlaceable:PlaceableItem;
	
#if debug
	private var back:FlxButton;
	private var next:FlxButton;
	private var toggleSpeed:FlxButton;
	
	private var stageTxt:FlxText;
	private var toolTxt:FlxText;
	private var lvTxt:FlxText;
#end	
	
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
	
	public var fastForward(default,null):Bool = false;
	
	private var playerTrail:FlxTrail;
	
	/**
	 * Function that is called up when to state is created to set it up.
	 */
	override public function create():Void
	{
		super.create();
		
		currentTools = new Array<PlaceableItemTool>();
		
		buildItemLibrary();
		
		gameContainer = new GameContainer(X_OFFSET, Y_OFFSET);
		add(gameContainer);
		
		actors = new Array<Actor>();
		
		stageMode = StageMode.EDIT;
		timeToAwake = -1;
		
		player = null;
		goal = null;
		
		baseBackgroundLayer = null;
		
		selectedToolIdx = -1;

		levelData = new MapData("assets/data/"+Reg.currentLevel.file);
		levelData.build(this);
		
		if (!Reg.gameWorld.worldTable.exists(Reg.gameWorld.currentWorldIdx))
		{
			Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx] = new WorldStateEntry();
			Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable = new Map<Int,LevelState>();
		}
		
		if (!Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable.exists(Reg.gameWorld.currentLevelIdx))
		{
			var data:LevelData = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx].levels[Reg.gameWorld.currentLevelIdx];
			var levelState = new LevelState();
			for (objData in data.objectives)
			{
				var objState:ObjectiveState = new ObjectiveState();
				objState.completed = false;
				objState.bestValue = 0;
				objState.bestFloat = 0.0;
				objState.bestSequence.splice(0,objState.bestSequence.length - 1);
				levelState.objectives.push(objState);
			}
			Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx] = levelState;
		}
		
		resetToolLoadout();
		
		
		hud = new HUD(this);
		hud.editPanel.buildTools(currentTools, toolLibrary);
		hud.onStageModeChanged(stageMode);
		add(hud);
		
		pauseLayer = new PauseLayer();	
		
#if debug		
		createDebugItems();
#end		
		goalSound = new FlxSound();
		goalSound.loadEmbedded(AssetPaths.goal__wav);
		goalSound.stop();
		
		fastForward = false;
	}
	
	public function buildPlayer(playerData: PlayerData):Void
	 {					
		player = new Player();
		player.init(this, playerData);
		gameContainer.addToPlayerLayer(player);
		playerTrail = new FlxTrail(player);

		actors.push(player);
	 }
	 
	 public function buildGoal(startCoords: FlxPoint):Void
	 {
		goal = new Goal();
		var pos:FlxPoint = levelData.getWorldPositionFromTileCoords(startCoords);
		goal.setRelativePos(pos.x, pos.y);
		gameContainer.addToActorLayer(goal);
		
		actors.push(goal);
	 }
	
	public function addEdgeLayer(layer:FlxTilemapExt):Void
	{
		gameContainer.addToMapLayer(0, 0, layer, GameContainer.EDGES_IDX);
	}
	
	public function addBackgroundLayer(layer:FlxTilemapExt):Void
	{
		if (baseBackgroundLayer != null)
		{
			gameContainer.removeMapLayer(baseBackgroundLayer, GameContainer.BACKGROUND_IDX);
		}
		baseBackgroundLayer = layer;
		gameContainer.addToMapLayer(0,0,baseBackgroundLayer, GameContainer.BACKGROUND_IDX);
	}

	/**
	 * Function that is called when this state is destroyed - you might want to
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		actors.splice(0, actors.length);
		actors = null;
		
		player = null;
		goal = null;
		baseBackgroundLayer = null;
		hud = null;
	}
	
	public function getItemAtPos(coords:FlxPoint): PlaceableItem
	{
		var pos:FlxPoint = FlxPoint.get();
		var newPos:FlxPoint = FlxPoint.get();
		var ret:PlaceableItem = null;
		for (item in gameContainer.placedItemsLayer)
		{
			item.getRelativePos(pos);
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
		var playerMidPos:FlxPoint = player.getRelativeMidPos();
		var playerCoords:FlxPoint = levelData.getTilePositionFromWorld(Math.round(playerMidPos.x), Math.round(playerMidPos.y));
		playerMidPos.put();
		
		super.update(dt);
		
		var pos:FlxPoint = FlxG.mouse.getWorldPosition();			
		var fits:Bool = pos.x >= baseBackgroundLayer.x && pos.x < baseBackgroundLayer.x + baseBackgroundLayer.width && pos.y >= baseBackgroundLayer.y && pos.y < baseBackgroundLayer.y + baseBackgroundLayer.height;
		var mouseReleased:Bool = FlxG.mouse.justReleased;
		if (stageMode == StageMode.EDIT)
		{
			if (fits && mouseReleased)
			{
				var coords:FlxPoint = null;
				pos.subtract(baseBackgroundLayer.x, baseBackgroundLayer.y);
				coords = levelData.getTilePositionFromWorld(Math.round(pos.x), Math.round(pos.y));
				
				var tile:TileData = levelData.getTileAt(coords);
				if (tile.type != TileType.EMPTY)
				{
					var selectedToolData:PlaceableItemData = selectedToolIdx >= 0 ? toolLibrary.get(currentTools[selectedToolIdx].id) : null;
					var entity:PlaceableItem = getItemAtPos(coords);
					if (entity != null)
					{ 
						// WE KNOW there is something here. 
						
						var entityData:PlaceableItemData = entity.itemData;
						
						var canPlaceSelection:Bool = selectedToolIdx >= 0 
							&& currentTools[selectedToolIdx].id != entityData.templateID 
							&& currentTools[selectedToolIdx].amount > 0;
						var willReplace:Bool = canPlaceSelection && tile.type == selectedToolData.allowedTileType;
						var removeScheduled:Bool = true;
						
						if (removeScheduled)
						{
							var templateID:Int = entityData.templateID;
							for (i in 0...currentTools.length)
							{
								if (currentTools[i].id == templateID && currentTools[i].amount < Reg.currentLevel.loadouts[i].amount)
								{
									currentTools[i].amount++;
									hud.editPanel.updateToolPage(i, currentTools[i].amount);
									if (selectedToolIdx < 0)
									{
										selectedToolIdx = i;
										hud.editPanel.selectTool(i);
									}
								}
							}
							gameContainer.removePlaceableItem(entity);
							actors.remove(entity);
							entity.destroy();							
						}
						
						if (willReplace)
						{
							createNewPlaceableItem(selectedToolData, coords);
						}
					}
					else 
					{
						if (selectedToolData != null && currentTools[selectedToolIdx].amount > 0 && tile.type == selectedToolData.allowedTileType)
						{
							createNewPlaceableItem(toolLibrary.get(currentTools[selectedToolIdx].id), coords);
						}
					}
				}
				coords.put();
			}
			pos.put();
		}
		else if (stageMode == StageMode.PLAY && timeToAwake < 0)
		{			
			// Check stats:
			//Reg.stats.tilesPlaced = gameContainer.placedItemsLayer.length;
			Reg.stats.timeSpent += dt; // Beware of the timescale!!
			
			// Check position changes
			playerMidPos = player.getRelativeMidPos();			
			var newPlayerCoords = levelData.getTilePositionFromWorld(Math.round(playerMidPos.x), Math.round(playerMidPos.y));
			var distanceX:Int = Std.int(Math.abs(newPlayerCoords.x - playerCoords.x));
			var distanceY:Int = Std.int(Math.abs(newPlayerCoords.y - playerCoords.y));
			if (distanceX != 0 || distanceY != 0)
			{
				Reg.stats.tilesTraversed += (distanceX + distanceY); // It shouldn't be higher than 1
			}
			playerMidPos.put();
			newPlayerCoords.put();
			
			// Check game limits
			var tileFailed:Bool = Reg.stats.tilesTraversed > Reg.currentLevel.maxTiles;
			var timeFailed:Bool = Reg.stats.timeSpent > Reg.currentLevel.maxTime;
			if (tileFailed || timeFailed)
			{
				if (tileFailed)
				{
					hud.playPanel.playStatFail(StatType.TILES_TRAVERSED);
				}
				if (timeFailed)
				{
					hud.playPanel.playStatFail(StatType.TIME_SPENT);
				}
				result = Result.TIMEDOUT;
				setStageMode(StageMode.OVER);
			}

		}
		playerCoords.put();
		
		if (timeToAwake >= 0)
		{
			timeToAwake -= dt;
			if (timeToAwake <= 0)
			{
				Reg.stats.reset();
				playerTrail.resetTrail();
				gameContainer.addToSpriteLayer(playerTrail, GameContainer.SPRITE_PLAYER_BG_IDX);
				for (a in actors) { a.startPlaying(); };
			}
		}
		
#if debug
		stageTxt.text = "stage: " + stageMode;
		var toolIdx:String = selectedToolIdx == -1 ? "none" : toolLibrary.get(currentTools[selectedToolIdx].id).name;
		toolTxt.text = "Tool: " + toolIdx;
#end
	}
	
	private function createNewPlaceableItem(toolData:PlaceableItemData, coords:FlxPoint):Void
	{
		var item:PlaceableItem = new PlaceableItem();
		item.init(this, toolData);
		var newCoords:FlxPoint = levelData.getWorldPositionFromTileCoords(coords);
		item.setRelativePos(newCoords.x, newCoords.y);
		newCoords.put();
		currentTools[selectedToolIdx].amount--;
		hud.editPanel.updateToolPage(selectedToolIdx, currentTools[selectedToolIdx].amount);
		gameContainer.addToPlaceableLayer(item);
		actors.push(item);
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
				hud.editPanel.deselectTool();
			}
			else 
			{
				selectedToolIdx = i;				
				hud.editPanel.selectTool(selectedToolIdx);								
			}						
		}
		else 
		{
			hud.editPanel.deselectTool();
		}
	}
	
	public function playPressed():Void
	{
		setStageMode(StageMode.PLAY);		
	}
	private function resetToolLoadout():Void
	{		
		currentTools.splice(0, currentTools.length);
		var levelLoadout:Array<PlaceableItemTool> = Reg.currentLevel.loadouts;
		for (i in 0...levelLoadout.length)
		{					
			currentTools.push( { id: levelLoadout[i].id, amount:levelLoadout[i].amount } );
		}
	}
	private function resetTools():Void
	{
		for (item in gameContainer.placedItemsLayer)
		{
			actors.remove(item);
		}
		gameContainer.resetPlaceableItems();
		selectedToolIdx = -1;
		selectedPlaceable = null;
		resetToolLoadout();
		for (i in 0...currentTools.length)
		{
			hud.editPanel.updateToolPage(i, currentTools[i].amount);
		}
	}
	public function resetPressed(): Void 
	{
		if (stageMode == StageMode.EDIT)
		{
			resetTools();
		}
		if (stageMode != StageMode.OVER)
		{
			setStageMode(StageMode.EDIT);
			// TODO: On Over we should probably do something different			
		}
		else 
		{
			FlxG.switchState(new MenuState());
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
		var names:Array<String> = ["Go left", "Go right", "Go up", "Go down"];
		
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
			placeable.name = names[i];
			toolLibrary[i] = placeable;
		}
	}
	
	public function onReachedGoal():Void
	{
		result = Result.WON;
		
		// Evaluate objectives. Notify UI. Etc
		
		setStageMode(StageMode.OVER);
		
		if (!goalSound.playing)
		{
			goalSound.play();
		}
	}
	
	public function onFellDown():Void
	{
		result = Result.DIED;
		player.visible = false;
		
		setStageMode(StageMode.OVER);
	}
	
	public function setStageMode(newMode:StageMode)
	{
		if (stageMode == StageMode.PAUSE && newMode != StageMode.PAUSE)
		{
			pauseLayer.setPaused(false);
			remove(pauseLayer);
		}
		
		switch(newMode)
		{
			case StageMode.EDIT:
			{
				destroySubStates = true;
				var t:Transition = new Transition(new TransitionData(TransitionType.FADE, FlxColor.BLACK, 0.8));
				t.start(TransitionStatus.OUT);
				t.finishCallback = closeSubState;
				openSubState(t);
				
				resetTimescale();
				hud.editPanel.deselectTool();
				gameContainer.removeFromSpriteLayer(playerTrail, GameContainer.SPRITE_PLAYER_BG_IDX);
				// Clear everything
				for (a in actors) { a.resetToDefaults();}
			}
			case StageMode.PLAY:
			{
				selectedToolIdx = -1;
				hud.editPanel.deselectTool();
				if (stageMode != PAUSE)
				{
					for (a in actors) { a.resetToDefaults();}
					resetTimescale(); // We should never need to check this
					timeToAwake = AWAKE_DELAY;
					selectedToolIdx = -1; 
					selectedPlaceable = null;					
				}
				else
				{
					setFastForward(fastForward);
					for (a in actors) { a.pause(false);}
					playerTrail.resetTrail();
					gameContainer.addToSpriteLayer(playerTrail, GameContainer.SPRITE_PLAYER_BG_IDX);					
				}
			}
			case StageMode.PAUSE:
			{
				resetTimescale(true);
				selectedToolIdx = -1;
				hud.editPanel.deselectTool();
				for (a in actors) { a.pause(true); }
				gameContainer.removeFromSpriteLayer(playerTrail, GameContainer.SPRITE_PLAYER_BG_IDX);
				
				pauseLayer.setPaused(true);
				add(pauseLayer);
			}
			case StageMode.OVER:
			{
				resetTimescale();
				selectedToolIdx = -1;
				hud.editPanel.deselectTool();
				gameContainer.removeFromSpriteLayer(playerTrail, GameContainer.SPRITE_PLAYER_BG_IDX);
				for (a in actors) { a.pause(true);}
					
				if (result == Result.WON)
				{
					trace("YAY WON");
					// Evaluate objectives:
					var worldTable: WorldStateEntry = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx];
					var levelState: LevelState = worldTable.levelObjectiveTable[Reg.gameWorld.currentLevelIdx];
					var victoryPopupInfo:Array<Int> = new Array<Int>();
					var objectives:Array<ObjectiveData> = Reg.currentLevel.objectives;
					var idx:Int = 0;
					for (objective in objectives)
					{
						var loadoutData:Array<PlaceableItemTool> = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx].levels[Reg.gameWorld.currentLevelIdx].loadouts;
						var loadoutTotal:Int = 0;
						for (tool in  loadoutData)
						{
							loadoutTotal += tool.amount;
						}
						var objectiveState:ObjectiveState = levelState.objectives[idx];
						var complete:Bool = false;
						var bestInt:Int = objectiveState.bestValue;
						var bestFloat:Float = objectiveState.bestFloat;
						var bestSequence:Array<Int> = objectiveState.bestSequence.copy();
						
						switch(objective.type)
						{
							case ObjectiveType.ALL_TILES_PLACED: 
							{ 
								complete = (Reg.stats.tilesPlaced == loadoutTotal);
								if (complete)
									bestInt = Math.round(Math.max(Reg.stats.tilesPlaced, bestInt));
							}	
							case ObjectiveType.MAX_BUMPS: 
							{ 
								complete = (Reg.stats.bumps <= objective.value); 
								if (complete)
									bestInt = (!objectiveState.completed) ? Reg.stats.bumps : Math.round(Math.min(Reg.stats.bumps, bestInt));							
							}	
							case ObjectiveType.MAX_TILES_PLACED: 
							{
								complete = (Reg.stats.tilesPlaced <= objective.value); 
								if (complete)
									bestInt = (!objectiveState.completed) ? Reg.stats.tilesPlaced : Math.round(Math.min(Reg.stats.tilesPlaced, bestInt));							
							}	
							case ObjectiveType.MAX_TIME: 
							{
								complete = (Reg.stats.timeSpent <= objective.value);
								if (complete)
									bestFloat = (!objectiveState.completed) ? Reg.stats.timeSpent: Math.min(Reg.stats.timeSpent, bestFloat);							
							}
							case ObjectiveType.MAX_TILES_TRAVERSED: 
							{
								complete = (Reg.stats.tilesTraversed <= objective.value); 
								if (complete)
									bestInt = (!objectiveState.completed) ? Reg.stats.tilesTraversed : Math.round(Math.min(Reg.stats.tilesTraversed, bestInt));
							}
							case ObjectiveType.MIN_TILES_TRAVERSED: 
							{
								complete = (Reg.stats.tilesTraversed >= objective.value); 
								if (complete)
									bestInt = (!objectiveState.completed) ? Reg.stats.tilesTraversed : Math.round(Math.max(Reg.stats.tilesTraversed, bestInt));
							}
							case ObjectiveType.REACH_GOAL:
							{
								complete = true;
							}	
							case ObjectiveType.ALL_COLLECTABLES_PICKED: { }
							case ObjectiveType.COMPLETE_SEQUENCE: { }	
							case ObjectiveType.MIN_COLLECTABLES_PICKED: { }	
						}

						if (!objectiveState.completed && complete)
						{
							objectiveState.completed = true;
							var revealed:Bool = idx < 2 || objectiveState.completed || levelState.objectives[idx - 1].completed;
							hud.playPanel.setGoalRevealed(idx, revealed, objectiveState.completed);
							victoryPopupInfo.push(idx);
						}
						objectiveState.bestValue = bestInt;
						objectiveState.bestFloat = bestFloat;
						objectiveState.bestSequence.splice(0, objectiveState.bestSequence.length - 1);
						objectiveState.bestSequence = bestSequence.copy();
						trace("Processed obj " + Std.string(idx));
						idx++;
					}
					
/*					// Show results
					var youWon:FlxText = new FlxText((baseBackgroundLayer.x + baseBackgroundLayer.width) / 2, (baseBackgroundLayer.y + baseBackgroundLayer.height) / 2, 0, "WELL DONE!", 72);
					youWon.alignment = FlxTextAlign.CENTER;
					youWon.x -= youWon.width / 2;
					youWon.y -= youWon.height /2;
					add(youWon);
					youWon.scale.set(0.25, 0.25);
					var t:FlxTween = FlxTween.tween(youWon.scale, { "x": 1.25, "y":1.25 }, 0.35, { type:FlxTween.ONESHOT, ease:FlxEase.backOut, onComplete:onNextLevel } );*/
					
					//Victory popup
					var popup:VictoryPopup = new VictoryPopup();
					add(popup);	
					popup.start(victoryPopupInfo);
				}
				else
				{
					//Defeat popup
					var popup:DefeatPopup= new DefeatPopup();
					add(popup);
					popup.start(result);
				}	
				Reg.gameWorld.save();
			}			
		}
		stageMode = newMode;
		hud.onStageModeChanged(stageMode);
	}
	
	public function onNextLevel(t:FlxTween):Void
	{
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
		FlxTween.num(0, 100, 1, { onComplete: function(t:FlxTween):Void { FlxG.switchState(new PlayState()); }} );
	}
	
	public function loadLevel(levelID:String):Void
	{
		
	}
	
	public function togglePause():Void
	{
		if (stageMode == StageMode.PAUSE)
		{
			setStageMode(StageMode.PLAY);
		}
		else if (stageMode == StageMode.PLAY)
		{
			setStageMode(StageMode.PAUSE);
		}
	}	
	
	public function resetTimescale(?keepValue:Bool = false):Void
	{
		var old:Bool = fastForward;
		setFastForward(false);
		if (keepValue)
		{
			fastForward = old;
		}
	}
	
	public function onFastForward():Void
	{
		setFastForward(!fastForward);
	}
	public function setFastForward(value:Bool):Void
	{
		fastForward = value;			
		if (fastForward)
		{
			FlxG.timeScale = 2;					
		}
		else 
		{
			FlxG.timeScale = 1;
		}
	}
	
	public function resetSave():Void
	{
		Reg.gameWorld.clearSave();
		Reg.gameWorld.currentWorldIdx = 0;
		Reg.gameWorld.currentLevelIdx = 0;
		Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
		Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx] = new WorldStateEntry();
		Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable = new Map<Int,LevelState>();
		var data:LevelData = Reg.worldDatabase[Reg.gameWorld.currentWorldIdx].levels[Reg.gameWorld.currentLevelIdx];
		var levelState = new LevelState();
		var idx:Int = 0;
		for (objData in data.objectives)
		{
			var objState:ObjectiveState = new ObjectiveState();
			objState.completed = false;
			objState.bestValue = 0;
			objState.bestFloat = 0.0;
			objState.bestSequence.splice(0,objState.bestSequence.length - 1);
			levelState.objectives.push(objState);
			hud.playPanel.setGoalRevealed(idx, false, false);
			idx++;
		}
		Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx] = levelState;
		FlxG.switchState(new PlayState());
	}
#if debug
	private function createDebugItems():Void
	{
		// Add buttons to move across maps
		back = new FlxButton(80, 5, "prev", function():Void
		{
			Reg.gameWorld.currentLevelIdx = (Reg.currentWorld.levels.length + Reg.gameWorld.currentLevelIdx - 1) % Reg.currentWorld.levels.length;
			Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
			FlxG.switchState(new PlayState());
		});
		add(back);
		
		next = new FlxButton(170, 5, "next", function():Void 
		{
			Reg.gameWorld.currentLevelIdx = (Reg.gameWorld.currentLevelIdx + 1) % Reg.currentWorld.levels.length;
			Reg.currentLevel = Reg.currentWorld.levels[Reg.gameWorld.currentLevelIdx];
			FlxG.switchState(new PlayState());
		} );
		add(next);
		
		stageTxt = new FlxText(5, 30, 0, "stage: " + stageMode, 14);
		stageTxt.color = FlxColor.WHITE;
		add(stageTxt);
		
		var toolIdx:String = selectedToolIdx == -1 ? "none" : toolLibrary.get(currentTools[selectedToolIdx].id).name;
		toolTxt = new FlxText(5, 5, 0, "Tool: " + toolIdx, 14);
		stageTxt.color = FlxColor.WHITE;
		add(toolTxt);
		
		lvTxt = new FlxText(5, 30, 0, "Level  " + Reg.gameWorld.currentLevelIdx, 14);// + " - " + Reg.levels[Reg.level], 14);
		lvTxt.color = FlxColor.WHITE;
		add(lvTxt);
	}
#end
}