package metazelda.util;

import de.polygonal.ds.Comparable;

/**
 * An AWT-agnostic 2D coordinate class.
 * <p>
 * Provided so that metazelda may be used on platforms without AWT (e.g.
 * Android).
 */
class Coords implements Comparable<Coords>
{
	public var x:Int;
	public var y:Int;
	
	/**
	 * Create coordinates at the given X and Y position.
	 * 
	 * @param x the position along the left-right dimension
	 * @param y the position along the top-bottom dimension
	 */
	public function new(x:Int, y:Int) 
	{
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Gets the coordinates of the next space in the given direction
	 * 
	 * @param d the direction
	 */
	public function nextInDirection(d:Direction):Coords
	{
		return add(d.x, d.y);
	}
	
	public function add(dx:Int, dy:Int):Coords
	{
		return new Coords(x + dx, y + dy);
	}
	
	public function substract(other:Coords):Coords
	{
		return new Coords(x - other.x, y - other.y);
	}
	
	public function equals(other:Dynamic):Bool
	{
		if (Std.is(other, Coords)) {
			return this.x == other.x && this.y == other.y;
		}
		return false;
	}
	
	// override
	public function compare(other:Coords):Int 
	{
		// For Dungeon's TreeMap
		var d:Int = this.x - other.x;
		if (d == 0) {
			d = this.y - other.y;
		}
		return d;
	}
	
	// Porting Helper, keep the same name as in metazelda
	public function compareTo(other:Coords):Int
	{
		return compare(other);
	}
	
	/**
	 * Determines whether this Coords and another Coords are next to each other.
	 * 
	 * @param other the other Coords
	 * @return whether they are adjacent
	 */
	public function isAdjacent(other:Coords):Bool
	{
		var dx:Int = Std.int(Math.abs(x - other.x));
		var dy:Int = Std.int(Math.abs(y - other.y));
		return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
	}
	
	/**
	 * Gets the direction from this Coords to another Coords.
	 * 
	 * @param other the other Coords
	 * @return the direction the other Coords is in
	 * @throws exception if the direction to the other Coords cannot be
	 *                   described with compass directions, e.g. if it's
	 *                   diagonal
	 */
	public function getDirectionTo(other:Coords):Direction
	{
		var dx:Int = x - other.x;
		var dy:Int = y - other.y;
		
		Utils.assert(dx == 0 || dy == 0);
		
		if (dx < 0) return Direction.E;
		if (dx > 0) return Direction.W;
		if (dy < 0) return Direction.S;
		if (dy > 0) return Direction.N;
		
		throw "Coords do not align in one dimension, or are equal";
	}
	
	public function distance(other:Coords):Float
	{
		var dx:Int = x - other.x;
		var dy:Int = y - other.y;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	public inline function toString():String
	{
		return '($x, $y)';
	}
	
	public function clone():Coords
	{
		return new Coords(x, y);
	}
}
