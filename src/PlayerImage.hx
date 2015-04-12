import starling.display.*;

enum Animation
{
	STAND;
	JUMP;
	FALL;
	WALK;
	STUN;
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
	private var frame : Int;
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

	public function new(c:UInt)
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
			case STAND, WALK:
				//trace("Set stand/walk animation");
				frame = 39;
				setAnim(standAnim);
			case JUMP:
				//trace("Set jump animation");
				setAnim(jumpAnim);
			case FALL:
				//trace("Set fall animation");
				setAnim(fallAnim);
			case STUN:
				//trace("Set stun animation");
				setAnim(fallAnim);
			default:
				//trace("Set default animation");
		}
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

	public function is(a : Animation) : Bool
	{	return curAnim == a;}

	public function animate()
	{
		++frame;
		switch(curAnim)
		{
			case WALK:
			switch(frame % 40)
			{
				case 0:
					images[1].rotation = deg2rad(-45);
					images[1].x = 30; images[1].y = 40;
					images[5].rotation = deg2rad(45);
					images[5].x = 6; images[5].y = 40;
				case 5, 35:
					images[1].rotation = deg2rad(-22.5);
					images[1].x = 24; images[1].y = 49;
					images[5].rotation = deg2rad(22.5);
					images[5].x = 12; images[5].y = 49;
				case 10, 30:
					images[1].rotation = deg2rad(0);
					images[1].x = 18; images[1].y = 58;
					images[5].rotation = deg2rad(0);
					images[5].x = 18; images[5].y = 58;
				case 15, 25:
					images[5].rotation = deg2rad(-22.5);
					images[5].x = 24; images[5].y = 49;
					images[1].rotation = deg2rad(22.5);
					images[1].x = 12; images[1].y = 49;
				case 20:
					images[5].rotation = deg2rad(-45);
					images[5].x = 30; images[5].y = 40;
					images[1].rotation = deg2rad(45);
					images[1].x = 6; images[1].y = 40;
			}
			case STUN:
				images[0].rotation += deg2rad(30);
				images[4].rotation += deg2rad(30);
			default:
		}
	}
}