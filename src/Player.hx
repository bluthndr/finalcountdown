import starling.events.*;
import starling.display.*;
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
	private var body : Quad;
	private var dir : DIRECTION;
	private var controller : Controller;
	private var curRect : Rectangle;
	private var lastRect : Rectangle;
	private var jumpHeld : Bool;

	public function new(p : PlayerPanel, i : UInt = 0)
	{
		super();

		dir = NONE;
		controller = p.getCtrls();
		curRect = new Rectangle(x,y,50,50);
		lastRect = new Rectangle(x,y,50,50);
		jumpHeld = false;

		body = new Quad(50,50,p.getColor());
		addChild(body);
		addEventListener(Event.ADDED_TO_STAGE, addHandler);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);

		if(controller.gamepad)
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
		if(e.deviceIndex == controller.padID)
		{
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
			else if(e.control == controller.down)
			{
				if(e.value == 1)
					fastFall();
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
	}

	private function keyboardInputDown(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left) dir = LEFT;
		else if(e.keyCode == controller.right)dir = RIGHT;
		else if(e.keyCode == controller.jump) jump();
		else if(e.keyCode == controller.down) fastFall();
	}

	private function keyboardInputUp(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left){if(dir == LEFT) dir = NONE;}
		else if(e.keyCode == controller.right){if(dir == RIGHT) dir = NONE;}
		else if(e.keyCode == controller.jump) endJump();
	}

	private function jump()
	{
		if(!jumpHeld && onPlatform())
		{
			vel.y = -30;
			platOn = null;
			jumpHeld = true;
		}
	}

	private function endJump()
	{
		if(!onPlatform() && vel.y < 0)
			vel.y = 10 * weight;
		jumpHeld = false;
	}

	private function fastFall()
	{
		if(!onPlatform() && (!jumpHeld || vel.y < 0) && vel.y < 15)
			vel.y = 15;
	}

	public function reset()
	{	x = y = vel.x = vel.y = 0;}

	public function getColor() : UInt
	{	return body.color;}

	override private function move()
	{
		vel.x = switch(dir)
		{
			case LEFT: -speed;
			case RIGHT: speed;
			default: 0;
		}
		lastPos.x = x; lastPos.y = y;
		lastRect.x = curRect.x; lastRect.y = curRect.y;

		x += vel.x; y += vel.y;
		curRect.x = x; curRect.y = y;
	}

	override public function getRect() : Rectangle
	{	return curRect.union(lastRect);}
}