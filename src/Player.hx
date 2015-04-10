import starling.events.*;
import starling.display.Quad;
import flash.geom.Rectangle;
import bitmasq.*;

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
	private var controller : Controller;

	public function new(ctrl : Controller, c : UInt = 0xff0000)
	{
		super();

		dir = NONE;
		controller = ctrl;
		quad = new Quad(50,50,c);
		addChild(quad);
		addEventListener(Event.ADDED_TO_STAGE, addHandler);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);

		if(controller.gamepadControl)
		{
			Gamepad.get().addEventListener(GamepadEvent.CHANGE, gamepadInput);
			addEventListener(Event.REMOVED_FROM_STAGE,
			function(e:Event)
			{
				Gamepad.get().removeEventListener(GamepadEvent.CHANGE, gamepadInput);
			});
		}
		else
		{
			addEventListener(KeyboardEvent.KEY_UP, keyboardInputUp);
			addEventListener(KeyboardEvent.KEY_DOWN, keyboardInputDown);
		}
	}

	private function gamepadInput(e:GamepadEvent)
	{
		/*haxe.Log.clear();
		trace("Gamepad Event Triggered!");*/
		if(e.control == controller.left)
		{
			switch(e.value)
			{
				case 1: dir = LEFT;
				case 0: if(dir == LEFT) dir = NONE;
			}
		}
		else if(e.control == controller.right)
		{
			switch(e.value)
			{
				case 1: dir = RIGHT;
				case 0: if(dir == RIGHT) dir = NONE;
			}
		}
		else if(e.control == controller.jump)
		{
			switch(e.value)
			{
				case 1: jump();
				case 0: endJump();
			}
		}
	}

	private function keyboardInputDown(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left) dir = LEFT;
		else if(e.keyCode == controller.right)dir = RIGHT;
		else if(e.keyCode == controller.jump) jump();
	}

	private function keyboardInputUp(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left){if(dir == LEFT) dir = NONE;}
		else if(e.keyCode == controller.right){if(dir == RIGHT) dir = NONE;}
		else if(e.keyCode == controller.jump) endJump();
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

	public function reset()
	{	x = y = vel.x = vel.y = 0;}

	override public function getRect() : Rectangle
	{	return new Rectangle(x,y, quad.width, quad.height);}
}