package org.wildrabbit.world;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.world.LevelData.TileData;
import org.wildrabbit.world.LevelData.TileType;

using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ith1ldin
 */
class Player extends Actor
{
	public static inline var PLAYER_WIDTH:Int = 64;
	public static inline var PLAYER_HEIGHT:Int = 64;
	
	public static inline var PLAYER_HITBOX_WIDTH:Int = 48;
	public static inline var PLAYER_HITBOX_HEIGHT:Int = 48;
	
	private static inline var MIDPOINT_DISTANCE_THRESHOLD:Int = 5;
	
	private var initData: PlayerData;
	private var parent: PlayState;
	
	private var speed:Float;
	
			var wallSound:FlxSound;
	private var interactedLastFrame:Bool;
	// stuff
	
	
	public function new() 
	{
		super(0, 0);
		loadGraphic(AssetPaths.entities_00__png, true, PLAYER_WIDTH, PLAYER_HEIGHT,false);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.UP, false, false);
		setFacingFlip(FlxObject.DOWN, false, true);
		animation.add("horizontal", [1], 1, false);
		animation.add("vertical", [0], 1, false);
		animation.play("horizontal");
	}
	
	public override function update(dt:Float):Void 
	{
		var interact:Bool = false;
		var hitboxDeltaX:Int = PLAYER_WIDTH - PLAYER_HITBOX_WIDTH;
		var hitboxDeltaY:Int = PLAYER_HEIGHT - PLAYER_HITBOX_HEIGHT;
		
		var ox1:Int = Math.round(relX + hitboxDeltaX/2 );
		var oy1:Int = Math.round(relY + hitboxDeltaY/2);
		var ox2:Int = Math.floor(relX + hitboxDeltaX/2 + PLAYER_HITBOX_WIDTH);
		var oy2:Int = Math.floor(relY + hitboxDeltaY/2 + PLAYER_HITBOX_HEIGHT);
		
		var oldTL:FlxPoint = parent.levelData.getTilePositionFromWorld(ox1, oy1);
		var oldTR:FlxPoint = parent.levelData.getTilePositionFromWorld(ox2, oy1);
		var oldBL:FlxPoint = parent.levelData.getTilePositionFromWorld(ox1, oy2);
		var oldBR:FlxPoint = parent.levelData.getTilePositionFromWorld(ox2, oy2);

		var oldPos:FlxPoint = getRelativePos();
		var coordsTL:FlxPoint = null;
		var coordsBR:FlxPoint = null;
		var coordsTR:FlxPoint = null;
		var coordsBL:FlxPoint = null;
		
		wallSound = new FlxSound();
		wallSound.loadEmbedded(AssetPaths.wall__wav);
		wallSound.stop();		
		
		super.update(dt);
		relX = x - offsetX;
		relY = y - offsetY;

		var x1:Int = Math.round(relX + hitboxDeltaX/2 );
		var y1:Int = Math.round(relY + hitboxDeltaY/2);
		var x2:Int = Math.floor(relX + hitboxDeltaX/2 + PLAYER_HITBOX_WIDTH);
		var y2:Int = Math.floor(relY + hitboxDeltaY/2 + PLAYER_HITBOX_HEIGHT);
		
		if (parent == null) return;
		
		var v:FlxVector = new FlxVector();
		v.set(velocity.x, velocity.y);
		if (parent.isPlaying())
		{
			coordsTL = parent.levelData.getTilePositionFromWorld(x1,y1);
			coordsTR = parent.levelData.getTilePositionFromWorld(x2,y1);
			coordsBR = parent.levelData.getTilePositionFromWorld(x2,y2);
			coordsBL = parent.levelData.getTilePositionFromWorld(x1,y2);
			
			if (!parent.levelData.validCoords(coordsTL) || !parent.levelData.validCoords(coordsTR)  || !parent.levelData.validCoords(coordsBL) || !parent.levelData.validCoords(coordsBR) )
			{
				setRelativePos(oldPos.x, oldPos.y);
				velocity.set();
			}
			else 
			{
				var goalCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(parent.goal.relX), Math.round(parent.goal.relY));
				var midPos:FlxPoint = getMidpoint();
				midPos.subtract(offsetX, offsetY);
				var midPointCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(midPos.x), Math.round(midPos.y));
				var midCoords:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(midPointCoords);
				if (goalCoords.equals(midPointCoords) &&  midPos.distanceTo(parent.goal.getMidpoint().subtract(parent.goal.offsetX, parent.goal.offsetY)) < MIDPOINT_DISTANCE_THRESHOLD)
				{
					trace("yeah!");
					parent.onReachedGoal();
				}
				else 
				{
					if (checkInteraction() && !interactedLastFrame)
					{						
						setRelativePos(midCoords.x, midCoords.y);
						interact = true;
					}
					else
					{
						var tData:TileData = parent.levelData.getTileAt(midPointCoords);
						var midTilePos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(midPointCoords);
						//midTilePos.subtract(offsetX, offsetY);
						midTilePos.add(parent.levelData.tileWidth / 2, parent.levelData.tileHeight / 2);						
						var type:TileType = tData == null? TileType.EMPTY : tData.type;
						if (type == TileType.GAP && midPos.distanceTo(midTilePos) < MIDPOINT_DISTANCE_THRESHOLD)
						{
							parent.onFellDown();
							goalCoords.put();
							midPointCoords.put();
							oldPos.put();
							if (coordsTL != null) coordsTL.put();
							if (coordsTR != null) coordsTR.put();
							if (coordsBL != null) coordsBL.put();
							if (coordsBR != null) coordsBR.put();
							oldTL.put();
							oldTR.put();
							oldBL.put();
							oldBR.put();
							interactedLastFrame = false;
							return;
						}
						
						tData = parent.levelData.getTileAt(coordsTL);
						type = tData == null? TileType.EMPTY : tData.type;
						
						var wallHitTL = type == TileType.EMPTY || type == TileType.WALL || parent.levelData.hitsEdgeAt(oldTL, coordsTL);
						tData = parent.levelData.getTileAt(coordsTR);
						type = tData == null? TileType.EMPTY : tData.type;
						var wallHitTR = type == TileType.EMPTY || type == TileType.WALL || parent.levelData.hitsEdgeAt(oldTR, coordsTR);
						tData = parent.levelData.getTileAt(coordsBL);
						type = tData == null? TileType.EMPTY : tData.type;
						var wallHitBL = type == TileType.EMPTY || type == TileType.WALL  || parent.levelData.hitsEdgeAt(oldBL, coordsBL);
						tData = parent.levelData.getTileAt(coordsBR);
						type = tData == null? TileType.EMPTY : tData.type;
						var wallHitBR = type == TileType.EMPTY || type == TileType.WALL || parent.levelData.hitsEdgeAt(oldBR, coordsBR);
						if (wallHitTL || wallHitTR || wallHitBL || wallHitBR)
						{
							setRelativePos(midCoords.x, midCoords.y);						
							changeFacing(calculateNextFacing());
							if (!wallSound.playing) { wallSound.play(); }
							//FlxG.camera.shake(0.0004, 0.1);
						}	
					}
				}
								
				goalCoords.put();
				midPointCoords.put();
			}
		}
		interactedLastFrame = interact;
		oldPos.put();
		if (coordsTL != null) coordsTL.put();
		if (coordsTR != null) coordsTR.put();
		if (coordsBL != null) coordsBL.put();
		if (coordsBR != null) coordsBR.put();
		oldTL.put();
		oldTR.put();
		oldBL.put();
		oldBR.put();
	}
	
	public function checkInteraction():Bool
	{
		var midPos:FlxPoint = getMidpoint();
		midPos.subtract(offsetX, offsetY);
		var midPointCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(midPos.x), Math.round(midPos.y));
				
		var item:PlaceableItem = parent.getItemAtPos(midPointCoords);
		if (item != null)
		{
			var itemMid:FlxPoint = item.getMidpoint();
			itemMid.subtract(item.offsetX, item.offsetY);
			if (midPos.distanceTo(itemMid) < MIDPOINT_DISTANCE_THRESHOLD)
			{					
				item.onEntityInteracted(this);
				return true;				
			}
			midPos.put();
			midPointCoords.put();
			itemMid.put();
		}
		midPos.put();
		midPointCoords.put();
		return false;

	}

	
	public override function pause(value:Bool):Void
	{
		if (value)
		{
			velocity.set();
			//acceleration.set();
		}
		else 
		{
			adjustVelocity();
		}
	}
	
	public function init(parent:PlayState, data:PlayerData):Void
	{
		this.parent = parent;
		initData = data;
		
		speed = initData.speed;
		changeFacing(initData.facing);
		var pos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(initData.start);
		setRelativePos(pos.x, pos.y);
		
		velocity.set();
	}
	
	public override function resetToDefaults():Void
	{
		visible = true;
		speed = initData.speed;
		changeFacing(initData.facing);
		var pos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(initData.start);
		setRelativePos(pos.x, pos.y);
		velocity.set();
	}
	
	public override function startPlaying():Void
	{
		interactedLastFrame = checkInteraction();
		adjustVelocity();		
	}

	
	public function changeFacing(newFacing:Int):Void
	{
		var faceAngle:Float = 0;
		facing = newFacing;
		adjustVelocity();
	}
	
	private function adjustVelocity():Void
	{
		var faceAngle:Float = 0;
		var animationName:String = "horizontal";
		switch(facing)
		{
			case FlxObject.LEFT:
			{
				faceAngle = 180;			
			}
			case FlxObject.RIGHT:
			{
				faceAngle = 0;
			}
			case FlxObject.UP:
			{
				faceAngle = 270;
				animationName = "vertical";
			}
			case FlxObject.DOWN:
			{
				faceAngle = 90;
				animationName = "vertical";
			}
		}

		velocity.set(speed, 0);
		velocity.rotate(FlxPoint.weak(0, 0), faceAngle);
		animation.play(animationName);
	}
	public function calculateNextFacing():Int
	{
		switch(facing)
		{
			case FlxObject.LEFT:
			{
				return FlxObject.UP;			
			}
			case FlxObject.RIGHT:
			{
				return FlxObject.DOWN;			
			}
			case FlxObject.UP:
			{
				return FlxObject.RIGHT;			
			}
			case FlxObject.DOWN:
			{
				return FlxObject.LEFT;			
			}
		}
		return 0;
	}
}