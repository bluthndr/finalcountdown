import starling.display.*;
import starling.text.TextField;
import starling.events.*;
import flash.ui.*;

class Level extends Sprite
{
	private var sprites : Array<GameSprite>;
	private var level : LevelGeom;

	public function new(w : Float, h : Float, sp : Array<GameSprite>,
	plats : Array<Platform>, walls : Array<Wall>, ?lava : Array<Lava>)
	{
		super();

		sprites = sp;
		level = new LevelGeom(w,h,plats,walls,lava);

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, collisionTest);

		//add all children to level
		addChild(level);
		for(ply in sprites) addChild(ply);
		for(ply in sprites) cast(ply, Player).addMeter(this);
		//for(i in 0...numChildren) trace(getChildAt(i));
	}

	private function collisionTest(e:Event)
	{
		for(sprite in sprites)
		{
			sprite.gravity();
			if(!sprite.visible) continue;
			if(!sprite.onPlatform())
			{
				for(platform in level.platforms)
				{
					if(sprite.platformCollision(platform))
						break;
				}
			}
			for(wall in level.walls)
			{	sprite.wallCollision(wall);}
			for(l in level.lava)
			{	sprite.lavaCollision(l);}
		}
	}

	private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				trace(this);
			case Keyboard.F2:
				for(player in sprites)
				{
					try
					{cast(player,Player).reset();}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.F3:
				for(player in sprites)
				{
					try{cast(player,Player).toggleBound();}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.F4:
				for(player in sprites)
				{
					try{cast(player,Player).kill();}
					catch(d:Dynamic){continue;}
				}
			case Keyboard.ESCAPE:
				cast(parent, Game).reset();
		}
	}

	public function addLimbs(limbs : Array<PlayerLimb>)
	{
		for(limb in limbs)
		{
			sprites.push(limb);
			addChild(limb);
		}
		//trace("Add limbs");
	}

	public function remove(sp : GameSprite)
	{
		//trace("Remove limb");
		sprites.remove(sp);
		removeChild(sp);
	}

	public function toString() : String
	{
		var s = "";
		s += Std.string(level) + "\n";
		for(sprite in sprites) s += Std.string(sprite) + "\n";
		return s;
	}
}

class LevelGeom extends Sprite
{
	public var platforms : Array<Platform>;
	public var walls : Array<Wall>;
	public var lava : Array<Lava>;

	public function new(wd : Float, h : Float, p : Array<Platform>,
							w : Array<Wall>, ?lv : Array<Lava>)
	{
		super();

		walls = w;
		addBoundWalls(wd,h);
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

	private function addBoundWalls(w : Float, h : Float)
	{
		var wall = new Wall(w, Startup.stageHeight(0.1));
		wall.y = h;

		var wall2 = wall.clone();
		wall2.y = -wall2.height;

		var wall3 = new Wall(Startup.stageWidth(0.1), h);
		wall3.x = -wall3.width;

		var wall4 = wall3.clone();
		wall4.x = w;

		walls.push(wall);
		walls.push(wall2);
		walls.push(wall3);
		walls.push(wall4);
	}
}