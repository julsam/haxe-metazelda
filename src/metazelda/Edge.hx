package metazelda;

/**
 * Links two {@link Room}s.
 * <p>
 * The attached {@link Symbol} is a condition that must be satisfied for the
 * player to pass from one of the linked Rooms to the other via this Edge. It is
 * implemented as a {@link Symbol} rather than a {@link Condition} to simplify
 * the interface to clients of the library so that they don't have to handle the
 * case where multiple Symbols are required to pass through an Edge.
 * <p>
 * An unconditional Edge is one that may always be used to go from one of the
 * linked Rooms to the other.
 */
class Edge
{
	private var symbol:Symbol;
	
	/**
	 * Creates an Edge that requires a particular Symbol to be collected before
	 * it may be used by the player to travel between the Rooms.
	 * If no symbol is given, it creates an unconditional Edge.
	 * 
	 * @param symbol    the symbol that must be obtained
	 */
	public function new(symbol:Symbol=null)
	{
		this.symbol = symbol;
	}
	
	/**
	 * @return  whether the Edge is conditional
	 */
	public function hasSymbol():Bool
	{
		return symbol != null;
	}
	
	/**
	 * @return  the symbol that must be obtained to pass along this edge or null
	 *          if there are no required symbols
	 */
	public function getSymbol():Symbol {
		return symbol;
	}
	
	public function setSymbol(symbol:Symbol):Void {
		this.symbol = symbol;
	}
	
	public function equals(other:Dynamic):Bool
	{
		if (Std.is(other, Edge)) {
			return symbol == other.symbol || symbol.equals(other.symbol);
		}
		return false;
	}
}
