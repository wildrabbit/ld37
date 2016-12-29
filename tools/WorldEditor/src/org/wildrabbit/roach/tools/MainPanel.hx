package org.wildrabbit.roach.tools;
import haxe.ui.toolkit.containers.Accordion;
import haxe.ui.toolkit.containers.Container;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.events.UIEvent;
import openfl.events.Event;
import openfl.display.Sprite;

import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.interfaces.IDisplayObjectContainer;

/**
 * ...
 * @author ith1ldin
 */
class MainPanel extends VBox
{
	private var list:Array<Int> = new Array<Int>();
	private var addNew:Button;
	private var removeSelected:Button;
	private var moveUp:Button;
	private var moveDown:Button;
	
	private var levelAccordion:Accordion;
	
	public function new() 
	{
		super();
		addNew = new Button();
		addNew.x = 10;
		addNew.y = 10;
		addNew.text = "Add";
		addNew.addEventListener(UIEvent.CLICK, addNewLevel);				
		addChild(addNew);
		
		levelAccordion = new Accordion();
		levelAccordion.width = 700;
		levelAccordion.height = 500;
		levelAccordion.x = 50;
		levelAccordion.y = 80;
		addChild(levelAccordion);
	}
	
	public function addNewLevel(evt:UIEvent):Void
	{
		trace("New level!");
		list.push(list.length);
		var i:Int = list[list.length - 1];
		var newPanel:LevelPanel = new LevelPanel();
		newPanel.init(i);
		levelAccordion.addChild(newPanel);
	}
	
}