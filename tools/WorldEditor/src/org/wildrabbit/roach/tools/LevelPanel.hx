package org.wildrabbit.roach.tools;

import haxe.ui.toolkit.containers.HBox;
import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Text;
import haxe.ui.toolkit.controls.TextInput;
import haxe.ui.toolkit.text.TextDisplay;

/**
 * ...
 * @author ith1ldin
 */
class LevelPanel extends VBox
{
	public var filename:TextInput;
	private var levelID:Int = -1;
	
	public var container:VBox;
	
	public function new() 
	{
		super();
	}
	
	public function init(levelID:Int):Void
	{
		this.levelID = levelID;
		
		text = "Level " + Std.string(this.levelID);
		
		var nameContainer:HBox = new HBox();
		addChild(nameContainer);
		var label:Text = new Text();
		label.text = "Filename:";
		nameContainer.addChild(label);
		filename = new TextInput();
		filename.text = "level"+Std.string(levelID)+".tmx";
		nameContainer.addChild(filename);
	}
	
}