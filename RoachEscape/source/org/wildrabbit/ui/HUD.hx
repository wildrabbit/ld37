package org.wildrabbit.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.world.PlaceableItemData;

/**
 * ...
 * @author ith1ldin
 */
class HUD extends FlxTypedSpriteGroup<FlxSprite>
{
	private var tools:Array<ToolButton>;
	
	private var playButton:FlxButton;
	private var resetButton:FlxButton;	
	private var parent: PlayState;
	
	private static inline var MAX_BUTTONS:Int = 8;
	
	public function new(parent:PlayState) 
	{
		super(0,0,0);

		this.parent = parent;
		tools = new Array<ToolButton>();
		var i:Int = 0;
		var baseX: Int = 812;
		var baseY: Int = 91;
		var buttonWidth: Int = 72;
		var buttonHeight: Int = 96;
		var spaceX: Int = 24;
		var spaceY: Int = 24;
		var colour: FlxColor = FlxColor.fromString("#af980b");
		while (i <MAX_BUTTONS)
		{
			var clickBtn: Void -> Void = onToolClickBtn.bind(i);
			tools[i] = new ToolButton(baseX + (i % 2) * (spaceX + buttonWidth), baseY + Math.floor(i / 2) * (spaceY +  buttonHeight), "??", clickBtn);
			tools[i].resetGraphic(buttonWidth, buttonHeight, colour);
			add(tools[i]);
			i++;
		}
		
		playButton = new FlxButton(812, 583, "PLAY/PAUSE", onPlayButton);
		playButton.makeGraphic(168, 56, FlxColor.fromRGB(130,0,37));
		add(playButton);
		resetButton = new FlxButton(812, 656, "CLEAR/EDIT", onResetButton);
		resetButton.makeGraphic(168, 56, FlxColor.fromRGB(130, 0, 37));
		add(resetButton);
	}
	
	public function onToolClickBtn(i:Int):Void 
	{
		trace("clicked button " + i);
		parent.toggleTool(i);
	}
	
	public function onPlayButton():Void
	{
		trace("start sim");
		parent.playPressed();
	}
	
	public function onResetButton(): Void 
	{
		trace("clear shit from level");
		parent.resetPressed();
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
				tools[i].resetGraphic(72, 96, FlxColor.fromString("#af980b"));
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
}