package metazelda.generators;

/**
 * Interface for classes that provide methods to procedurally generate new
 * {@link IDungeon}s.
 */
interface IDungeonGenerator
{
	/**
	 * Generates a new {@link IDungeon}.
	 */
	public function generate():Void;
	
	/**
	 * Gets the most recently generated {@link IDungeon}.
	 * 
	 * @return the most recently generated IDungeon
	 */
	public function getDungeon():IDungeon;
	
	public function getSeed():Int;
}
