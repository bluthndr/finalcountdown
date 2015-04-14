import starling.events.*;
import starling.display.*;
import flash.geom.*;
import bitmasq.*;
import PlayerAttributes;

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
	private var jumpHeld : Bool;
	private var attHeld : Bool;
	private var color : UInt;
	private var stunLength : Int;
	private var ivLength : Int;
	private var meter : PlayerMeter;
	private var dead : Bool;
	private var respawn : Int;
	private var jumpHeight : Float;
	private var attacking : Bool;

	public static inline var WIDTH = 48;
	public static inline var HEIGHT = 64;

	private static inline var lavaKnockback = 1.5;
	private static inline var lavaStun = 120;

	public static inline var END_ATTACK = "EndAttack";

	public static var lgPunch : AttackProperties =
	{knockback : new Point(0.75,-0.01), damage : 2, stun : 90};
	public static var hgPunch : AttackProperties =
	{knockback : new Point(1.5, -0.05), damage : 5, stun : 240};

	public function new(p : PlayerPanel, i : UInt = 0)
	{
		super();

		curDir = NONE;
		lastDir = RIGHT;
		stunLength = ivLength = 0;
		controller = p.getCtrls();
		jumpHeld = attHeld = dead = attacking = false;
		charWidth = WIDTH;
		charHeight = HEIGHT;
		color = p.getColor();
		jumpHeight = -30;

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
		addEventListener(END_ATTACK, endAttack);
	}

	public function toggleBound()
	{
		//bound.visible = !bound.visible;
		image.toggleCircles();
	}

	public inline function alive() : Bool
	{	return !dead;}

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
		Game.game.addChild(meter);
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
			else if(e.control == controller.up)
			{
				switch(e.value)
				{
					case 1: jump();
					case 0: endJump();
				}
			}
			else if(e.control == controller.lAtt)
			{
				if(e.value == 1)
				{
					if(!attHeld)
					{
						if(onPlatform()) attack(LG_PUNCH);
						attHeld = true;
					}
				}
				else attHeld = false;
			}
			else if(e.control == controller.hAtt)
			{
				if(e.value == 1)
				{
					if(!attHeld)
					{
						if(onPlatform()) attack(HG_PUNCH);
						attHeld = true;
					}
				}
				else attHeld = false;
			}
		}
	}

	private function keyboardInputDown(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left) curDir = LEFT;
		else if(e.keyCode == controller.right)curDir = RIGHT;
		else if(e.keyCode == controller.up) jump();
		else if(e.keyCode == controller.down) fastFall();
		else if(!attHeld)
		{
			if(e.keyCode == controller.lAtt)
			{
				attHeld = true;
				if(onPlatform()) attack(LG_PUNCH);
			}
			else if(e.keyCode == controller.hAtt)
			{
				attHeld = true;
				if(onPlatform()) attack(HG_PUNCH);
			}
		}
	}

	private function keyboardInputUp(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left){if(curDir == LEFT) curDir = NONE;}
		else if(e.keyCode == controller.right){if(curDir == RIGHT) curDir = NONE;}
		else if(e.keyCode == controller.up) endJump();
		else if(e.keyCode == controller.lAtt || e.keyCode == controller.hAtt) attHeld = false;
	}

	override public function wallCollision(wall : Platform)
	{
		if(this.getRect().intersects(wall.getRect()))
		{
			if(!onPlatform() && vel.y > 0 && lastPos.y <= wall.y - charHeight)
			{
				/*haxe.Log.clear();
				trace("Top Collision!", x, y , wall.x, wall.y);*/
				y = wall.y - charHeight;
				vel.y = 0;
				platOn = wall;
			}
			else if(vel.x >= 0 && lastPos.x <= wall.x - charWidth)
			{
				/*haxe.Log.clear();
				trace("Left Collision!", x, y , wall.x, wall.y);*/
				if(isStunned())
				{
					if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.x *= -1;
					else makeLimbs();
				}
				else
				{
					vel.x = 0;
					x = wall.x - charWidth;
				}
			}
			else if(vel.x <= 0 && lastPos.x >= wall.x + wall.width)
			{
				/*haxe.Log.clear();
				trace("Right Collision!", x, y , wall.x, wall.y);*/
				if(isStunned())
				{
					if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.x *= -1;
					else makeLimbs();
				}
				else
				{
					x = wall.x + wall.width;
					vel.x = 0;
				}
			}
			else if(vel.y < 0 && lastPos.y >= wall.y + wall.height)
			{
				/*haxe.Log.clear();
				trace("Bottom Collision!", x, y , wall.x, wall.y);*/
				if(isStunned())
				{
					if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.y *= -1;
					else makeLimbs();
				}
				else
				{
					y = wall.y + wall.height;
					vel.y = 0;
				}
			}
		}
	}

	override public function lavaCollision(lava : Lava)
	{
		if(this.getRect().intersects(lava.getRect()))
		{
			if(!onPlatform() && vel.y > 0 && lastPos.y <= lava.y - charHeight)
			{
				var stun = meter.takeDamage(10,lavaStun);
				if(!isStunned()) stunLength = stun;
				vel.y = -lavaKnockback * meter.getDamage();
				image.setAnimation(STUN);
				endAttack();
			}
			else if(vel.x >= 0 && lastPos.x <= lava.x - charWidth)
			{
				var stun = meter.takeDamage(10,lavaStun);
				if(!isStunned()) stunLength = stun;
				vel.x = -lavaKnockback * meter.getDamage();
				image.setAnimation(STUN);
				endAttack();
			}
			else if(vel.x <= 0 && lastPos.x >= lava.x + lava.width)
			{
				var stun = meter.takeDamage(10,lavaStun);
				if(!isStunned()) stunLength = stun;
				vel.x = lavaKnockback * meter.getDamage();
				image.setAnimation(STUN);
				endAttack();
			}
			else if(vel.y < 0 && lastPos.y >= lava.y + lava.height)
			{
				var stun = meter.takeDamage(10,lavaStun);
				if(!isStunned()) stunLength = stun;
				vel.y = lavaKnockback * meter.getDamage();
				image.setAnimation(STUN);
				endAttack();
			}
		}
	}

	public function playerCollision(attacker : Player) : Bool
	{
		if(ivLength > 0) return false;
		var body = image.getCircle(3);
		for(attack in attacker.image.getAttacks())
		{
			if(body.intersects(attack.area))
			{
				var att = switch(attack.type)
				{
					case LG_PUNCH: lgPunch;
					case HG_PUNCH: hgPunch;
					default: {damage : 0.0, knockback : new Point(), stun : 0};
				};
				if(!isStunned())
					stunLength = meter.takeDamage(att.damage, att.stun);
				vel.x = att.knockback.x * meter.getDamage();
				if(attacker.image.scaleX < 0) vel.x *= -1;
				vel.y = att.knockback.y * meter.getDamage();
				while(magnitude() < 900) {vel.x *= 1.1; vel.y *= 1.1;}
				image.setAnimation(STUN);
				endAttack();
				ivLength = 5;
				return true;
			}
		}
		return false;
	}

	private function makeLimbs()
	{
		trace("Died at the speed: " + magnitude());
		var limbs = new Array<PlayerLimb>();

		var rightEye = new PlayerLimb("eye", PlayerImage.deg2rad(120));
		rightEye.setScale(24,24);
		rightEye.x = 24 + x; rightEye.y = y;

		var leftEye = new PlayerLimb("eye", PlayerImage.deg2rad(60));
		leftEye.setScale(24,24);
		leftEye.x = x; leftEye.y = y;

		var headShell = new PlayerLimb("crack", PlayerImage.deg2rad(90),true);
		headShell.setScale(WIDTH,HEIGHT/2);
		headShell.setColor(color);
		headShell.x = 12+x; headShell.y = 24+y;

		var bottomShell = new PlayerLimb("crack", PlayerImage.deg2rad(180),false);
		bottomShell.setScale(WIDTH,HEIGHT/2);
		bottomShell.setColor(color);
		bottomShell.x = 12+x; bottomShell.y = 44+y;

		var leftHand = new PlayerLimb("fist", PlayerImage.deg2rad(150));
		leftHand.setScale(24,24);
		leftHand.x = x; leftHand.y = 24+y;

		var rightHand = new PlayerLimb("fist", PlayerImage.deg2rad(30));
		rightHand.setScale(24,24);
		rightHand.x = 28+x; rightHand.y = 24+y;

		var leftShoe = new PlayerLimb("shoe", PlayerImage.deg2rad(225));
		leftShoe.setScale(24,12);
		leftShoe.x = x; leftShoe.y = 52+y; leftShoe.setColor(PlayerImage.SHOE_COLOR);

		var rightShoe = new PlayerLimb("shoe", PlayerImage.deg2rad(315));
		rightShoe.setScale(24,12);
		rightShoe.x = 24+x; rightShoe.y = 52+y; rightShoe.setColor(PlayerImage.SHOE_COLOR);

		limbs.push(rightEye);
		limbs.push(rightShoe);
		limbs.push(rightHand);
		limbs.push(headShell);
		limbs.push(bottomShell);
		limbs.push(leftEye);
		limbs.push(leftShoe);
		limbs.push(leftHand);
		cast(parent, Level).addLimbs(limbs);
		dead = true; respawn = 240;
		visible = false; platOn = null;
	}

	public function kill()
	{	makeLimbs();}

	private function jump()
	{
		if(!attacking && !isStunned() && !jumpHeld && onPlatform())
		{
			vel.y = jumpHeight;
			platOn = null;
			jumpHeld = true;
			image.setAnimation(JUMP);
		}
	}

	private function endJump()
	{
		if(!attacking && !isStunned() && !onPlatform() && vel.y < 0)
			vel.y = 10 * weight;
		jumpHeld = false;
	}

	private function fastFall()
	{
		if(!isStunned() && !onPlatform() && (!jumpHeld ||
		vel.y < 0) && vel.y < 15){vel.y = 15;}
	}

	private function attack(at : PLAYER_ATTACK)
	{
		switch(at)
		{
			case LG_PUNCH:
				attacking = true;
				image.setAnimation(LGP);
				vel.x = vel.y = 0;
			case HG_PUNCH:
				attacking = true;
				image.setAnimation(HGP);
				vel.x = vel.y = 0;
			default:
		}
	}

	private inline function endAttack()
	{	attacking = false;}

	public function reset(p : Point)
	{
		x = curRect.x = lastRect.x = lastPos.x = p.x;
		y = curRect.y = lastRect.y = lastPos.y = p.y;
		vel.x = vel.y = stunLength = 0;
		visible = true; meter.reset();
		dead = attacking = false; platOn = null;
	}

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
		if(dead)
		{
			if(--respawn <= 0) reset(cast(parent,Level).getSpawnPoint(this));
			return;
		}
		else if(isStunned())
		{
			vel.x *= 0.8;
			--stunLength;
		}
		else if(!attacking)
		{
			switch(curDir)
			{
				case LEFT:
					if(vel.x < -speed*2) vel.x *= 0.8;
					else
					{
						vel.x = -speed;
						setDir(true);
						if(onPlatform() && !image.is(WALK))
							image.setAnimation(WALK);
					}
				case RIGHT:
					if(vel.x > speed*2) vel.x *= 0.8;
					else
					{
						vel.x = speed;
						setDir(false);
						if(onPlatform() && !image.is(WALK))
							image.setAnimation(WALK);
					}
				default:
					if(Math.abs(vel.x) > speed*2) vel.x *= 0.8;
					else
					{
						vel.x = 0;
						if(onPlatform() && !image.is(STAND))
							image.setAnimation(STAND);
					}
			}
			if(curDir != NONE) lastDir = curDir;
			if(!onPlatform() && !image.is(FALL) && vel.y > 0)
			image.setAnimation(FALL);
		}

		super.move();
		image.animate();
		if(ivLength > 0) --ivLength;
	}

	public function toString() : String
	{
		var s =  Std.string(getPosition()) + " " + Std.string(vel)
		+ " " + curDir + " " + dead + " " + isStunned() + "\n";
		for(i in 0...numChildren) s += Std.string(getChildAt(i)) + "\n";
		return s;
	}
}