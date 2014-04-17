package metazelda;

import metazelda.util.Utils;

/**
 * Used to represent {@link Room}s' preconditions.
 * <p>
 * A Room's precondition can be considered the set of Symbols from the other
 * Rooms that the player must have collected to be able to reach this room. For
 * instance, if the Room is behind a locked door, the precondition for the
 * Room includes the key for that lock.
 * <p>
 * In practice, since there is always a time ordering on the collection of keys,
 * this can be implemented as a count of the number of keys the player must have
 * (the 'keyLevel').
 * <p>
 * The state of the {@link Dungeon}'s switch is also recorded in the Condition.
 * A Room behind a link that requires the switch to be flipped into a particular
 * state will have a precondition that includes the switch's state.
 * <p>
 * A Condition is 'satisfied' when the player has all the keys it requires and
 * when the dungeon's switch is in the state that it requires.
 * <p>
 * A Condition x implies a Condition y if and only if y is satisfied whenever x
 * is.
 */
class Condition
{
	private var keyLevel:Int;
	private var switchState:SwitchState;
	
	/**
	 * If arg is null :
	 *     Create a Condition that is always satisfied.
	 * If arg is a Symbol :
	 *     Creates a Condition that requires the player to have a particular
	 *     {@link Symbol}.
	 *     @param e the symbol that the player must have for the Condition to be
	 *            satisfied
	 * If arg is a Condition :
	 *     Creates a Condition from another Condition (copy it).
	 *     @param other the other Condition
	 * If arg is a SwitchState :
	 *     Creates a Condition that requires the switch to be in a particular state.
	 *     @param switchState the required state for the switch to be in
	 */
	public function new(arg:Dynamic=null)
	{
		if (arg == null)
		{
			this.keyLevel = 0;
			this.switchState = SwitchState.EITHER;
		}
		else if (Std.is(arg, Symbol))
		{
			var e:Symbol = cast(arg, Symbol);
			if (e.getValue() == Symbol.SWITCH_OFF) {
				this.keyLevel = 0;
				this.switchState = SwitchState.OFF;
			} else if (e.getValue() == Symbol.SWITCH_ON) {
				this.keyLevel = 0;
				this.switchState = SwitchState.ON;
			} else {
				this.keyLevel = e.getValue() + 1;
				this.switchState = SwitchState.EITHER;
			}
		}
		else if (Std.is(arg, Condition))
		{
			this.keyLevel = arg.keyLevel;
			this.switchState = arg.switchState;
		}
		else if (Std.is(arg, SwitchState))
		{
			this.keyLevel = 0;
			this.switchState = arg;
		}
	}
	
	public function equals(other:Dynamic):Bool
	{
		if (Std.is(other, Condition)) {
			return keyLevel == other.keyLevel && switchState == other.switchState;
		}
		return false;
	}
	
	private function addSymbol(sym:Symbol):Void
	{
		if (sym.getValue() == Symbol.SWITCH_OFF) {
			Utils.assert(switchState == null);
			switchState = SwitchState.OFF;
		} else if (sym.getValue() == Symbol.SWITCH_ON) {
			Utils.assert(switchState == null);
			switchState = SwitchState.ON;
		} else {
			keyLevel = Std.int(Math.max(keyLevel, sym.getValue() + 1));
		}
	}
	
	private function addCondition(cond:Condition):Void
	{
		if (switchState == SwitchState.EITHER) {
			switchState = cond.switchState;
		} else {
			Utils.assert(switchState == cond.switchState);
		}
		keyLevel = Std.int(Math.max(keyLevel, cond.keyLevel));
	}
	
	/**
	 * Creates a new Condition that requires this Condition to be satisfied and
	 * requires another {@link Symbol} to be obtained as well.
	 * 
	 * @param sym   the added symbol the player must have for the new Condition
	 *              to be satisfied
	 * @return      the new Condition
	 */
	public function andSymbol(sym:Symbol):Condition
	{
		var result:Condition = new Condition(this);
		result.addSymbol(sym);
		return result;
	}
	
	/**
	 * Creates a new Condition that requires this Condition and another
	 * Condition to both be satisfied.
	 * 
	 * @param other the other Condition that must be satisfied.
	 * @return      the new Condition
	 */
	public function andCondition(other:Condition):Condition
	{
		if (other == null) { return this; }
		var result:Condition = new Condition(this);
		result.addCondition(other);
		return result;
	}
	
	/**
	 * Determines whether another Condition is necessarily true if this one is.
	 * 
	 * @param other the other Condition
	 * @return  whether the other Condition is implied by this one
	 */
	public function impliesCondition(other:Condition):Bool
	{
		return keyLevel >= other.keyLevel &&
		        (switchState == other.switchState ||
		        other.switchState == SwitchState.EITHER);
	}
	
	/**
	 * Determines whether this Condition implies that a particular
	 * {@link Symbol} has been obtained.
	 * 
	 * @param s the Symbol
	 * @return  whether the Symbol is implied by this Condition
	 */
	public function impliesSymbol(s:Symbol):Bool
	{
		return impliesCondition(new Condition(s));
	}
	
	/**
	 * Gets the single {@link Symbol} needed to make this Condition and another
	 * Condition identical.
	 * <p>
	 * If {@link #and}ed to both Conditions, the Conditions would then imply
	 * each other.
	 * 
	 * @param other the other Condition
	 * @return  the Symbol needed to make the Conditions identical, or null if
	 *          there is no single Symbol that would make them identical or if
	 *          they are already identical.
	 */
	public function singleSymbolDifference(other:Condition):Symbol
	{
		// If the difference between this and other can be made up by obtaining
		// a single new symbol, this returns the symbol. If multiple or no
		// symbols are required, returns null.
		
		if (this.equals(other)) { 
			return null;
		}
		if (switchState == other.switchState) {
			return new Symbol(Std.int(Math.max(keyLevel, other.keyLevel)) - 1);
		} else {
			if (keyLevel != other.keyLevel) { return null; }
			// Multiple symbols needed          ^^^
			
			Utils.assert(switchState != other.switchState);
			if (switchState != SwitchState.EITHER &&
			        other.switchState != SwitchState.EITHER) {
				return null;
			}
			
			var nonEither:SwitchState = switchState != SwitchState.EITHER
			        ? switchState
			        : other.switchState;
			
			return new Symbol(nonEither == SwitchState.ON
			        ? Symbol.SWITCH_ON
			        : Symbol.SWITCH_OFF);
		}
	}
	
	public inline function toString():String
	{
		var result = "";
		if (keyLevel != 0) {
			result += new Symbol(keyLevel - 1).toString();
		}
		if (switchState != SwitchState.EITHER) {
			if (result != "") {
				result += ",";
			}
			result += switchState.toSymbol().toString();
		}
		return result;
	}
	
	/**
	 * Get the number of keys that need to have been obtained for this Condition
	 * to be satisfied.
	 * 
	 * @return the number of keys
	 */
	public function getKeyLevel():Int
	{
		return keyLevel;
	}
	
	/**
	 * Get the state the switch is required to be in for this Condition to be
	 * satisfied.
	 */
	public function getSwitchState():SwitchState
	{
		return switchState;
	}
}

/**
 * A type to represent the required state of a switch for the Condition to
 * be satisfied.
 */
abstract SwitchState(String)
{
	/**
	 * The switch may be in any state.
	 */
	public static inline var EITHER:SwitchState = "EITHER";
	/**
	 * The switch must be off.
	 */
	public static inline var OFF:SwitchState = "OFF";
	/**
	 * The switch must be on.
	 */
	public static inline var ON:SwitchState = "ON";
	
	private inline function new(s:String)
	{
		this = s;
	}
	
	@:from private static function fromString(s:String) {
		return new SwitchState(s);
	}
	
	@:op(A == B) static public function equals(lhs:SwitchState, rhs:SwitchState):Bool;
	
	/**
	 * Convert this SwitchState to a {@link Symbol}.
	 * 
	 * @return  a symbol representing the required state of the switch or
	 *          null if the switch may be in any state
	 */
	public function toSymbol():Symbol
	{
		if (this == OFF) {
			return new Symbol(Symbol.SWITCH_OFF);
		} else if (this == ON) {
			return new Symbol(Symbol.SWITCH_ON);
		}
		return null;
	}
	
	/**
	 * Invert the required state of the switch.
	 * 
	 * @return  a SwitchState with the opposite required switch state or
	 *          this SwitchState if no particular state is required
	 */
	public function invert():SwitchState
	{
		if (this == OFF) {
			return ON;
		} else if (this == ON) {
			return OFF;
		}
		return this;
	}
}
