package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.world.PlaceableItemData;

/**
 * ...
 * @author ith1ldin
 */
class HUD extends FlxTypedSpriteGroup<FlxSprite>
{
	public var tools:Array<ToolButton>;
	
	private var playButton:FlxButton;
	private var resetButton:FlxButton;	
	private var parent: PlayState;
	
	private var playRect:FlxRect = FlxRect.get(812, 583, 168, 56);
	private var resetRect:FlxRect = FlxRect.get(812, 656, 168, 56);
	
	
	var baseX: Int = 812;
	var baseY: Int = 91;
	var buttonWidth: Int = 72;
	var buttonHeight: Int = 96;
	var spaceX: Int = 24;
	var spaceY: Int = 24;
	var colour: FlxColor = FlxColor.fromString("#af980b");
	var buttonColour:FlxColor = FlxColor.fromRGB(130, 0, 37);
	var buttonSize:Int = 20;
		
		
	private static inline var MAX_BUTTONS:Int = 8;
	
	public function new(parent:PlayState) 
	{
		super(0,0,0);

		this.parent = parent;
		tools = new Array<ToolButton>();
		
		var i:Int = 0;
	
		while (i <MAX_BUTTONS)
		{
			var clickBtn: Void -> Void = onToolClickBtn.bind(i);
			tools[i] = new ToolButton(baseX + (i % 2) * (spaceX + buttonWidth), baseY + Math.floor(i / 2) * (spaceY +  buttonHeight), "??", clickBtn);
			tools[i].resetGraphic(buttonWidth, buttonHeight, colour);
			add(tools[i]);
			i++;
		}
		
		playButton = new FlxButton(playRect.x, playRect.y, "PLAY/PAUSE", onPlayButton);
		playButton.makeGraphic(Std.int(playRect.width), Std.int(playRect.height), buttonColour);
		playButton.label.size = buttonSize;
		playButton.label.color = FlxColor.WHITE;
		playButton.label.x = playRect.x + playRect.width / 2 - playButton.label.width / 2;
		playButton.label.y = playRect.y + playRect.height/ 2;
		add(playButton);
		
		resetButton = new FlxButton(resetRect.x, resetRect.y, "CLEAR/EDIT", onResetButton);
		resetButton.makeGraphic(Std.int(resetRect.width), Std.int(resetRect.height), buttonColour);
		resetButton.label.size = buttonSize;
		resetButton.label.color = FlxColor.WHITE;
		resetButton.label.x = resetRect.x + resetRect.width/ 2 - resetButton.label.width / 2;
		resetButton.label.y = resetRect.y  + resetRect.height / 2;
		add(resetButton);
	}
	
	public function onStageModeChanged(stageMode:StageMode)
	{
		switch(stageMode)
		{
			case StageMode.EDIT:
			{
				playButton.text = "GO!";
				resetButton.text = "CLEAR";
				for (i in 0...tools.length)
				{
					tools[i].baseButton.active = true;
				}
			}
			case StageMode.OVER:
			{
				playButton.text = "EDIT";
				resetButton.text = "EXIT";
				for (i in 0...tools.length)
				{
					tools[i].baseButton.active = false;
				}
			}
			case StageMode.PAUSE:
			{
				playButton.text = "PLAY";
				resetButton.text = "EDIT";
				for (i in 0...tools.length)
				{
					tools[i].baseButton.active = false;
				}
			}
			case StageMode.PLAY:
			{
				playButton.text = "PAUSE";
				resetButton.text = "EDIT";
				for (i in 0...tools.length)
				{
					tools[i].baseButton.active = false;
				}
			}
			playButton.label.x = playRect.x + playRect.width / 2 - playButton.label.width / 2;
			playButton.label.y = playRect.y + playRect.height / 2;
			resetButton.label.x = resetRect.x + resetRect.width/ 2 - resetButton.label.width / 2;
			resetButton.label.y = resetRect.y  + resetRect.height / 2;
		}
	}
	
	public function onToolClickBtn(i:Int):Void 
	{
		trace("clicked button " + i);
		parent.toggleTool(i);
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onPlayButton():Void
	{
		trace("start sim");
		parent.playPressed();
		FlxG.sound.play(AssetPaths.play__wav);
	}
	
	public function onResetButton(): Void 
	{
		trace("clear shit from level");
		parent.resetPressed();
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