import starling.display.*;
import flash.filesystem.*;
import starling.events.*;

enum Animation
{
	STAND;
	JUMP;
	FALL;
	WALK;
	STUN;
	PUNCH1;
}
typedef Anim = {x : Float, y : Float, rot : Float}
class PlayerImage extends Sprite
{
	private var images : Array<Image>;
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
	private static var standAnim : Array<Anim> =
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0},{x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
	{x : 6, y : 30, rot : 0}];

	private static var jumpAnim : Array<Anim> =
	[{x : 30, y : 6, rot : deg2rad(-45)}, {x : 30, y : 58, rot : deg2rad(22.5)},{x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : deg2rad(-45)}, {x : 6, y : 58, rot : deg2rad(22.5)},
	{x : 6, y : 30, rot : 0}];

	private static var fallAnim : Array<Anim> =
	[{x : 30, y : 6, rot : deg2rad(45)}, {x : 30, y : 58, rot : deg2rad(-22.5)}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : deg2rad(45)}, {x : 6, y : 58, rot : deg2rad(-22.5)},
	{x : 6, y : 30, rot : 0}];

	private static var stunAnim : Array<Anim> =
	[{x : 30, y : 6, rot : 0}, {x : 31, y : 52, rot : -0.34906585039886584},
	{x : 50, y : -3, rot : -0.6981317007977318}, {x : 18, y : 29, rot : 0},
	{x : 6, y : 6, rot : 0}, {x : 11, y : 53, rot : -0.34906585039886584},
	{x : -12, y : -2, rot : -2.268928027592628}];

	private static var walkAnim : Array<Array<Anim>> = [
	//0
	[{x : 30, y : 6, rot : 0}, {x : 37, y : 47, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
	{x : 6, y : 30, rot : 0}],

	//1
	[{x : 30, y : 6, rot : 0}, {x : 44, y : 45, rot : -0.6981317007977318}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : -3, y : 48, rot : 0.6981317007977318},
	{x : 6, y : 30, rot : 0}],

	//2
	[{x : 30, y : 6, rot : 0}, {x : 19, y : 58, rot : 5.551115123125783e-17}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 4, y : 48, rot : 1.5707963267948966},
	{x : 6, y : 30, rot : 0}],

	//3
	[{x : 30, y : 6, rot : 0}, {x : 11, y : 58, rot : 5.551115123125783e-17}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 17, y : 48, rot : 1.5707963267948966},
	{x : 6, y : 30, rot : 0}],

	//4
	[{x : 30, y : 6, rot : 0}, {x : 6, y : 58, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 37, y : 47, rot : 0},
	{x : 6, y : 30, rot : 0}],

	//5
	[{x : 30, y : 6, rot : 0}, {x : -3, y : 48, rot : 0.6981317007977318}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 44, y : 45, rot : -0.6981317007977318},
	{x : 6, y : 30, rot : 0}],

	//6
	[{x : 30, y : 6, rot : 0}, {x : 4, y : 48, rot : 1.5707963267948966}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 19, y : 58, rot : 5.551115123125783e-17},
	{x : 6, y : 30, rot : 0}],

	//7
	[{x : 30, y : 6, rot : 0}, {x : 17, y : 48, rot : 1.5707963267948966}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 11, y : 58, rot : 5.551115123125783e-17},
	{x : 6, y : 30, rot : 0}]
	];

	private static var punchAnim1 : Array<Array<Anim>> =
	[

	//0
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 2, y : 54, rot : 0.5235987755982988},
	{x : -4, y : 30, rot : 0}],

	//1
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 2, y : 54, rot : 0.5235987755982988},
	{x : 11, y : 30, rot : 0}],

	//2
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 10, y : 54, rot : 0.5235987755982988},
	{x : 25, y : 30, rot : 0}],

	//3
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 17, y : 58, rot : -5.551115123125783e-17},
	{x : 41, y : 30, rot : 0}],

	//4
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 17, y : 58, rot : -5.551115123125783e-17},
	{x : 56, y : 30, rot : 0}],
	];

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
		setAnim(standAnim);
	}

	public inline static function set(px : Float) : Float
	{	return px / 256;}

	public function setAnimation(a : Animation)
	{
		switch(a)
		{
			case STAND:
				//trace("Set stand animation");
				setAnim(standAnim);
			case WALK:
				//trace("Set walk animation");
				setAnim(walkAnim[0]);
			case JUMP:
				//trace("Set jump animation");
				setAnim(jumpAnim);
			case FALL:
				//trace("Set fall animation");
				setAnim(fallAnim);
			case STUN:
				//trace("Set stun animation");
				setAnim(stunAnim);
			case PUNCH1:
				//trace("set punch animation");
				setAnim(punchAnim1[0]);
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
			images[i].x = a[i].x;
			images[i].y = a[i].y;
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
				if(++curFrame >= cast(walkAnim.length, UInt)) setAnimation(JUMP);
				else setAnim(walkAnim[curFrame]);
			case JUMP:
				setAnimation(FALL);
			case FALL:
				setAnimation(STUN);
			case STUN:
				setAnimation(PUNCH1);
			case PUNCH1:
				if(++curFrame >= cast(punchAnim1.length, UInt)) setAnimation(STAND);
				else setAnim(punchAnim1[curFrame]);
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
					setAnim(walkAnim[++curFrame % walkAnim.length]);
			case PUNCH1:
				if(frameCount % 3 == 0)
					setAnim(punchAnim1[++curFrame % punchAnim1.length]);
			case STUN:
				images[0].rotation += deg2rad(30);
				images[4].rotation += deg2rad(30);
			default:
		}
	}

	public inline function get(c:UInt) : Image
	{	return images[c % 7];}

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