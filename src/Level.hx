import starling.display.*;
import starling.text.TextField;
import starling.events.*;
import flash.ui.*;

class Level extends Sprite
{
	private var players : Array<Player>;
	private var level : LevelGeom;

	public function new(ply : Array<Player>, plats : Array<Platform>,
	walls : Array<Wall>, ?lava : Array<Lava>)
	{
		super();

		players = ply;
		level = new LevelGeom(plats,walls,lava);

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, collisionTest);

		//add all children to level
		addChild(level);
		for(ply in players) addChild(ply);
		for(ply in players) ply.addMeter(this);
		//for(i in 0...numChildren) trace(getChildAt(i));
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
			for(l in level.lava)
			{	player.lavaCollision(l);}
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
				for(player in players)
					player.toggleBound();
			case Keyboard.F4:
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
	public var lava : Array<Lava>;

	public function new(p : Array<Platform>, w : Array<Wall>, ?lv : Array<Lava>)
	{
		super();

		walls = w;
		for(wall in walls) addChild(wall);

		platforms = p;
		for(plat in platforms) addChild(plat);

		lava = lv;
		for(l in lava) addChild(l);
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