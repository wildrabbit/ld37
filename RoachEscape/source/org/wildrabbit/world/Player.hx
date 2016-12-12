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
class Player extends FlxSprite implements Actor
{
	private var initData: PlayerData;
	private var parent: PlayState;
	
	private var speed:Float;
	
			var wallSound:FlxSound;
	private var interactedLastFrame:Bool;
	// stuff
	
	public override function update(dt:Float):Void 
	{
		var interact:Bool = false;
		var ox1:Int = Math.round(x+2);
		var oy1:Int = Math.round(y+2);
		var ox2:Int = Math.floor(x -2+ parent.levelData.tileWidth);
		var oy2:Int = Math.floor(y -2 + parent.levelData.tileHeight);
		
		var oldTL:FlxPoint = parent.levelData.getTilePositionFromWorld(ox1, oy1);
		var oldTR:FlxPoint = parent.levelData.getTilePositionFromWorld(ox2, oy1);
		var oldBL:FlxPoint = parent.levelData.getTilePositionFromWorld(ox1, oy2);
		var oldBR:FlxPoint = parent.levelData.getTilePositionFromWorld(ox2, oy2);

		var oldPos:FlxPoint = FlxPoint.get(x, y);
		var coordsTL:FlxPoint = null;
		var coordsBR:FlxPoint = null;
		var coordsTR:FlxPoint = null;
		var coordsBL:FlxPoint = null;
		
		wallSound = new FlxSound();
		wallSound.loadEmbedded(AssetPaths.wall__wav);
		wallSound.stop();		
		
		super.update(dt);

		var x1:Int = Math.round(x+2);
		var y1:Int = Math.round(y+2);
		var x2:Int = Math.floor(x -2+ parent.levelData.tileWidth);
		var y2:Int = Math.floor(y -2+ parent.levelData.tileHeight);
		
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
				setPosition(oldPos.x, oldPos.y);
				velocity.set();
			}
			else 
			{
				var goalCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(parent.goal.x), Math.round(parent.goal.y));
				var midPos:FlxPoint = getMidpoint();
				var midPointCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(midPos.x), Math.round(midPos.y));
				var midCoords:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(midPointCoords);
				if (goalCoords.equals(midPointCoords) &&  midPos.distanceTo(parent.goal.getMidpoint()) < 5)
				{
					trace("yeah!");
					parent.onReachedGoal();
				}
				else 
				{
					if (checkInteraction() && !interactedLastFrame)
					{						
						setPosition(midCoords.x, midCoords.y);
						interact = true;
					}
					else
					{
						var tData:TileData = parent.levelData.getTileAt(midPointCoords);
						var midTilePos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(midPointCoords);
						midTilePos.add(parent.levelData.tileWidth / 2, parent.levelData.tileHeight / 2);						
						var type:TileType = tData == null? TileType.EMPTY : tData.type;
						if (type == TileType.GAP && midPos.distanceTo(midTilePos) < 5)
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
							setPosition(midCoords.x, midCoords.y);						
							changeFacing(calculateNextFacing());
							if (!wallSound.playing) { wallSound.play(); }
							FlxG.camera.shake(0.0004, 0.1);
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
		var midPointCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(midPos.x), Math.round(midPos.y));
				
		var item:PlaceableItem = parent.getItemAtPos(midPointCoords);
		if (item != null)
		{
			var itemMid:FlxPoint = item.getMidpoint();
			if (midPos.distanceTo(itemMid) < 5)
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

	public function new() 
	{
		super(0, 0);
		loadGraphic(AssetPaths.entities_00__png, true, 64, 64,false);
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		setFacingFlip(FlxObject.UP, false, false);
		setFacingFlip(FlxObject.DOWN, false, true);
		animation.add("horizontal", [1], 1, false);
		animation.add("vertical", [0], 1, false);
		animation.play("horizontal");
				//var lStyle: LineStyle = { color: FlxColor.BLACK, thickness: 1 };
		//var dStyle: DrawStyle = { smoothing: true };
		//
		//FlxSpriteUtil.drawCircle(this, -1, -1, 24, FlxColor.BLACK, lStyle, dStyle);
		//FlxSpriteUtil.drawCircle(this, x + 24, y + 16, 6, FlxColor.YELLOW, lStyle, dStyle);
		//FlxSpriteUtil.drawCircle(this, x + 40, y + 16, 6, FlxColor.YELLOW, lStyle, dStyle);
	}
	
	public function pause(value:Bool):Void
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
		setPosition(pos.x, pos.y);
		
		velocity.set();
		FlxG.watch.add(this, "x");
		FlxG.watch.add(this, "y");
		FlxG.watch.add(this.velocity, "x", "vX");
		FlxG.watch.add(this.velocity, "y", "vY");
	
	}
	
	public function resetToDefaults():Void
	{
		visible = true;
		speed = initData.speed;
		changeFacing(initData.facing);
		var pos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(initData.start);
		setPosition(pos.x, pos.y);
		velocity.set();
	}
	
	public function startPlaying():Void
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
		//acceleration.set(600, 0);
		//acceleration.rotate(FlxPoint.weak(0, 0), faceAngle);
		//maxVelocity.set(speed, 0);
		//maxVelocity.rotate(FlxPoint.weak(0, 0), faceAngle);
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