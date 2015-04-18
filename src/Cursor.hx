import starling.display.Image;
import starling.events.*;

enum CURSOR_DIRECTION
{
	POSITIVE;
	NEGATIVE;
	NO_DIR;
}

class Cursor extends Image
{
	public var vertDir : CURSOR_DIRECTION;
	public var horiDir : CURSOR_DIRECTION;
	public function new(c : UInt = 0xffffff)
	{
		super(Root.assets.getTexture("fist"));
		vertDir = horiDir = NO_DIR;
		color = c;
		addEventListener(Event.ADDED_TO_STAGE, function()
		{
			removeEventListeners(Event.ADDED_TO_STAGE);
			addEventListener(Event.ENTER_FRAME, update);
		});
		scaleX = scaleY = 0.1;
		alignPivot();
	}

	public function reset()
	{	vertDir = horiDir = NO_DIR; rotation = 0;}

	private function update(e:EnterFrameEvent)
	{
		var velx = 0; var vely = 0;
		switch(vertDir)
		{
			case NEGATIVE:
				if(y > 0)vely = -5;
			case POSITIVE:
				if(y < Startup.stageHeight()) vely = 5;
			default:
		}
		switch(horiDir)
		{
			case NEGATIVE:
				if(x > 0) velx = -5;
			case POSITIVE:
				if(x < Startup.stageWidth()) velx = 5;
			default:
		}
		if(vely != 0 || velx != 0)
		{
			y += vely; x += velx;
			rotation = Math.atan2(vely,velx);
		}
	}
}