package org.wildrabbit.ui.pages;

import flixel.util.FlxColor;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.TabPage;

/**
 * ...
 * @author ith1ldin
 */
class SettingsPage extends TabPage
{
	private var parent:PlayState;
	public function new(state:PlayState, ?x:Float=0, ?y:Float=0) 
	{
		super(x, y);
		parent = state;
	}
	
}