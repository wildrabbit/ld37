package org.wildrabbit.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.pages.GoalsPage;
import org.wildrabbit.ui.pages.SettingsPage;
import org.wildrabbit.ui.pages.TilesPage;
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
	private static inline var TOOLS_TEXT:String = "PLAYBACK";
	
	private var parent:PlayState;
	
	public var title: FlxText;
	public var toolsText: FlxText;
	public var tools: Array<ToolButton>;
	
	public var playButton: ActionButton;
	public var clearButton: ActionButton;
	public var menuButton:ActionButton;
	
	public var borderSprite:FlxSprite;
	
	public var tabWidget: TabWidget;
	
	public var tilesPage: TilesPage;
	public var goalsPage: GoalsPage;
	public var settingsPage: SettingsPage;

	
	private var orientations: Array<EditOrientationData> = [
		{
			toolsRect: FlxRect.get(0, 48, 0, 0),
			toolsVertical: false,
			playRect: FlxRect.get(0,100,68,68),
			clearRect: FlxRect.get(88, 100, 68, 68),
			menuRect: FlxRect.get(176, 100, 68, 68),
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
			toolsRect: FlxRect.get(0, 16, 0, 0),
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
			toolsText.font = AssetPaths.small_text__TTF;
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
		
		playButton = initButton(config.playRect, onPlayButton, config.buttonColour, AssetPaths.play__png);
		clearButton = initButton(config.clearRect, onClearButton, config.buttonColour, AssetPaths.clear__png);
		menuButton = initButton( config.menuRect, onMenuButton, config.buttonColour, AssetPaths.menu__png);
		
		tilesPage = new TilesPage(parent, config);
		goalsPage = new GoalsPage(parent);
		settingsPage = new SettingsPage(parent);
		
		tabWidget = new TabWidget(0, 210);
		add(tabWidget);
		tabWidget.addPage(UIAtlasNames.ICON_TILES, "TILES", tilesPage);
		tabWidget.addPage(UIAtlasNames.ICON_GOALS, "GOALS", goalsPage);
		tabWidget.addPage(UIAtlasNames.ICON_SETTINGS, "SETTINGS", settingsPage);
		tabWidget.setPage(0);
	}
	
	private function initButton(rect:FlxRect, callback:Void->Void, bgColour:FlxColor,icon:Dynamic):ActionButton
	{
		var btn:ActionButton = new ActionButton(rect.x, rect.y);
		btn.build(rect,bgColour, icon, callback);
		add(btn);
		return btn;
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
	
	
	public function goToEdit():Void
	{
		active = true;
		visible = true;
		
		tabWidget.setActivePageEnabled(true);
	}
	
	public function goToPlay():Void
	{
		active = false;
		visible = false;
		
		tabWidget.setActivePageEnabled(false);
	}
	
	public function updateToolPage(idx:Int, amount:Int):Void
	{
		tilesPage.updateTool(idx, amount);
	}
	
	public function buildTools(btnInfo:Array<PlaceableItemTool>, library:Map<Int,PlaceableItemData>):Void
	{
		tilesPage.buildToolButtons(btnInfo, library);
	}
	
	public function getToolMidpoint(idx:Int, point:FlxPoint):Void
	{
		tilesPage.getToolMidpoint(idx, point);
	}
	
	public function deselectTool():Void
	{
		tilesPage.deselect();
	}
	
	public function selectTool(idx:Int):Void
	{
		tilesPage.select(idx);
	}
}