package org.wildrabbit.world;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil.DrawStyle;
import flixel.util.FlxSpriteUtil.LineStyle;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
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
	// stuff
	
	public override function update(dt:Float):Void 
	{
		var iX:Int = Math.round(x);
		var iY:Int = Math.round(y);
		var oldCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(iX, iY);

		var oldPos:FlxPoint = FlxPoint.get(x, y);
		var coordsTL:FlxPoint = null;
		var coordsBR:FlxPoint = null;
		var coordsTR:FlxPoint = null;
		var coordsBL:FlxPoint = null;
		
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
				var midPointCoords:FlxPoint = parent.levelData.getTilePositionFromWorld(Math.round(x + width / 2), Math.round(y + height / 2));
				
				if (goalCoords.equals(midPointCoords) && getPosition().distanceTo(parent.goal.getPosition()) < 10)
				{
					trace("yeah!");
					parent.onReachedGoal();
				}
				else {
					var wallHitTL = parent.levelData.getTileAt(coordsTL) == TileType.EMPTY || parent.levelData.getTileAt(coordsTL) == TileType.WALL || parent.levelData.hitsEdgeAt(oldCoords, coordsTL);
					var wallHitTR = parent.levelData.getTileAt(coordsTR) == TileType.EMPTY ||parent.levelData.getTileAt(coordsTR) == TileType.WALL || parent.levelData.hitsEdgeAt(oldCoords, coordsTR);
					var wallHitBL = parent.levelData.getTileAt(coordsBL) == TileType.EMPTY ||parent.levelData.getTileAt(coordsBL) == TileType.WALL || parent.levelData.hitsEdgeAt(oldCoords, coordsBL);
					var wallHitBR = parent.levelData.getTileAt(coordsBR) == TileType.EMPTY || parent.levelData.hitsEdgeAt(oldCoords, coordsBR);
					if (wallHitTL || wallHitTR || wallHitBL || wallHitBR)
					{
						var pos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(oldCoords);
						setPosition(pos.x,pos.y);
						changeFacing(calculateNextFacing());
					}	
				}
				
				goalCoords.put();
				midPointCoords.put();
			}
		}
		oldPos.put();
		oldCoords.put();
		if (coordsTL != null) coordsTL.put();
		if (coordsTR != null) coordsTR.put();
		if (coordsBL != null) coordsBL.put();
		if (coordsBR != null) coordsBR.put();		
	}

	public function new() 
	{
		super(0, 0);
		loadGraphic(AssetPaths.entities_00__png, true, 64, 64);
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
		speed = initData.speed;
		changeFacing(initData.facing);
		var pos:FlxPoint = parent.levelData.getWorldPositionFromTileCoords(initData.start);
		setPosition(pos.x, pos.y);
		velocity.set();
	}
	
	public function startPlaying():Void
	{
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