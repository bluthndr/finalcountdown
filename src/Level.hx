import starling.display.*;
import starling.text.TextField;
import starling.events.*;
import starling.utils.*;
import flash.ui.*;

class Level extends Sprite
{
	private var players : Array<Player>;
	private var meters : Array<Meter>;
	private var level : LevelGeom;

	public function new(ply : Array<Player>, plats : Array<Platform>, walls : Array<Wall>)
	{
		super();

		players = ply;
		meters = new Array();
		level = new LevelGeom(plats,walls);

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, collisionTest);

		//add all children to level
		addChild(level);
		var i = 0;
		for(ply in players)
		{
			meters.push(new Meter(ply,i));
			addChild(ply);
			++i;
		}
		for(m in meters) addChild(m);
	}

	private function collisionTest(e:Event)
	{
		for(player in players)
		{
			player.gravity();
			if(!player.onPlatform())
			{
				for(platform in level.platforms)
				{
					if(player.platformCollision(platform))
						break;
				}
			}
			for(wall in level.walls)
			{	player.wallCollision(wall);}
		}
	}

	private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				for(player in players)
				{
					trace("Position: " + player.getPosition(),
					"Velocity: " + player.getVelocity());
				}
			case Keyboard.F2:
				for(player in players)
					player.reset();
			case Keyboard.F3:
				haxe.Log.clear();
				trace(level);
			case Keyboard.ESCAPE:
				cast(parent, Game).reset();
		}
	}
}

class LevelGeom extends Sprite
{
	public var platforms : Array<Platform>;
	public var walls : Array<Wall>;

	public function new(p : Array<Platform>, w : Array<Wall>)
	{
		super();

		walls = w;
		for(wall in walls) addChild(wall);

		platforms = p;
		for(plat in platforms) addChild(plat);
		addEventListener(Event.ADDED, addHandle);
	}

	private function addHandle(e:Event)
	{
		removeEventListener(Event.ADDED,addHandle);
		flatten();
	}

	public function toString() : String
	{
		var s = "";
		for(wall in walls) s += Std.string(wall) + "\n";
		for(platform in platforms) s += Std.string(platform) + "\n";
		return s;
	}
}

class Meter extends Sprite
{
	private var damage : Float;
	private var output : TextField;
	private var quad : Quad;

	public function new(p : Player, i : UInt)
	{
		super();
		damage = 0;

		var q = new Quad(100,50, p.getColor());
		q.alpha = 0.25;
		addChild(q);

		output = new TextField(100, 50, "0%");
		output.fontSize = 20;
		output.vAlign = VAlign.CENTER;
		output.hAlign = HAlign.CENTER;
		addChild(output);

		x = Startup.stageWidth(0.25*i) + Startup.stageWidth(0.05);
		y = Startup.stageHeight(0.9);
	}

	public function takeDamage(d : Float)
	{
		damage += d;
		output.text = Std.string(damage) + "5";
	}
}