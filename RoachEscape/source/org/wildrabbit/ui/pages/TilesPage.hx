package org.wildrabbit.ui.pages;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.EditModePanel.EditOrientationData;
import org.wildrabbit.ui.TabPage;
import org.wildrabbit.world.PlaceableItemData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import org.wildrabbit.roach.AssetPaths;

/**
 * ...
 * @author ith1ldin
 */
class TilesPage extends TabPage
{
	private static inline var MAX_BUTTONS:Int = 4;
	
	private var parent:PlayState;
	private var config: EditOrientationData;
	public var toolsText: FlxText;
	public var tools: Array<ToolButton>;
	
	private var selectBorder:FlxSprite;
	
	public function new(state:PlayState, config: EditOrientationData, ?x:Float=0, ?y:Float=0) 
	{
		super(x, y);
		parent = state;
		this.config = config;
		
		tools = new Array<ToolButton>();
		
		for (i in 0...MAX_BUTTONS)
		{
			var clickBtn: Void -> Void = onToolClickBtn.bind(i);
			tools[i] = new ToolButton(config.baseX + (i % 2) * (config.spaceX + config.buttonWidth), config.baseY + Math.floor(i / 2) * (config.spaceY +  config.buttonHeight), "??", clickBtn);
			tools[i].resetGraphic(config.buttonWidth, config.buttonHeight, config.colour);
			add(tools[i]);
		}
		
		selectBorder = new FlxSprite(0, 0, AssetPaths.select__png);	
	}
	
	public function onToolClickBtn(i:Int):Void 
	{
		parent.toggleTool(i);
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function buildToolButtons(btnInfo:Array<PlaceableItemTool>, library:Map<Int,PlaceableItemData>):Void
	{
		var numberAvailable: Int = btnInfo.length;
		for (i in 0...numberAvailable)
		{
			var placeableItemData:PlaceableItemData = library.get(btnInfo[i].id);
			var s:String = placeableItemData.btnName;			
			var amount:Int = btnInfo[i].amount;
			tools[i].setToolData(placeableItemData.spritePath, placeableItemData.spriteAnims, s, amount);
			if (!tools[i].baseButton.active)
			{
				tools[i].baseButton.active = true;
			}
		}
		
		for (i in numberAvailable...MAX_BUTTONS)
		{
			if (tools[i].baseButton.active)
			{
				tools[i].resetGraphic(config.buttonWidth, config.buttonHeight, config.colour);
				tools[i].baseButton.active = false;
			}
		}
	}
	
	public function updateTool(i:Int, newAmount:Int):Void
	{
		if (tools[i] != null)
		{
			tools[i].txt.text = Std.string(newAmount);			
		}
	}

	
	override public function enable():Void
	{
		for (i in 0...tools.length)
		{
			tools[i].baseButton.active = true;
		}
		
	}
	
	override public function disable():Void
	{
		for (i in 0...tools.length)
		{
			tools[i].baseButton.active = false;
		}
		
	}
	
	public function getToolMidpoint(idx:Int, point:FlxPoint):Void
	{
		var p:FlxPoint = tools[idx].getMidpoint();
		point.set(p.x, p.y);
		p.put();
	}
	
	public function deselect():Void
	{
		remove(selectBorder);
	}
	
	public function select(idx:Int):Void
	{
		// Position:
		add(selectBorder);
		var pos:FlxPoint = FlxPoint.get();
		getToolMidpoint(idx, pos);
		trace("Midpoint: " + Std.string(pos.x) + "," + Std.string(pos.y));
		pos.subtract(selectBorder.width / 2, selectBorder.height / 2);
		selectBorder.setPosition(pos.x, pos.y);
		FlxTween.tween(selectBorder.scale, { x:1.1, y:1.1}, 0.5, { type:FlxTween.PINGPONG } );
		pos.put();
		
	}
	
}