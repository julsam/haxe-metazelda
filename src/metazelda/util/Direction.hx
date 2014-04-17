package metazelda.util;

/**
 * Represents a compass direction.
 */
class Direction
{
	public static var N:Direction = new Direction(0,  0, -1);
	public static var E:Direction = new Direction(1,  1,  0);
	public static var S:Direction = new Direction(2,  0,  1);
	public static var W:Direction = new Direction(3, -1,  0);
	
	public static inline var NUM_DIRS:Int = 4;
	
	/**
	 * The integer representation of this direction.
	 */
	public var code:Int;
	public var x:Int;
	public var y:Int;
	
	private function new(code:Int, x:Int, y:Int) 
	{
		this.code = code;
		this.x = x;
		this.y = y;
	}
	
	/**
	 * Gets the direction completely opposite to this direction.
	 * 
	 * @param d the direction to return the opposite of
	 * @return  the opposite direction to d
	 */
	public static function oppositeDirection(d:Direction):Direction
	{
		if (d.equals(N)) {
			return S;
		} else if (d.equals(S)) {
			return N;
		}else if (d.equals(E)) {
			return W;
		}else if (d.equals(W)) {
			return E;
		} else {
			// Should not occur
			throw "Unknown direction";
		}
	}
	
	/**
	 * Gets the Direction for a given integer representation of a direction.
	 * 
	 * @return the Direction
	 * @see #code
	 */
	public static function fromCode(code:Int):Direction
	{
		switch (code)
		{
			case 0: return N;
			case 1: return E;
			case 2: return S;
			case 3: return W;
			default: return null;
		}
	}
	
	/**********************************************************
	* What follow was added to help port this class to haxe :
	***********************************************************/
	
	public static function values():Array<Direction>
	{
		return [N, E, S, W];
	}
	
	public function equals(other:Dynamic):Bool
	{
		if (Std.is(other, Direction)) {
			return code == other.code && x == other.x && y == other.y;
		}
		return false;
	}
	
	public inline function toString():String
	{
		return 'Direction($code, $x, $y)';
	}
}
