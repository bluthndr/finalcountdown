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
	private var image : PlayerImage;
	private var bound : Quad;
	private var curDir : DIRECTION;
	private var lastDir : DIRECTION;
	private var controller : Controller;
	private var curRect : Rectangle;
	private var lastRect : Rectangle;
	private var jumpHeld : Bool;
	private var color : UInt;
	private var stunLength : Int;
	private var meter : PlayerMeter;

	public static inline var WIDTH = 48;
	public static inline var HEIGHT = 64;

	private static inline var lavaKnockback = 1.5;

	public function new(p : PlayerPanel, i : UInt = 0)
	{
		super();

		curDir = NONE;
		lastDir = RIGHT;
		stunLength = 0;
		controller = p.getCtrls();
		jumpHeld = false;
		charWidth = WIDTH;
		charHeight = HEIGHT;
		color = p.getColor();

		meter = new PlayerMeter(this, i);
		image = new PlayerImage(color);
		addChild(image);

		bound = new Quad(WIDTH,HEIGHT,color);
		bound.alpha = 0.5;
		bound.visible = false;
		addChild(bound);

		curRect = new Rectangle(x,y,WIDTH,HEIGHT);
		lastRect = curRect.clone();
		addEventListener(Event.ADDED_TO_STAGE, addHandler);
	}

	public function toggleBound()
	{	bound.visible = !bound.visible;}

	public function addMeter(level : Level)
	{	level.addChild(meter);}

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
		if(e.deviceIndex == controller.padID)
		{
			if(e.control == controller.left)
			{
				switch(e.value)
				{
					case 1: curDir = LEFT;
					case 0: if(curDir == LEFT) curDir = NONE;
				}
			}
			else if(e.control == controller.right)
			{
				switch(e.value)
				{
					case 1: curDir = RIGHT;
					case 0: if(curDir == RIGHT) curDir = NONE;
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
		if(e.keyCode == controller.left) curDir = LEFT;
		else if(e.keyCode == controller.right)curDir = RIGHT;
		else if(e.keyCode == controller.jump) jump();
		else if(e.keyCode == controller.down) fastFall();
	}

	private function keyboardInputUp(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left){if(curDir == LEFT) curDir = NONE;}
		else if(e.keyCode == controller.right){if(curDir == RIGHT) curDir = NONE;}
		else if(e.keyCode == controller.jump) endJump();
	}

	override public function lavaCollision(lava : Lava)
	{
		if(this.getRect().intersects(lava.getRect()))
		{
			if(!onPlatform() && vel.y > 0 && lastPos.y <= lava.y - charHeight)
			{
				meter.takeDamage(10);
				vel.y = -lavaKnockback * meter.getDamage();
				stunLength = 30;
				image.setAnimation(STUN);
			}
			else if(vel.x >= 0 && lastPos.x <= lava.x - charWidth)
			{
				meter.takeDamage(10);
				vel.x = -lavaKnockback * meter.getDamage();
				stunLength = 30;
				image.setAnimation(STUN);
			}
			else if(vel.x <= 0 && lastPos.x >= lava.x + lava.width)
			{
				meter.takeDamage(10);
				vel.x = lavaKnockback * meter.getDamage();
				stunLength = 30;
				image.setAnimation(STUN);
			}
			else if(vel.y < 0 && lastPos.y >= lava.y + lava.height)
			{
				meter.takeDamage(10);
				vel.y = lavaKnockback * meter.getDamage();
				stunLength = 30;
				image.setAnimation(STUN);
			}
		}
	}

	private function jump()
	{
		if(!jumpHeld && onPlatform())
		{
			vel.y = -30;
			platOn = null;
			jumpHeld = true;
			image.setAnimation(JUMP);
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
	{	return color;}

	private function setDir(f: Bool)
	{
		if(lastDir != curDir)
		{
			if(f)
			{
				image.scaleX = Math.abs(image.scaleX) * -1;
				image.x += WIDTH;
			}
			else
			{
				image.scaleX = Math.abs(image.scaleX);
				image.x -= WIDTH;
			}
		}
	}

	public function isStunned() : Bool
	{	return stunLength > 0;}

	override private function move()
	{
		if(isStunned())
		{
			vel.x *= 0.95;
			--stunLength;
		}
		else
		{
			switch(curDir)
			{
				case LEFT:
					vel.x = -speed;
					setDir(true);
					if(onPlatform() && !image.is(WALK))
						image.setAnimation(WALK);
				case RIGHT:
					vel.x = speed;
					setDir(false);
					if(onPlatform() && !image.is(WALK))
						image.setAnimation(WALK);
				default:
					vel.x = 0;
					if(onPlatform() && !image.is(STAND))
						image.setAnimation(STAND);
			}
			if(curDir != NONE) lastDir = curDir;
			if(!onPlatform() && !image.is(FALL) && vel.y > 0)
			image.setAnimation(FALL);
		}

		lastPos.x = x; lastPos.y = y;
		lastRect.x = curRect.x; lastRect.y = curRect.y;

		x += vel.x; y += vel.y;
		curRect.x = x; curRect.y = y;
		image.animate();
	}

	override public function getRect() : Rectangle
	{	return curRect.union(lastRect);}
}