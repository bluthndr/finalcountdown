import starling.display.*;
import flash.filesystem.*;
import starling.events.*;
import PlayerAttributes;

enum Animation
{
	STAND;
	JUMP;
	FALL;
	WALK;
	STUN;

	//punches
	HGP;
	LGP;

	//kicks
	HGK;
	LGK;

	//eyes
	LGE;
	HGE;
}

class PlayerImage extends Sprite
{
	private var images : Array<Image>;
	private var circles : Array<HitCircle>;
	/*
		0-Eyes (right)
		1-Shoes (right)
		2-Fists (right)
		3-Body
		4-Eyes
		5-Shoes
		6-Fists
	*/

	public inline static function deg2rad(deg : Float) : Float
	{	return deg * Math.PI / 180;}

	public static inline var SHOE_COLOR = 0x222222;

	private var curAnim : Animation;
	private var frameCount : UInt;
	private var curFrame : UInt;

	public function new(c:UInt=0xffffff)
	{
		super();

		curAnim = STAND;
		images = new Array();
		images[0] = new Image(Root.assets.getTexture("eye"));
		images[0].scaleX = set(24); images[0].scaleY = set(24);

		images[1] = new Image(Root.assets.getTexture("shoe"));
		images[1].color = SHOE_COLOR;
		images[1].scaleX = set(24); images[1].scaleY = set(12);

		images[2] = new Image(Root.assets.getTexture("fist"));
		images[2].scaleX = set(24); images[2].scaleY = set(24);

		images[3] = new Image(Root.assets.getTexture("body"));
		images[3].scaleX = set(Player.WIDTH);
		images[3].scaleY = set(Player.HEIGHT);
		images[3].color = c;

		images[4] = new Image(Root.assets.getTexture("eye"));
		images[4].scaleX = set(24); images[4].scaleY = set(24);

		images[5] = new Image(Root.assets.getTexture("shoe"));
		images[5].color = SHOE_COLOR;
		images[5].scaleX = set(24); images[5].scaleY = set(12);

		images[6] = new Image(Root.assets.getTexture("fist"));
		images[6].scaleX = set(24); images[6].scaleY = set(24);

		curFrame = frameCount = 0;
		for(im in images)
		{
			im.alignPivot();
			addChild(im);
		}

		//init hit circles
		circles = new Array();
		for(image in images) circles.push(new HitCircle(image));
		for(circle in circles)
		{
			addChild(circle);
			circle.visible = false;
		}
		circles[1].scaleX = circles[1].scaleY = circles[5].scaleX =
		circles[5].scaleY = set(18);
		setAnim(PlayerAnimations.standAnim);
	}

	public inline static function set(px : Float) : Float
	{	return px / 256;}

	public function toggleCircles()
	{
		for(circle in circles)
			circle.visible = !circle.visible;
	}

	public function setAnimation(a : Animation)
	{
		switch(a)
		{
			case STAND:
				//trace("Set stand animation");
				setAnim(PlayerAnimations.standAnim);
			case WALK:
				//trace("Set walk animation");
				setAnim(PlayerAnimations.walkAnim[0]);
			case JUMP:
				//trace("Set jump animation");
				setAnim(PlayerAnimations.jumpAnim);
			case FALL:
				//trace("Set fall animation");
				setAnim(PlayerAnimations.fallAnim);
			case STUN:
				//trace("Set stun animation");
				setAnim(PlayerAnimations.stunAnim);
			case LGP:
				//trace("set light ground punch animation");
				setAnim(PlayerAnimations.lgPunchAnim[0]);
			case HGP:
				//trace("set light ground punch animation");
				setAnim(PlayerAnimations.hgPunchAnim[0]);
			case LGK:
				//trace("set light ground kick animation");
				setAnim(PlayerAnimations.lgKickAnim[0]);
			case HGK:
				//trace("set heavy ground kick animation");
				setAnim(PlayerAnimations.hgKickAnim[0]);
			case LGE:
				//trace("set light ground eye animation");
				setAnim(PlayerAnimations.lgEyeAnim[0]);
			case HGE:
				//trace("set heavy ground eye animation");
				setAnim(PlayerAnimations.hgEyeAnim[0]);
			default:
				//trace("Set default animation");
		}
		curFrame = 0;
		curAnim = a;
	}

	private function setAnim(a : Array<Anim>)
	{
		for(i in 0...images.length)
		{
			circles[i].x = images[i].x = a[i].x;
			circles[i].y = images[i].y = a[i].y;
			images[i].rotation = a[i].rot;
		}
	}

	public function nextAnim()
	{
		switch(curAnim)
		{
			case STAND:
				setAnimation(WALK);
				curFrame = 0;
			case WALK:
				if(++curFrame >= cast(PlayerAnimations.walkAnim.length, UInt)) setAnimation(JUMP);
				else setAnim(PlayerAnimations.walkAnim[curFrame]);
			case JUMP:
				setAnimation(FALL);
			case FALL:
				setAnimation(STUN);
			case STUN:
				setAnimation(LGP);
			case LGP:
				if(++curFrame >= cast(PlayerAnimations.lgPunchAnim.length, UInt)) setAnimation(HGP);
				else setAnim(PlayerAnimations.lgPunchAnim[curFrame]);
			case HGP:
				if(++curFrame >= cast(PlayerAnimations.hgPunchAnim.length, UInt)) setAnimation(LGK);
				else setAnim(PlayerAnimations.hgPunchAnim[curFrame]);
			case LGK:
				if(++curFrame >= cast(PlayerAnimations.lgKickAnim.length, UInt)) setAnimation(HGK);
				else setAnim(PlayerAnimations.lgKickAnim[curFrame]);
			case HGK:
				if(++curFrame >= cast(PlayerAnimations.hgKickAnim.length, UInt)) setAnimation(LGE);
				else setAnim(PlayerAnimations.hgKickAnim[curFrame]);
			case LGE:
				if(++curFrame >= cast(PlayerAnimations.lgEyeAnim.length, UInt)) setAnimation(HGE);
				else setAnim(PlayerAnimations.lgEyeAnim[curFrame]);
			case HGE:
				if(++curFrame >= cast(PlayerAnimations.hgEyeAnim.length, UInt)) setAnimation(STAND);
				else setAnim(PlayerAnimations.hgEyeAnim[curFrame]);
			default:
				setAnimation(STAND);
		}
		trace(curAnim, curFrame);
	}

	public function loopCur()
	{
		if(hasEventListener(Event.ENTER_FRAME))
		{
			removeEventListeners(Event.ENTER_FRAME);
			trace("Stopped loop");
		}
		else
		{
			addEventListener(Event.ENTER_FRAME, animate);
			trace("Looping: ", curAnim);
		}
	}

	public function is(a : Animation) : Bool
	{	return curAnim == a;}

	public function animate()
	{
		++frameCount;
		switch(curAnim)
		{
			case WALK:
				if(frameCount % 6 == 0)
					setAnim(PlayerAnimations.walkAnim[++curFrame % PlayerAnimations.walkAnim.length]);
			case LGP:
				//trace("Animate punch");
				if(frameCount % 2 == 0)
				{
					if(++curFrame < cast(PlayerAnimations.lgPunchAnim.length, UInt))
						setAnim(PlayerAnimations.lgPunchAnim[curFrame % PlayerAnimations.lgPunchAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case HGP:
				if(frameCount % 2 == 0)
				{
					if(++curFrame < cast(PlayerAnimations.hgPunchAnim.length, UInt))
						setAnim(PlayerAnimations.hgPunchAnim[curFrame % PlayerAnimations.hgPunchAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case LGK:
				if(frameCount % 3 == 0)
				{
					if(++curFrame < cast(PlayerAnimations.lgKickAnim.length, UInt))
						setAnim(PlayerAnimations.lgKickAnim[curFrame % PlayerAnimations.lgKickAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case HGK:
				if(frameCount % 3 == 0)
				{
					if(++curFrame < cast(PlayerAnimations.hgKickAnim.length, UInt))
						setAnim(PlayerAnimations.hgKickAnim[curFrame % PlayerAnimations.hgKickAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case LGE:
				if(frameCount % 2 == 0)
				{
					if(++curFrame < cast(PlayerAnimations.lgEyeAnim.length, UInt))
						setAnim(PlayerAnimations.lgEyeAnim[curFrame % PlayerAnimations.lgEyeAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case HGE:
				if(frameCount % 2 == 0)
				{
					if(curFrame == 45) curFrame = 9;
					else if(curFrame == 8) curFrame = 30;
					else if(curFrame >= 30)
					{
						++curFrame;
						//rotate eyes
						images[0].rotation += deg2rad(67.5);
						images[4].rotation += deg2rad(67.5);
					}
					else if(++curFrame < cast(PlayerAnimations.hgEyeAnim.length, UInt))
						setAnim(PlayerAnimations.hgEyeAnim[curFrame % PlayerAnimations.hgEyeAnim.length]);
					else
					{
						//trace("Dispatch event...");
						parent.dispatchEventWith(Player.END_ATTACK);
						if(!hasEventListener(Event.ENTER_FRAME)) setAnimation(STAND);
						else curFrame = 0;
					}
				}
			case STUN:
				images[0].rotation += deg2rad(30);
				images[4].rotation += deg2rad(30);
			default:
		}
	}

	public inline function get(c:UInt) : Image
	{	return images[c % 7];}

	public function getCircle(c:UInt) : HitCircle
	{	return circles[c % 7];}

	public function getAttacks() : Array<Attack>
	{
		return switch(curAnim)
		{
			case LGP:
				if(curFrame >= 4)
					[{area : circles[6], type : LG_PUNCH}];
				else [];
			case HGP:
				if(curFrame >= 9 && curFrame <= 12)
				{
					[{area : circles[2], type : HG_PUNCH},
					{area : circles[6], type : HG_PUNCH}];
				}
				else [];
			case LGK:
				if(curFrame >= 3)
					[{area : circles[5], type : LG_KICK}];
				else [];
			case HGK:
				if(curFrame >= 5 && curFrame <=8)
				{
					[{area : circles[1], type : HG_KICK},
					{area : circles[5], type : HG_KICK}];
				}
				else [];
			case LGE:
				if(curFrame >= 3 && curFrame <= 5)
				{
					[{area : circles[0], type : LG_EYE},
					{area : circles[4], type : LG_EYE}];
				}
				else [];
			case HGE:
				if((curFrame >= 6 && curFrame <= 7) || curFrame >= 30)
				{
					[{area : circles[0], type : HG_EYE},
					{area : circles[4], type : HG_EYE}];
				}
				else [];
			default: [];
		};
	}

	public function save()
	{
		var file = File.desktopDirectory.resolvePath("animations.txt");
		var fout = new FileStream();
		fout.open(file, FileMode.WRITE);

		fout.writeUTFBytes("[");
		for(i in 0...7)
		{
			if(i == 6)
			{
				fout.writeUTFBytes("{x : " + images[i].x + ", y : " + images[i].y +
				", rot : " + images[i].rotation + "}],");
			}
			else
			{
				fout.writeUTFBytes("{x : " + images[i].x + ", y : " + images[i].y +
				", rot : " + images[i].rotation + "}, ");
				if(i % 3 == 2) fout.writeUTFBytes("\n");
			}
		}
		fout.close();
		trace("Saved animation");
	}
}