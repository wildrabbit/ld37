package org.wildrabbit.world;
import org.wildrabbit.roach.states.PlayState.StageMode;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;

/**
 * @author ith1ldin
 */

class Actor extends FlxSprite
{
	public var offsetX(default,null): Float;
	public var offsetY(default, null): Float;
	
	public var relX(default, null):Float;
	public var relY(default, null):Float;
	
	public function new(?offsetX:Float = 0, ?offsetY:Float = 0, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		
		this.relX = X; 
		this.relY = Y;
		
		super(offsetX + relX, offsetY + relY, SimpleGraphic);		
	}
	
	public function pause(value:Bool):Void
	{}
	
	public function resetToDefaults() : Void
	{}
	
	public function startPlaying(): Void
	{
		
	}	
	
	public function setRelativePos(X:Float = 0, Y:Float = 0):Void
	{
		relX = X;
		relY = Y;		
		setPosition(relX + offsetX, relY + offsetY);
	}
	
	public function getRelativePos(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(relX, relY);
	}
	
	public function setOffset(X:Float = 0, Y:Float = 0):Void
	{
		offsetX = X;
		offsetY = Y;
		setPosition(offsetX + relX, offsetY + relY);
	}
	
	public function getOffset(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(offsetX, offsetY);
	}

}