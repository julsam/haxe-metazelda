package metazelda.constraints;

import metazelda.IDungeon;
import metazelda.util.Coords;

/**
 * Limits the {@link net.bytten.metazelda.generators.IDungeonGenerator} only in
 * the <i>number</i> of keys, switches and rooms it is allowed to place.
 * 
 * @see IDungeonConstraints
 */
class CountConstraints implements IDungeonConstraints
{
	private var maxSpaces:Int;
	private var maxKeys:Int;
	private var maxSwitches:Int;
	
	public function new(maxSpaces:Int, maxKeys:Int, maxSwitches:Int)
	{
		this.maxSpaces = maxSpaces;
		this.maxKeys = maxKeys;
		this.maxSwitches = maxSwitches;	
	}
	
	/* INTERFACE metazelda.constraints.IDungeonConstraints */
	
	public function getMaxSpaces():Int
	{
		return maxSpaces;
	}
	
	public function setMaxSpaces(maxSpaces:Int):Void
	{
		this.maxSpaces = maxSpaces;
	}
	
	public function getMaxKeys():Int
	{
		return maxKeys;
	}
	
	public function setMaxKeys(maxKeys:Int):Void
	{
		this.maxKeys = maxKeys;
	}
	
	public function getMaxSwitches():Int
	{
		return maxSwitches;
	}
	
	public function setMaxSwitches(maxSwitches:Int):Void
	{
		this.maxSwitches = maxSwitches;
	}
	
	public function validRoomCoords(c:Coords):Bool
	{
		return c != null && c.y <= 0; // TODO: keep it or remove it
	}
	
	public function initialCoords():List<Coords>
	{
		return Lambda.list([new Coords(0, 0)]);
	}
	
	public function isAcceptable(dungeon:IDungeon):Bool
	{
		return true;
	}
}
