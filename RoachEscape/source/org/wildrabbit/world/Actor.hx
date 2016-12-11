package org.wildrabbit.world;
import org.wildrabbit.roach.PlayState.StageMode;

/**
 * @author ith1ldin
 */

interface Actor 
{
	public function pause(value:Bool):Void;
	
	public function resetToDefaults() : Void;
	
	public function startPlaying(): Void;
}