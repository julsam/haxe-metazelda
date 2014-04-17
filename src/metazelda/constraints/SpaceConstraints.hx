package metazelda.constraints;

import metazelda.util.Coords;

/**
 * Constrains the coordinates where Rooms may be placed to be only those within
 * the {@link SpaceMap}, as well as placing limitations on the number of keys
 * and switches.
 * 
 * @see CountConstraints
 * @see SpaceMap
 */
class SpaceConstraints extends CountConstraints
{
	public static inline var DEFAULT_MAX_KEYS:Int = 4;
	public static inline var DEFAULT_MAX_SWITCHES:Int = 1;
	
	private var spaceMap:SpaceMap;
	
	public function new(spaceMap:SpaceMap) 
	{
		super(spaceMap.numberSpaces(), DEFAULT_MAX_KEYS, DEFAULT_MAX_SWITCHES);
		this.spaceMap = spaceMap;
	}
	
	override public function validRoomCoords(c:Coords):Bool
	{
		return c != null && spaceMap.get(c);
	}
	
	override public function initialCoords():List<Coords>
	{
		return spaceMap.getBottomSpaces();
	}
}
