import starling.display.*;
import starling.events.*;
import flash.ui.*;
import flash.geom.*;

class Level extends Sprite
{
	private var sprites : Array<GameSprite>;
	private var level : LevelGeom;
	private var spawnPoints : Array<Point>;
	private var camera : Camera;

	public function new(w : Float, h : Float, pos : Array<Point>, sp : Array<GameSprite>,
	plats : Array<Platform>, walls : Array<Wall>, ?lava : Array<Lava>)
	{
		super();

		if(w < Startup.stageWidth()) w = Startup.stageWidth();
		if(h < Startup.stageHeight()) h = Startup.stageHeight();
		camera = new Camera(w,h);

		spawnPoints = pos;
		sprites = sp;
		level = new LevelGeom(w,h,plats,walls,lava);

		addEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(KeyboardEvent.KEY_UP, debugFunc);
	}

	private function addHandler(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, addHandler);
		addEventListener(Event.ENTER_FRAME, update);

		//add all children to level
		addChild(level);
		for(i in 0...sprites.length)
		{
			sprites[i].x = spawnPoints[i].x;
			sprites[i].y = spawnPoints[i].y;
			camera.x += sprites[i].x;
			camera.y += sprites[i].y;
			addChild(sprites[i]);
		}
		moveCamera();
		//for(i in 0...numChildren) trace(getChildAt(i));
	}

	private function update(e:Event)
	{
		//movement and collision detection
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

		//camera movement
		moveCamera();
	}

	private function moveCamera()
	{
		//find center between all players
		var avg = new Point();
		var plyNum = 0;
		var positions = new Array<Point>();
		for(sprite in sprites)
		{
			try
			{
				var ply = cast(sprite, Player);
				if(ply.alive())
				{
					avg.x += sprite.x;
					avg.y += sprite.y;
					positions.push(new Point(sprite.x-Player.WIDTH,sprite.y-Player.HEIGHT));
					positions.push(new Point(sprite.x+Player.WIDTH*2,sprite.y+Player.HEIGHT*2));
					++plyNum;
				}
			}
			catch(d:Dynamic) continue;
		}
		avg.x /= plyNum;
		avg.y /= plyNum;

		camera.move(avg, positions);

		//move and scale level
		x = Startup.stageWidth(0.5)-(camera.x*camera.scale);
		y = Startup.stageHeight(0.5)-(camera.y*camera.scale);
		scaleX = scaleY = camera.scale;
	}

	private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				//trace(this);
			case Keyboard.F2:
				for(i in 0...sprites.length)
				{
					try
					{cast(sprites[i],Player).reset(spawnPoints[i]);}
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
				haxe.Log.clear();
				cast(parent, Game).reset();
		}
	}

	public function getSpawnPoint(p : Player) : Point
	{
		for(i in 0...sprites.length)
		{
			if(sprites[i] == p)
				return spawnPoints[i];
		}
		throw "Player isn't in the level...";
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
		s += Std.string(level);
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

class Camera
{
	public var x : Float;
	public var y : Float;
	public var scale : Float;
	public var lowBound : Point;
	public var highBound : Point;
	public inline static var cameraSpeed = 10;

	public function new(w : Float, h : Float)
	{
		scale = 1;
		lowBound = new Point(Startup.stageWidth(0.5),Startup.stageHeight(0.5));
		highBound = new Point(w - lowBound.x, h - lowBound.y);
		x = lowBound.x; y = lowBound.y;
	}

	public function getRect() : Rectangle
	{
		var scales = new Point(Startup.stageWidth(1/scale),Startup.stageHeight(1/scale));
		var nx = x - Startup.stageWidth(0.5/scale);
		var ny = y - Startup.stageHeight(0.5/scale);
		return new Rectangle(nx, ny, scales.x, scales.y);
	}

	public function allOnScreen(points : Array<Point>) : Bool
	{
		var rect = getRect();
		for(p in points)
		{
			if(!rect.containsPoint(p))
				return false;
		}
		return true;
	}

	public function move(center : Point, positions : Array<Point>)
	{
		//move camera
		if(x < center.x - cameraSpeed*2) x += cameraSpeed;
		else if(x > center.x + cameraSpeed*2) x -= cameraSpeed;
		if(y < center.y - cameraSpeed*2) y += cameraSpeed;
		else if(y > center.y + cameraSpeed*2) y -= cameraSpeed;

		scale = 1;
		while(!allOnScreen(positions) && scale > 0.01) scale -= 0.01;

		//bound camera
		if(x < lowBound.x) x = lowBound.x;
		else if(x > highBound.x) x = highBound.x;
		if(y < lowBound.y) y = lowBound.y;
		else if(y > highBound.y) y = highBound.y;
	}
}