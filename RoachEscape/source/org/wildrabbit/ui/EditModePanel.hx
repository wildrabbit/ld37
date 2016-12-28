package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.PlayState;
import org.wildrabbit.world.PlaceableItemData;

import org.wildrabbit.ui.Orientation;

typedef EditOrientationData = 
{
	 var toolsRect: FlxRect;
	 var toolsVertical:Bool;
	 
	 var playRect: FlxRect;
	 var clearRect: FlxRect;
	 var menuRect: FlxRect;
	 
	 var baseX:Int;
	 var baseY:Int;
	 var buttonWidth:Int;
	 var buttonHeight:Int;
	 var spaceX:Int;
	 var spaceY:Int;
	 var colour:FlxColor;
	 var buttonColour:FlxColor;
	 var buttonSize:Int;
}

class EditModePanel extends FlxTypedSpriteGroup<FlxSprite>
{
	private static inline var MAX_BUTTONS:Int = 4;
	private static inline var TOOLS_TEXT:String = "TOOLS";
	
	private var parent:PlayState;
	
	public var title: FlxText;
	public var toolsText: FlxText;
	public var tools: Array<ToolButton>;
	
	public var playButton: ActionButton;
	public var clearButton: ActionButton;
	public var menuButton:ActionButton;
	
	public var borderSprite:FlxSprite;

	
	private var orientations: Array<EditOrientationData> = [
		{
			toolsRect: FlxRect.get(0, 0, 0, 0),
			toolsVertical: false,
			playRect: FlxRect.get(36,574,168,56),
			clearRect: FlxRect.get(36, 638, 168, 56),
			menuRect: FlxRect.get(36, 702, 168, 56),
			baseX: 32,
			baseY: 91,
			buttonWidth: 72,
			buttonHeight: 96,
			spaceX:24,
			spaceY:24,
			colour:FlxColor.fromString("#AF980B"),
			buttonColour:FlxColor.fromRGB(130,0,37),
			buttonSize:20,
		},
		{
			toolsRect: FlxRect.get(0, 0, 0, 0),
			toolsVertical: true,
			playRect: FlxRect.get(36,574,168,56),
			clearRect: FlxRect.get(36, 638, 168, 56),
			menuRect: FlxRect.get(36, 702, 168, 56),
			baseX:32,
			baseY: 91,
			buttonWidth: 72,
			buttonHeight: 96,
			spaceX:24,
			spaceY:24,
			colour:FlxColor.fromString("#AF980B"),
			buttonColour:FlxColor.fromRGB(130,0,37),
			buttonSize:20			
		}
	];
	
	private var currentOrientation:Orientation = Orientation.LANDSCAPE;
	

	public function new(parent:PlayState) 
	{
		super(768, 0, 0);
		this.parent = parent;
		
		
		var config:EditOrientationData = orientations[Type.enumIndex(currentOrientation)];

		if (!config.toolsVertical)
		{
			toolsText = new FlxText(config.toolsRect.x, config.toolsRect.y, 256, "", 30);
			toolsText.alignment = FlxTextAlign.CENTER;
			toolsText.text = TOOLS_TEXT;
		}
		else
		{
			var reverseTools:StringBuf = new StringBuf();
			for (c in 0...TOOLS_TEXT.length)
			{				
				reverseTools.addChar(TOOLS_TEXT.charCodeAt(c));
				reverseTools.addChar("\n".code);				
			}			
			toolsText = new FlxText(config.toolsRect.x, config.toolsRect.y, 0, reverseTools.toString(), 30);
		}
		add(toolsText);
		
		tools = new Array<ToolButton>();
		
		for (i in 0...MAX_BUTTONS)
		{
			var clickBtn: Void -> Void = onToolClickBtn.bind(i);
			tools[i] = new ToolButton(config.baseX + (i % 2) * (config.spaceX + config.buttonWidth), config.baseY + Math.floor(i / 2) * (config.spaceY +  config.buttonHeight), "??", clickBtn);
			tools[i].resetGraphic(config.buttonWidth, config.buttonHeight, config.colour);
			add(tools[i]);
		}
		
		playButton = initButton(config.playRect, onPlayButton, config.buttonColour, AssetPaths.play__png);
		
		clearButton = initButton(config.clearRect, onClearButton, config.buttonColour, AssetPaths.clear__png);
		
		menuButton = initButton( config.menuRect, onMenuButton, config.buttonColour, AssetPaths.menu__png);
	}
	
	private function initButton(rect:FlxRect, callback:Void->Void, bgColour:FlxColor,icon:Dynamic):ActionButton
	{
		var btn:ActionButton = new ActionButton(rect.x, rect.y);
		btn.build(rect,bgColour, icon, callback);
		add(btn);
		return btn;
	}
	
	public function onToolClickBtn(i:Int):Void 
	{
		parent.toggleTool(i);
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onPlayButton():Void
	{
		parent.playPressed();
		FlxG.sound.play(AssetPaths.play__wav);
	}
	
	public function onClearButton(): Void 
	{
		parent.resetPressed();
		FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function onMenuButton(): Void 
	{
		//parent.resetPressed();
		//FlxG.sound.play(AssetPaths.select__wav);
	}
	
	public function buildToolButtons(btnInfo:Array<PlaceableItemTool>, library:Map<Int,PlaceableItemData>):Void
	{
		var config:EditOrientationData = orientations[Type.enumIndex(currentOrientation)];
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
	
	public function goToEdit():Void
	{
		active = true;
		visible = true;
		
		for (i in 0...tools.length)
		{
			tools[i].baseButton.active = true;
		}
	}
	
	public function goToPlay():Void
	{
		active = false;
		visible = false;
		
		for (i in 0...tools.length)
		{
			tools[i].baseButton.active = false;
		}
	}
}