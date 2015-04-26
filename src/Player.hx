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

	private var curDir : DIRECTION;//direction moving
	private var dirHeld : DIRECTION;//stick/button held
	private var wallDir : DIRECTION;//for wall jumps

	private var controller : Controller;
	private var downHeld : Bool;
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
	public var playerID : UInt;

	private var blockLength : Int;
	private var blockImage : HitCircle;

	public static inline var WIDTH = 48;
	public static inline var HEIGHT = 64;

	private static inline var lavaKnockback = 1.5;
	private static inline var lavaStun = 120;

	public static inline var END_ATTACK = "EndAttack";

	public static var lgPunch : AttackProperties = {damage : 2.5,
	knockback : new Point(0.75,-0.01), stun : 90, ivFrames : 3};
	public static var hgPunch : AttackProperties = {damage : 5,
	knockback : new Point(1.5, -0.05), stun : 240, ivFrames : 10};
	public static var lgKick : AttackProperties = {damage : 3,
	knockback : new Point(0.5, -0.1), stun : 200, ivFrames : 5};
	public static var hgKick : AttackProperties = {damage : 6,
	knockback : new Point(0.75, -0.5), stun : 200, ivFrames : 10};
	public static var lgEye : AttackProperties = {damage : 2,
	knockback : new Point(0.0, -0.65), stun : 120, ivFrames : 10};
	public static var hgEye : AttackProperties = {damage : 7.25,
	knockback : new Point(0.0, -1.0),  stun : 300, ivFrames : 30};
	public static var lAir : AttackProperties = {damage : 1,
	knockback : new Point(0.75, -0.5), stun : 120, ivFrames : 5};
	public static var hAir : AttackProperties = {damage : 10,
	knockback : new Point(0.0, -1.4), stun : 300, ivFrames : 15};

	private var score : Int;
	private var lastHitBy : Player;

	public function new(p : PlayerPanel, i : UInt = 0)
	{
		super();

		curDir = dirHeld = wallDir = NONE;
		stunLength = ivLength = blockLength = 0;
		controller = p.getCtrls();
		jumpHeld = attHeld = downHeld =
		dead = attacking = false;
		charWidth = WIDTH;
		charHeight = HEIGHT;
		color = p.getColor();
		jumpHeight = -30;

		meter = new PlayerMeter(this, i++);
		playerID = i;
		image = new PlayerImage(color);
		addChild(image);

		bound = new Quad(WIDTH,HEIGHT,color);
		bound.alpha = 0.5;
		bound.visible = false;
		addChild(bound);

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
		curRect = new Rectangle(x,y,WIDTH,HEIGHT);
		lastRect = curRect.clone();
		cast(parent, Level).addMeter(meter);
		Game.game.addChild(meter);

		blockImage = new HitCircle();
		blockImage.color = color;
		blockImage.scaleX = PlayerImage.set(WIDTH);
		blockImage.scaleY = PlayerImage.set(HEIGHT);
		blockImage.visible = false;
		blockImage.alpha = 0.9;
		blockImage.x = -9;
		addChild(blockImage);
	}

	private function gamepadInput(e:GamepadEvent)
	{
		if(e.deviceIndex == controller.padID)
		{
			if(e.control == controller.left)
			{
				switch(e.value)
				{
					case 1: dirHeld = LEFT;
					case 0: if(dirHeld == LEFT) dirHeld = NONE;
				}
			}
			else if(e.control == controller.right)
			{
				switch(e.value)
				{
					case 1: dirHeld = RIGHT;
					case 0: if(dirHeld == RIGHT) dirHeld = NONE;
				}
			}
			else if(e.control == controller.down)
			{
				switch(e.value)
				{
					case 1:
						downHeld = true;
						fastFall();
					case 0:
						downHeld = false;
				}
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
						if(onPlatform())
						{
							if(downHeld) attack(dirHeld != NONE ? LG_KICK : LG_EYE);
							else attack(LG_PUNCH);
						}
						else if(!downHeld) attack(L_AIR);
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
						if(onPlatform())
						{
							if(downHeld) attack(dirHeld != NONE ? HG_KICK : HG_EYE);
							else attack(HG_PUNCH);
						}
						else if(!downHeld) attack(H_AIR);
						attHeld = true;
					}
				}
				else attHeld = false;
			}
		}
	}

	private function keyboardInputDown(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left) dirHeld = LEFT;
		else if(e.keyCode == controller.right) dirHeld = RIGHT;
		else if(e.keyCode == controller.up) jump();
		else if(!downHeld && e.keyCode == controller.down)
		{
			downHeld = true;
			fastFall();
		}
		else if(!attHeld)
		{
			if(e.keyCode == controller.lAtt)
			{
				attHeld = true;
				if(onPlatform())
				{
					if(downHeld) attack(dirHeld != NONE ? LG_KICK : LG_EYE);
					else attack(LG_PUNCH);
				}
				else if(!downHeld) attack(L_AIR);
			}
			else if(e.keyCode == controller.hAtt)
			{
				attHeld = true;
				if(onPlatform())
				{
					if(downHeld) attack(dirHeld != NONE ? HG_KICK : HG_EYE);
					else attack(HG_PUNCH);
				}
				else if(!downHeld) attack(H_AIR);
			}
		}
	}

	private function keyboardInputUp(e:KeyboardEvent)
	{
		if(e.keyCode == controller.left) {if(dirHeld == LEFT) dirHeld = NONE;}
		else if(e.keyCode == controller.right) {if(dirHeld == RIGHT) dirHeld = NONE;}
		else if(e.keyCode == controller.up) endJump();
		else if(e.keyCode == controller.down) downHeld = false;
		else if(e.keyCode == controller.lAtt || e.keyCode == controller.hAtt) attHeld = false;
	}

	override public function platformCollision(plat : Platform) : Bool
	{
		if(image.is(STICK) || image.is(WALL_JUMP) || image.is(LA) || image.is(HA))
		{
			var rval = super.platformCollision(plat);
			if(rval)
			{
				image.setAnimation(STAND);
				vel.x = 0;
				endAttack();
			}
			return rval;
		}
		else return super.platformCollision(plat);
	}

	override public function wallCollision(wall : Rectangle, ?sp : Platform)
	{
		if(this.getRect().intersects(wall))
		{
			if(image.is(WALL_JUMP))
			{
				if(vel.y > 0) image.setAnimation(FALL);
				else image.setAnimation(JUMP);
			}

			if(lastRect.y <= wall.y - charHeight)
			{
				if(!onPlatform() && vel.y > 0)
				{
					if(isStunned() && magnitude() > GameSprite.HIGH_BOUNCE_BOUND)
						kill();
					else
					{
						y = wall.y - charHeight;
						vel.y = 0;
						if(sp != null) platOn = sp;
						if(image.is(STICK) || image.is(WALL_JUMP) ||
						image.is(LA) || image.is(HA))
						{
							image.setAnimation(STAND);
							vel.x = 0;
							endAttack();
						}
					}
				}
			}
			else if(lastRect.y >= wall.y + wall.height)
			{
				if(vel.y < 0)
				{
					/*haxe.Log.clear();
					trace("Bottom Collision!", x, y , wall.x, wall.y);*/
					if(isStunned())
					{
						if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.y *= -1;
						else kill();
					}
					else
					{
						y = wall.y + wall.height;
						vel.y = 0;
					}
				}
			}
			else
			{
				//var centerX = wall.x + wall.width/2;
				if(vel.x >= 0 && lastRect.x <= wall.x)
				{
					/*haxe.Log.clear();
					trace("Left Collision!", x, y , wall.x, wall.y);*/
					if(isStunned())
					{
						if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.x *= -1;
						else kill();
					}
					else
					{
						vel.x = 0;
						x = wall.x - charWidth;
						wallDir = LEFT;
					}
				}
				else if(vel.x <= 0 && lastRect.x > wall.x)
				{
					/*haxe.Log.clear();
					trace("Right Collision!", x, y , wall.x, wall.y);*/
					if(isStunned())
					{
						if(magnitude() <= GameSprite.HIGH_BOUNCE_BOUND) vel.x *= -1;
						else kill();
					}
					else
					{
						x = wall.x + wall.width;
						vel.x = 0;
						wallDir = RIGHT;
					}
				}
			}
		}
	}

	override public function lavaCollision(lava : Lava)
	{
		if(this.getRect().intersects(lava.getRect()))
		{
			if(lastRect.y <= lava.y - charHeight)
			{
				if(!onPlatform() && vel.y > 0)
				{
					SFX.play("lava");
					var stun = meter.takeDamage(10,lavaStun);
					if(!isStunned()) stunLength = stun;
					y = lava.y - charHeight;
					vel.y = -lavaKnockback * meter.getDamage();
					image.setAnimation(STUN);
					endAttack();
				}
			}
			else if(lastRect.y >= lava.y + lava.height)
			{
				if(vel.y < 0)
				{
					SFX.play("lava");
					var stun = meter.takeDamage(10,lavaStun);
					if(!isStunned()) stunLength = stun;
					vel.y = lavaKnockback * meter.getDamage();
					image.setAnimation(STUN);
					endAttack();
				}
			}
			else
			{
				if(vel.x >= 0 && lastRect.x <= lava.x)
				{
					SFX.play("lava");
					var stun = meter.takeDamage(10,lavaStun);
					if(!isStunned()) stunLength = stun;
					vel.x = -lavaKnockback * meter.getDamage();
					image.setAnimation(STUN);
					endAttack();
				}
				else if(vel.x <= 0 && lastRect.x > lava.x)
				{
					SFX.play("lava");
					var stun = meter.takeDamage(10,lavaStun);
					if(!isStunned()) stunLength = stun;
					vel.x = lavaKnockback * meter.getDamage();
					image.setAnimation(STUN);
					endAttack();
				}
			}
		}
	}

	private function attackCollision(attacker : Player) : Bool
	{
		//attacks
		if(ivLength > 0) return false;
		var body = image.getCircle(3);
		for(attack in attacker.image.getAttacks())
		{
			if(body.intersects(attack.area))
			{
				var damage = switch(attack.type)
				{
					case LG_PUNCH: lgPunch;
					case HG_PUNCH: hgPunch;
					case LG_KICK: lgKick;
					case HG_KICK: hgKick;
					case LG_EYE: lgEye;
					case HG_EYE: hgEye;
					case L_AIR: lAir;
					case H_AIR: hAir;
				};
				if(isBlocking()) attacker.takeDamage(damage, attacker.image.scaleX > 0);
				else takeDamage(damage, attacker.image.scaleX < 0);
				lastHitBy = attacker;
				return true;
			}
		}
		return false;
	}

	public function playerCollision(attacker : Player) : Bool
	{
		if(attacker.alive())
		{
			if(!isStunned() && this.getRect().intersects(attacker.getRect()))
			{
				if(lastRect.y <= attacker.y - charHeight)
				{
					if(!onPlatform() && vel.y > 0)
					{
						vel.y = jumpHeight;
						image.setAnimation(JUMP);
						endAttack();
						attacker.vel.y = 0;
					}
				}
				else
				{
					if(x < attacker.x)
					{
						if(wallDir != RIGHT) --x;
						if(attacker.wallDir != LEFT) ++attacker.x;
					}
					else
					{
						if(wallDir != RIGHT) ++x;
						if(attacker.wallDir != LEFT) --attacker.x;
					}
				}
			}
			return attackCollision(attacker);
		}
		return false;
	}

	private function makeLimbs()
	{
		//trace("Died at the speed: " + magnitude());
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
		dead = true; respawn = 180;
		visible = false; platOn = null;
	}

	public function kill()
	{
		makeLimbs();
		parent.dispatchEvent(new PlayerDiedEvent(this,lastHitBy));
	}

	public function fatalKill() : PlayerMeter
	{
		Game.game.removeChild(meter);
		return meter;
	}

	public function updateScore(addScore : Bool)
	{
		if(addScore) ++score;
		else --score;
		meter.updateText(score);
	}

	private function notOpposite(a : DIRECTION, b : DIRECTION) : Bool
	{
		if(a == LEFT) return b != RIGHT;
		else if(a == RIGHT) return b != LEFT;
		else return false;
	}

	private function jump()
	{
		if(!attacking && !isStunned() && !jumpHeld)
		{
			if(image.is(STICK) && notOpposite(wallDir, dirHeld))
			{
				vel.x = speed * (wallDir == LEFT ? -1 : 1);
				vel.y = jumpHeight * 1.25;
				platOn = null;
				jumpHeld = true;
				image.setAnimation(WALL_JUMP);
			}
			else if(onPlatform())
			{
				if(downHeld)
				{
					//trace("Block?", canBlock());
					if(canBlock())
					{
						blockLength = 72;
						blockImage.visible = true;
						image.setAnimation(GUARD);
					}
				}
				else
				{
					vel.y = jumpHeight;
					platOn = null;
					jumpHeld = true;
					image.setAnimation(JUMP);
				}
			}
			else if(!image.is(STICK) && wallDir != NONE)
			{
				vel.y = 0;
				jumpHeld = true;
				//if flipped, then unflip
				if(image.x > 0)
				{
					image.x = 0;
					image.scaleX = Math.abs(image.scaleX);
				}
				//if not flipped, then flip
				else
				{
					image.x = WIDTH;
					image.scaleX = Math.abs(image.scaleX) * -1;
				}
				image.setAnimation(STICK);
			}
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
		if(!attacking && !isStunned() && !image.is(STICK) &&
		!onPlatform() && (!jumpHeld || vel.y < 0) && vel.y < 15)
		{vel.y = 15;}
	}

	private function attack(at : PLAYER_ATTACK)
	{
		if(isBlocking()) return;
		var p_att : Animation = switch(at)
		{
			case LG_PUNCH:LGP;
			case HG_PUNCH:HGP;
			case LG_KICK: LGK;
			case HG_KICK: HGK;
			case LG_EYE: LGE;
			case HG_EYE: HGE;
			case L_AIR: LA;
			case H_AIR: HA;
		}
		if(p_att != null)
		{
			if(attacking) image.reattack(p_att);
			else image.setAnimation(p_att);
			attacking = true;
			if(p_att != LA && p_att != HA)
				vel.x = vel.y = 0;
		}
	}

	private inline function endAttack()
	{	attacking = false;}

	public function reset(p : Point)
	{
		x = curRect.x = lastRect.x = p.x;
		y = curRect.y = lastRect.y = p.y;
		vel.x = vel.y = stunLength = blockLength = 0;
		visible = true; meter.reset();
		dead = attacking = false; platOn = null;
	}

	public inline function getColor() : UInt
	{	return color;}

	private function setDir()
	{
		if(dirHeld == LEFT)
		{
			image.scaleX = Math.abs(image.scaleX) * -1;
			image.x = WIDTH;
			blockImage.scaleX = Math.abs(blockImage.scaleX)* -1;
			blockImage.x = WIDTH;
		}
		else if(dirHeld == RIGHT)
		{
			image.scaleX = Math.abs(image.scaleX);
			image.x = 0;
			blockImage.scaleX = Math.abs(blockImage.scaleX);
			blockImage.x = 0;
		}
	}

	public inline function isStunned() : Bool
	{	return stunLength > 0;}

	public inline function canBlock() : Bool
	{	return blockLength <= 0;}

	public inline function isBlocking() : Bool
	{	return blockLength > 60;}

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
			if(stunLength == 1)
			{
				if(magnitude() < 900)
					stunLength = 0;
			}
			else --stunLength;
		}
		else if((!attacking || isBlocking() || image.is(LA) || image.is(HA)) && !image.is(STICK))
		{
			if(image.is(WALL_JUMP))
			{
				if(vel.y > 0)
					image.updateWallJump();
			}
			else if(isBlocking()) --blockLength;
			else
			{
				switch(dirHeld)
				{
					case LEFT:
						if(downHeld) noMovement();
						else if(vel.x < -speed*2) vel.x *= 0.8;
						else
						{
							vel.x = -speed;
							if(onPlatform() && !image.is(WALK))
								image.setAnimation(WALK);
						}
					case RIGHT:
						if(downHeld) noMovement();
						else if(vel.x > speed*2) vel.x *= 0.8;
						else
						{
							vel.x = speed;
							if(onPlatform() && !image.is(WALK))
								image.setAnimation(WALK);
						}
					default:
						noMovement();
				}
				setDir();
				if(onPlatform())
				{
					if(!canBlock())
					{
						if(--blockLength == 59)
						{
							blockImage.visible = false;
							image.setAnimation(STAND);
						}
					}
				}
				else
				{
					if(!attacking && !image.is(FALL) && vel.y > 0)
						image.setAnimation(FALL);
				}
			}
		}

		super.move();
		image.animate();
		if(ivLength > 0) --ivLength;
		if(!image.is(STICK)) wallDir = NONE;
	}

	private function noMovement()
	{
		if(Math.abs(vel.x) > speed*2) vel.x *= 0.8;
		else
		{
			vel.x = 0;
			if(onPlatform() && !image.is(STAND))
				image.setAnimation(STAND);
		}
	}

	private function takeDamage(att : AttackProperties, flipped : Bool)
	{
		var stun = meter.takeDamage(att.damage, att.stun);
		if(!isStunned()) stunLength = stun;
		vel.x = att.knockback.x * meter.getDamage();
		if(flipped) vel.x *= -1;
		vel.y = att.knockback.y * meter.getDamage();
		image.setAnimation(STUN);
		endAttack();
		if(ivLength <= 0) ivLength = att.ivFrames;
	}

	public inline function getScore() : Int
	{	return score;}

	public function toString() : String
	{
		var s =  Std.string(getPosition()) + " " + Std.string(vel)
		+ " " + curDir + " " + dead + " " + isStunned() + "\n";
		for(i in 0...numChildren) s += Std.string(getChildAt(i)) + "\n";
		return s;
	}
}
