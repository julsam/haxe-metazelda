package metazelda.constraints;

import metazelda.util.Coords;

/**
 * Implementing classes may specify constraints to be placed on Dungeon
 * generation.
 * 
 * @see net.bytten.metazelda.generators.IDungeonGenerator
 */
interface IDungeonConstraints
{
	/**
	 * Determines whether the
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} may place a
	 * Room at the given coordinates
	 * 
	 * @param c the coordinates
	 * @return whether a room can be placed here
	 */
	public function validRoomCoords(c:Coords):Bool;
	
	/**
	 * @return  the maximum number of Rooms an 
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} may
	 *          place in an {@link net.bytten.metazelda.IDungeon}
	 */
	public function getMaxSpaces():Int;
	
	/**
	 * @return  the maximum number of keys an 
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} may
	 *          place in an {@link net.bytten.metazelda.IDungeon}
	 */
	public function getMaxKeys():Int;
	
	/**
	 * Gets the number of switches the
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} is allowed to
	 * place in an {@link net.bytten.metazelda.IDungeon}.
	 * Note only one switch is ever placed due to limitations of the current
	 * algorithm.
	 * 
	 * @return  the maximum number of switches an
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} may
	 *          place in an {@link net.bytten.metazelda.IDungeon}
	 */
	public function getMaxSwitches():Int;
	
	/**
	 * Gets the collection of coordinates from which an
	 * {@link net.bytten.metazelda.generators.IDungeonGenerator} is allowed to
	 * pick the coordinates of the entrance room.
	 * 
	 * @return the collection of {@link net.bytten.metazelda.util.Coords} objects
	 *         (coordinates)
	 */
	public function initialCoords():List<Coords>;
	
	/**
	 * Runs post-generation checks to determine the suitability of the dungeon.
	 * 
	 * @param dungeon   the {@link net.bytten.metazelda.IDungeon} to check
	 * @return  true to keep the dungeon, or false to discard the dungeon and
	 *          attempt generation again
	 */
	public function isAcceptable(dungeon:IDungeon):Bool;
}
