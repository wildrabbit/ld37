package org.wildrabbit.roach.states;

import flixel.FlxState;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import org.wildrabbit.ui.TabPage;
import org.wildrabbit.ui.TabWidget;
import org.wildrabbit.ui.UIAtlasNames;

/**
 * ...
 * @author ith1ldin
 */
class TabTest extends FlxState
{
	var tab:TabWidget;

	override public function create():Void
	{
		super.create();
		tab = new TabWidget(50, 50);
		add(tab);
		tab.addPage(UIAtlasNames.ICON_GOALS, "GOALS", new TabPage(FlxColor.MAGENTA));
		tab.addPage(UIAtlasNames.ICON_STATS, "STATS", new TabPage(FlxColor.CYAN));
		tab.addPage(UIAtlasNames.ICON_SETTINGS, "SETTINGS", new TabPage(FlxColor.PURPLE));
		//tab.setPage(0);
	}
}