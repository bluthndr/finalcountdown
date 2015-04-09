import starling.events.*;
import flash.ui.*;
import starling.display.Quad;
import flash.geom.Rectangle;

enum DIRECTION
{
	LEFT;
	RIGHT;
	NONE;
}

class Player extends GameSprite
{
	private var quad : Quad;
	private var dir : DIRECTION;

	public function new(c : UInt = 0xff0000)
	{
		super();

		dir = NONE;
		quad = new Quad(50,50,c);
		addChild(quad);
		addEventListener(Event.ADDED_TO_STAGE, addHandler);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_DOWN, inputDown);
		addEventListener(KeyboardEvent.KEY_UP, inputUp);
	}

	private function inputDown(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.LEFT:
				dir = LEFT;
			case Keyboard.RIGHT:
				dir = RIGHT;
			case Keyboard.UP:
				jump();
		}
	}

	private function inputUp(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.LEFT:
				if(dir == LEFT) dir = NONE;
			case Keyboard.RIGHT:
				if(dir == RIGHT) dir = NONE;
			case Keyboard.UP:
				endJump();
			case Keyboard.R:
				x = y = 0;
				vel.x = vel.y = 0;
			case Keyboard.F1:
				trace(x,y);
		}
	}

	private function jump()
	{
		if(onPlatform)
		{
			vel.y = -30;
			onPlatform = false;
		}
	}

	private function endJump()
	{
		if(!onPlatform && vel.y < 0)
			vel.y = 10 * weight;
	}

	override private function move()
	{
		vel.x = switch(dir)
		{
			case LEFT: -speed;
			case RIGHT: speed;
			default: 0;
		}
		lastPos.x = x; lastPos.y = y;
		x += vel.x; y += vel.y;
	}

	override public function getRect() : Rectangle
	{	return new Rectangle(x,y, quad.width, quad.height);}
}