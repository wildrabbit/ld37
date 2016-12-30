package org.wildrabbit.world;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.tile.FlxTilemapExt;
import flixel.math.FlxPoint;
import haxe.ds.Vector;
import haxe.io.Path;
import org.wildrabbit.roach.PlayState;

import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledMap.FlxTiledMapAsset;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import org.wildrabbit.world.PlayerData;

 typedef TileData =
 {
	 var type: TileType;
	 var edgeMask: Int;
 }
 
enum TileType
{
	EMPTY;
	GROUND;
	WALL;
	GAP;
}


/**
 * ...
 * @author ith1ldin
 */
class MapData extends TiledMap
{
	private static var DATA_PATH:String = "assets/data/";
	private static var IMG_PATH:String = "assets/images/";
	
	private static var EDGE_DIRS:Array<String> = ["left", "right", "up", "down"];
	
	public var numTiles:Int;
	public var tiles: Vector<TileData>;
	private var edgeLayers:Map<String,TiledTileLayer>;
	
	public static inline var MASK_LEFT:Int = 0x1;
	public static inline var MASK_RIGHT:Int = 0x10;
	public static inline var MASK_UP:Int = 0x100;
	public static inline var MASK_DOWN:Int = 0x1000;
	
	public var goalStart: FlxPoint;
	public var playerData: PlayerData;
	
	public function new(data:FlxTiledMapAsset) 
	{
		super(data, DATA_PATH);
		numTiles = width * height;
		tiles = new Vector<TileData>(numTiles);
		for (i in 0...numTiles)
		{
			tiles[i] = { type: TileType.EMPTY, edgeMask:0 };
		}
		edgeLayers = new Map<String,TiledTileLayer>();
	}	
	
	public function build(state:PlayState):Void
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;
			var array:Array<Int> = tileLayer.tileArray;				

			if (tileLayer.properties.contains("edge"))
			{
				edgeLayers.set(tileLayer.properties.get("edge"), tileLayer);
			}
		}
		
		for (layer in layers)
		{
			if (layer.type == TiledLayerType.OBJECT)
			{
				loadEntities(state, cast layer);
			}
			
			if (layer.type != TiledLayerType.TILE) continue;
			var tileLayer:TiledTileLayer = cast layer;

			var tileSheetName:String = tileLayer.properties.get("tileset");
			if (tileSheetName == null)
			{
				throw "Undefined tileset";
			}
			
			var tileset:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileset = ts;
					break;
				}
			}
			
			if (tileset == null)
			{
				throw "Tileset not found :/";
			}
			
			// LOAD LOGIC
			var cellIndex:Int = 0;
			for (tile in tileLayer.tiles)
			{
				if (tile != null)
				{
					var tilesetID:Int = tile.tilesetID;
					if (tileset.hasGid(tilesetID))
					{
						var props:TiledPropertySet = tileset.getPropertiesByGid(tilesetID);
						if (props.contains("edgeType"))
						{
							var value:String = props.get("edgeType");
							addEdge(value, cellIndex); 
						}
						else if (props.contains("tileType"))
						{
							var value:String = props.get("tileType");
							addTile(value, cellIndex);
						}
					}
				}
				cellIndex++;
			}
			
			// LOAD VIEW
			
			var imgPath:Path = new Path(DATA_PATH + tileset.imageSource);
			var fullPath : String = IMG_PATH + imgPath.file + "." + imgPath.ext;
			
			//state.room.build(this);
			
			var map:FlxTilemapExt = new FlxTilemapExt();
#if (cpp || android)
			map.useScaleHack = true;
#end
			map.loadMapFromArray(tileLayer.tileArray, width, height, fullPath, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);
			
			if (tileLayer.properties.contains("type") && tileLayer.properties.get("type") == "base")
			{
				state.addBackgroundLayer(map);
			}
			else
			{
				state.addEdgeLayer(map);
			}
			
		}
	}
	
	public function loadEntities(state:PlayState, layer: TiledObjectLayer): Void 
	{
		for (object in layer.objects)
		{
			if (object.properties.contains("type"))
			{
				var xWorld: Int = object.x;
				var yWorld: Int = object.y;
				var t:String = object.properties.get("type");
				if (t == "goal")
				{
					goalStart = getTilePositionFromWorld(xWorld, yWorld);
					state.buildGoal(goalStart);
				}
				else if (t == "player")
				{
					playerData = new PlayerData();
					playerData.start = getTilePositionFromWorld(xWorld, yWorld);
					var facing:String = "left";
					if (object.properties.contains("facing"))
					{
						facing = object.properties.get("facing");
						switch(facing)
						{
							case "left": playerData.facing = FlxObject.LEFT;
							case "right": playerData.facing = FlxObject.RIGHT;
							case "up": playerData.facing = FlxObject.UP;
							case "down": playerData.facing = FlxObject.DOWN;
						}
					}
					if (object.properties.contains("speed"))
					{
						playerData.speed = Std.parseFloat(object.properties.get("speed"));
						if (Math.isNaN(playerData.speed))
						{
							playerData.speed = 0;
						}
					}
					state.buildPlayer(playerData);
				}
			}
		}
	}
	
	public function recordEdge(curMask:Int, idx:Int, ?symLayerName="", ?symMask:Int = 0, ?symIdx:Int = -1):Void
	{
		tiles[idx].edgeMask = tiles[idx].edgeMask | curMask;
		if (symIdx >= 0)
		{
			if (tiles[symIdx].type != TileType.EMPTY && tiles[symIdx].type != TileType.WALL)
			{
				if (edgeLayers.exists(symLayerName) && edgeLayers.get(symLayerName).tiles[symIdx] != null)
				{
					trace("Need to add " + symLayerName + ", ID: " + edgeLayers.get(symLayerName).tiles[symIdx].tileID + ", setID: " + edgeLayers.get(symLayerName).tiles[symIdx].tilesetID);
				}
				tiles[symIdx].edgeMask = tiles[symIdx].edgeMask | symMask;						
			}
		}
	}
	
	public function addEdge (value:String, idx:Int):Void
	{
		if (idx < 0 || idx >= tiles.length) return;
		
		var x:Int = idx % width;
		var y:Int = Math.floor(idx / width);
		
		var mask:Int = 0;
		switch(value)
		{
			case "left": 
			{ 
				if (x > 0)
				{
					recordEdge(MASK_LEFT, idx, "right", MASK_RIGHT, idx - 1);
				}
				else
				{
					recordEdge(MASK_LEFT, idx);
				}				
			}
			case "right":
			{ 
				if (x < width - 1)
				{
					recordEdge(MASK_RIGHT, idx, "left", MASK_LEFT, idx + 1);
				}
				else
				{
					recordEdge(MASK_RIGHT, idx);
				}			
			}
			case "up":
			{
				if (y > 0)
				{
					recordEdge(MASK_UP, idx, "down", MASK_DOWN, idx - width);
				}
				else
				{
					recordEdge(MASK_UP, idx);
				}	
			}
			case "down":
			{
				if (y < height - 1)
				{
					recordEdge(MASK_DOWN, idx, "up", MASK_UP, idx + width);
				}
				else
				{
					recordEdge(MASK_DOWN, idx);
				}
			}			
		}		
	}
	
	public function addTile (value:String, idx:Int):Void
	{
		if (idx < 0 || idx >= tiles.length) return;
		var type:TileType = EMPTY;
		switch(value)
		{
			case "void": { type = TileType.EMPTY;  }
			case "ground": { type = TileType.GROUND; }
			case "gap":{ type = TileType.GAP; }
			case "fullBlock": {
				type = TileType.WALL; 
				tiles[idx].edgeMask = MASK_DOWN | MASK_LEFT | MASK_RIGHT | MASK_UP;
			}
		}
		tiles[idx].type = type;
	}
	
	public function getWorldPositionFromTileCoords(coords:FlxPoint):FlxPoint
	{
		return FlxPoint.get(coords.x * tileWidth , coords.y * tileHeight );
	}
	public function getWorldPositionFromTileIdx(idx:Int):FlxPoint
	{
		var x:Int = idx % width;
		var y:Int = Math.floor(idx / width);
		return getWorldPositionFromTileCoords(FlxPoint.weak(x, y));
	}
	
	public function getTilePositionFromWorld(x: Int, y:Int):FlxPoint
	{
		return FlxPoint.get(Math.floor(x / tileWidth), Math.floor(y / tileHeight));
	}
	
	public function validCoords(coords:FlxPoint):Bool
	{
		return coords.x >= 0 && coords.x < width && coords.y >= 0 && coords.y < height;
	}
	
	public function getTileAt(coords:FlxPoint):TileData
	{
		return tiles[asIndex(coords)];
	}
	public function hitsEdgeAt(oldCoords:FlxPoint, coords:FlxPoint):Bool
	{
		var deltaX:Int = Std.int(coords.x - oldCoords.x);
		var deltaY:Int = Std.int(coords.y - oldCoords.y);
		var oldTile:TileData = tiles[asIndex(oldCoords)];
		var newTile:TileData = tiles[asIndex(coords)];
		return deltaX < 0 && ((oldTile.edgeMask & MASK_LEFT) != 0 || (newTile.edgeMask & MASK_RIGHT)!= 0)
			|| deltaX > 0 && ((oldTile.edgeMask & MASK_RIGHT)!= 0 || (newTile.edgeMask & MASK_LEFT)!= 0)
			|| deltaY < 0 && ((oldTile.edgeMask & MASK_UP)!= 0 || (newTile.edgeMask & MASK_DOWN)!= 0)
			|| deltaY > 0 && ((oldTile.edgeMask & MASK_DOWN)!= 0 || (newTile.edgeMask & MASK_UP)!= 0);
	}
	
	public function asIndex(coords:FlxPoint):Int
	{
		return Std.int(coords.x + coords.y * width);
	}
}