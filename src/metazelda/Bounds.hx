package metazelda;

/**
 * An AWT-independent minimal {@link java.awt.Rectangle}-like class.
 * <p>
 * Provides only the methods required by the metazelda algorithm.
 * AWT-independent so that it may be used on platforms without AWT (e.g.
 * Android).
 */
class Bounds
{
	public var left:Int;
	public var top:Int;
	public var right:Int;
	public var bottom:Int;
	
	/**
	 * Create a Bounds object with given coordinates.
	 * @param x         the X coordinate of the left side of the rectangle
	 * @param y         the Y coordinate of the top side of the rectangle
	 * @param right     the X coordinate of the right side of the rectangle
	 * @param bottom    the Y coordinate of the bottom side of the rectangle
	 */ 
	public function new(x:Int, y:Int, right:Int, bottom:Int) 
	{
		this.left = x;
		this.top = y;
		this.right = right;
		this.bottom = bottom;
	}
	
	/**
	 * Gets the width of the rectangle.
	 * @return width of the rectangle
	 */
	public function width():Int
	{
		return right - left + 1;
	}
	
	/**
	 * Gets the height of the rectangle.
	 * @return height of the rectangle
	 */
	public function height():Int
	{
		return bottom - top + 1;
	}
	
	public inline function toString():String
	{
		return 'Bounds($left, $top, $right, $bottom)';
	}
}