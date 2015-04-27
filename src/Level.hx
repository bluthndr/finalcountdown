import starling.display.*;
import starling.events.*;
import flash.ui.*;
import flash.geom.*;

enum GAME_TYPE
{
	STOCK;
	TIME;
}

typedef GameConditions = {type : GAME_TYPE, goal : Float}
class Level extends Sprite
{
	private var sprites : Array<GameSprite>;
	private var players : Array<Player>;
	private var meters : Array<PlayerMeter>;
	private var level : LevelMap;
	private var camera : Camera;
	private var gameTimer : flash.utils.Timer;

	//private var showFPS : Bool;
	//private var frameCount : UInt;
	private var timePassed : Float;
	private var conditions : GameConditions;
	private var bg : Quad;

	private inline static var pregameText =
	"Game will begin in: ";

	private static var defaultCond : GameConditions = {type : TIME, goal : 30000};

	public function new(map : LevelMap, _players : Array<Player>, ?t : GameConditions)
	{
		super();

		players = _players;
		Player.curLevel = this;
		sprites = new Array();
		level = map;
		bg = new Quad(Startup.stageWidth(), Startup.stageHeight(), level.bgColor);
		conditions = t == null ? defaultCond : t;

		camera = new Camera(level.minX, level.minY, map.width, map.height);

		addEventListener(Event.ADDED_TO_STAGE, preGame);

		//showFPS = false;
		//frameCount = 0;
		timePassed = 0;
		meters = new Array();
	}

	private function preGame(e:Event)
	{
		removeEventListener(Event.ADDED_TO_STAGE, preGame);
		addEventListener(Event.ENTER_FRAME, countdown);
		loadSprites();
		var countText = new GameText(200,200,pregameText + "3");
		countText.x = Startup.stageWidth(0.5) - countText.width/2;
		countText.y = Startup.stageHeight(0.5) - countText.height/2;
		countText.name = "Pregame";
		Game.game.addChild(countText);

	}

	private function countdown(e:EnterFrameEvent)
	{
		timePassed += e.passedTime;
		var t = cast(Game.game.getChildByName("Pregame"), GameText);
		t.text = pregameText + Std.string(Math.ceil(-timePassed+3));
		if(timePassed > 3) startgame();
		moveCamera();
	}

	private function startgame()
	{
		Game.game.removeChild(Game.game.getChildByName("Pregame"));
		removeEventListener(Event.ENTER_FRAME, countdown);

		addEventListener(Event.ENTER_FRAME, update);
		if(players.length > 1)
			addEventListener(PlayerDiedEvent.DEATH, updateScore);
		//addEventListener(KeyboardEvent.KEY_UP, debugFunc);
		if(conditions.type == TIME)
		{
			gameTimer = new flash.utils.Timer(conditions.goal, 1);
			gameTimer.start();
			gameTimer.addEventListener(flash.events.TimerEvent.TIMER_COMPLETE, endGame);
		}
	}

	private function loadSprites()
	{
		//add all children to level
		Game.game.addChildAt(bg,0);
		addChild(level);
		for(i in 0...players.length)
		{
			players[i].x = level.spawnPoints[i].x;
			players[i].y = level.spawnPoints[i].y;
			camera.x += players[i].x;
			camera.y += players[i].y;
			addChild(players[i]);
		}

		//for(i in 0...numChildren) trace(getChildAt(i));
	}

	private function update(e:EnterFrameEvent)
	{
		/*if(showFPS)
		{
			timePassed += e.passedTime;
			++frameCount;
			if(timePassed >= 1)
			{
				haxe.Log.clear();
				trace("FPS: " + frameCount);
				frameCount = 0; timePassed = 0;
			}
		}*/

		//movement and collision detection
		for(player in players)
		{
			player.gravity();
			if(player.visible)
			{
				if(player.y < level.minY || player.y >= level.bottom)
				{
					player.kill();
					continue;
				}
				else if(!player.onPlatform())
				{
					for(platform in level.platforms)
					{
						if(player.platformCollision(platform))
							break;
					}
				}
				for(wall in level.walls)
				{	player.wallCollision(wall.getRect(),wall);}
				for(l in level.lava)
				{	player.lavaCollision(l);}
				for(player2 in players)
				{
					if(player != player2)
					{
						if(player.playerCollision(player2))
							break;
					}
				}
			}
		}
		for(sprite in sprites)
		{
			sprite.gravity();
			if(!sprite.onPlatform())
			{
				for(platform in level.platforms)
				{
					if(sprite.platformCollision(platform))
						break;
				}
			}
			for(wall in level.walls)
			{	sprite.wallCollision(wall.getRect(),wall);}
			for(l in level.lava)
			{	sprite.lavaCollision(l);}
		}

		//camera movement
		moveCamera();

		//make sure meters aren't in the way of players
		for(meter in meters)
		{
			var changed = false;
			var point = globalToLocal(new Point(meter.x,meter.y));
			var mRect = new Rectangle(point.x, point.y, meter.width, meter.height);
			for(player in players)
			{
				if(player.getLocalRect().intersects(mRect))
				{
					meter.alpha = 0.5;
					changed = true;
					break;
				}
			}
			if(!changed) meter.alpha = 1.0;
		}
	}

	private function moveCamera()
	{
		//find center between all players
		var avg = new Point();
		var plyNum = 0;
		var positions = new Array<Point>();
		for(player in players)
		{
			if(player.alive())
			{
				avg.x += player.x;
				avg.y += player.y;
				positions.push(new Point(player.x-Player.WIDTH,player.y-Player.HEIGHT));
				positions.push(new Point(player.x+Player.WIDTH*2,player.y+Player.HEIGHT*2));
				++plyNum;
			}
		}
		avg.x /= plyNum;
		avg.y /= plyNum;

		if(plyNum > 0)
		{
			camera.move(avg, positions);

			//move and scale level
			x = Startup.stageWidth(0.5)-(camera.x*camera.scale);
			y = Startup.stageHeight(0.5)-(camera.y*camera.scale);
			scaleX = scaleY = camera.scale;
		}
	}

	private function updateScore(e : PlayerDiedEvent)
	{
		if(e.killer == e.victim || e.killer == null)
		{
			e.victim.updateScore(false);
			if(conditions.type == STOCK && Math.abs(e.victim.getScore()) == conditions.goal)
			{
				removeChild(e.victim);
				players.remove(e.victim);
				meters.remove(e.victim.fatalKill());
				if(players.length <= 1) endGame();
			}
		}
		else
		{
			e.victim.updateScore(false);
			switch(conditions.type)
			{
				case STOCK:
					if(Math.abs(e.victim.getScore()) == conditions.goal)
					{
						removeChild(e.victim);
						players.remove(e.victim);
						meters.remove(e.victim.fatalKill());
						if(players.length <= 1) endGame();
					}
				case TIME:
					e.killer.updateScore(true);
			}
		}
	}

	private function endGame(?e:Dynamic)
	{
		var p = findWinner();
		var g = new GameText(150,100,p != null ? "Player #" + p.playerID + " wins!" : "It's a tie...");
		g.alignPivot();
		g.x = Startup.stageWidth(0.5);
		g.y = Startup.stageHeight(0.5);
		Game.game.addChild(g);
		removeEventListener(PlayerDiedEvent.DEATH, updateScore);
		//showFPS = false;
		timePassed = 0;
		addEventListener(Event.ENTER_FRAME, gameOver);
	}

	private function gameOver(e : EnterFrameEvent)
	{
		timePassed += e.passedTime;
		if(timePassed > 3) Game.game.reset();
	}

	private function findWinner() : Player
	{
		var rval : Player = null;
		switch(conditions.type)
		{
			case STOCK:
				rval = players[0];
			case TIME:
				var highScore = -0xffffff;
				for(player in players)
				{
					if(highScore < player.getScore())
					{
						highScore = player.getScore();
						rval = player;
					}
					else if(highScore == player.getScore())
					{
						rval = null;
						break;
					}
				}
		}
		return rval;
	}

	public function findClosest(p : Player) : Player
	{
		var dist : Float = 0xffffff;
		var rval = null;
		for(player in players)
		{
			if(p != player && player.alive())
			{
				var tempDist = Player.distance(player,p);
				if(tempDist < dist)
				{
					dist = tempDist;
					rval = player;
				}
			}
		}
		return rval;
	}

	/*private function debugFunc(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.F1:
				haxe.Log.clear();
				//trace(this);
			case Keyboard.F2:
				for(i in 0...players.length)
					players[i].reset(level.spawnPoints[i]);
			case Keyboard.F3:
				for(player in players)
					player.toggleBound();
			case Keyboard.F4:
				for(player in players)
					player.kill();
			case Keyboard.F5:
				showFPS = !showFPS;
			case Keyboard.ESCAPE:
				haxe.Log.clear();
				cast(parent, Game).reset();
		}
	}*/

	public function getSpawnPoint(p : Player) : Point
	{
		for(i in 0...players.length)
		{
			if(players[i] == p)
				return level.spawnPoints[i];
		}
		throw "Player isn't in the level...";
	}

	public function addMeter(meter : PlayerMeter)
	{	meters.push(meter);}

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

class Camera
{
	public var x : Float;
	public var y : Float;
	public var scale : Float;
	public var lowBound : Point;
	public var highBound : Point;

	public inline static var cameraMoveSpeed = 10;
	public inline static var cameraScaleSpeed = 0.005;

	public function new(mx : Float, my : Float, w : Float, h : Float)
	{
		scale = 1;
		lowBound = new Point(mx + Startup.stageWidth(0.5), my + Startup.stageHeight(0.5));
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
		if(x < center.x - cameraMoveSpeed*2) x += cameraMoveSpeed;
		else if(x > center.x + cameraMoveSpeed*2) x -= cameraMoveSpeed;
		else x = center.x;
		if(y < center.y - cameraMoveSpeed*2) y += cameraMoveSpeed;
		else if(y > center.y + cameraMoveSpeed*2) y -= cameraMoveSpeed;
		else y = center.y;

		//bound camera
		if(x < lowBound.x) x = lowBound.x;
		else if(x > highBound.x) x = highBound.x;
		if(y < lowBound.y) y = lowBound.y;
		else if(y > highBound.y) y = highBound.y;

		//find scale
		var cond = !allOnScreen(positions);
		if(cond)
		{
			do{scale -= cameraScaleSpeed;}while(!allOnScreen(positions));
		}
		else if(scale < 1)
		{
			scale += cameraScaleSpeed;
			if(!allOnScreen(positions)) scale -= cameraScaleSpeed;
		}
	}
}