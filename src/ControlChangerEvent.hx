import starling.events.Event;

class ControlChangerEvent extends Event
{
	public var id : Int;

	public function new(pID : Int)
	{
		super(Game.CHANGE_CONTROLS);
		id = pID;
	}
}