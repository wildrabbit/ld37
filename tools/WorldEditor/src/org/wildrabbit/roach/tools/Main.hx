package org.wildrabbit.roach.tools;

import haxe.ui.toolkit.core.Macros;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.events.UIEvent;
import haxe.ui.toolkit.themes.GradientTheme;
  
class Main {
    public static function main() {
        Toolkit.theme = new GradientTheme();
        Toolkit.init();
        Toolkit.openFullscreen(function(root:Root) {
		var panel:MainPanel = new MainPanel();
		root.addChild(panel);
			
/*			var view:IDisplayObject= Toolkit.processXmlResource("assets/accordion.xml");
			root.addChild(view);*/
       });
    }
}