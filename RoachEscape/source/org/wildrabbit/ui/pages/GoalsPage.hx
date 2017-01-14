package org.wildrabbit.ui.pages;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import org.wildrabbit.roach.AssetPaths;
import org.wildrabbit.roach.states.PlayState;
import org.wildrabbit.ui.PlayModePanel.PlayOrientationData;
import org.wildrabbit.ui.TabPage;
import org.wildrabbit.roach.Reg;
import org.wildrabbit.data.ObjectiveData;
import org.wildrabbit.world.GameWorldState.ObjectiveState;
/**
 * ...
 * @author ith1ldin
 */
class GoalsPage extends TabPage
{
	private var parent:PlayState;
	
	// Goals
	private var goals:Array<GoalPanel>;
	private var atlas: FlxAtlasFrames;

	public function new(state:PlayState, ?x:Float=0, ?y:Float=0) 
	{
		super(x, y);
		parent = state;
		atlas = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.ui__png, AssetPaths.ui__json);
		
		initGoalsPanel();
	}
	
	private function initGoalsPanel():Void 
	{
		goals = new Array<GoalPanel>();
		
		var objRef:Array<ObjectiveData> = Reg.currentLevel.objectives;
		var height:Float = 36;
		var medalIdx:Int = 0;
		var offsetX:Float = 24;
		var offsetY:Float = 32;
		var padY: Float = 24;
		var objStateList:Array<ObjectiveState> = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx].objectives;
		for (objectiveData in objRef)
		{
			var objState:ObjectiveState = objStateList[medalIdx];
			var revealed:Bool = medalIdx < 2 || objState.completed || objStateList[medalIdx - 1].completed;
			var obj:GoalPanel = new GoalPanel(offsetX, offsetY, atlas, medalIdx, objectiveData.getText(), revealed, objState.completed);
			add(obj);	
			medalIdx++;
			offsetY += height + padY;
			goals.push(obj);
		}		
	}
	
		
	public function updateObjective(idx:Int, completed:Bool):Void
	{
		var revealed:Bool = goals[idx].tickBox.visible;
		goals[idx].setRevealed(completed ? true : revealed, completed);		
	}
	
	public function setGoalRevealed(idx:Int, revealed:Bool, completed:Bool):Void
	{
		goals[idx].setRevealed(revealed, completed);
	}
	
	public function updateAllGoals():Void
	{
		if (goals == null || goals.length == 0) return;
		
		var objStateList:Array<ObjectiveState> = Reg.gameWorld.worldTable[Reg.gameWorld.currentWorldIdx].levelObjectiveTable[Reg.gameWorld.currentLevelIdx].objectives;
		var medalIdx:Int = 0;
		
		if (goals != null && goals.length > 0)
		{
			for (goal in goals)
			{
				var objState:ObjectiveState = objStateList[medalIdx];
				var revealed:Bool = medalIdx < 2 || objState.completed || objStateList[medalIdx - 1].completed;
				goal.setRevealed(revealed, objState.completed);
				medalIdx++;						
			}	
		}		
	}
	
	override public function refreshVisibility():Void
	{
		updateAllGoals();
	}
}