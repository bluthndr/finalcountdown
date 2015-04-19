import starling.events.*;

class PlayerDiedEvent extends Event
{
	public var killer : Player;
	public var victim : Player;
	public inline static var DEATH = "PlayerDied";

	public function new(v : Player, k : Player)
	{
		super(DEATH);
		killer = k;
		victim = v;
	}
}