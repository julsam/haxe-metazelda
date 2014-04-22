package metazelda.constraints;

import de.polygonal.ds.ListSet;
import metazelda.util.Coords;

/**
 * Controls which spaces are valid for an
 * {@link net.bytten.metazelda.generators.IDungeonGenerator} to create
 * {@link Room}s in.
 * <p>
 * Essentially just a Set<{@link Coords}> with some convenience methods.
 * 
 * @see Coords
 * @see SpaceConstraints
 */
class SpaceMap
{
	private var spaces:ListSet<Coords> = new ListSet<Coords>();
	
	public function new() {}
	
	public function numberSpaces():Int
	{
		return spaces.size();
	}
	
	public function get(c:Coords):Bool
	{
		for (el in spaces) {
			if (el.equals(c)) {
				return true;
			}
		}
		return false;
	}
	
	public function set(c:Coords, val:Bool):Void
	{
		if (val) {
			spaces.set(c);
		} else {
			spaces.remove(c);
		}
	}
	
	private function getFirst():Coords
	{
		return spaces.iterator().next();
	}
	
	public function getBottomSpaces():List<Coords>
	{
		var bottomRow:List<Coords> = new List<Coords>();
		bottomRow.add(getFirst());
		var bottomY:Int = getFirst().y;
		for (space in spaces)
		{
			if (space.y > bottomY)
			{
				bottomY = space.y;
				bottomRow = new List<Coords>();
				bottomRow.add(space);
			}
			else if (space.y == bottomY)
			{
				bottomRow.add(space);
			}
		}
		return bottomRow;
	}
}
