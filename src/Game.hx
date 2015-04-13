import starling.display.*;
import starling.events.*;
import flash.ui.*;
import bitmasq.*;
import flash.geom.Point;

class Game extends Sprite
{
	private static inline var title = "Game";
	private static inline var credits =
	"Credits\n------------\nTemitope Alaga\nAdd other names later...";

	private var panels : Array<PlayerPanel>;
	private var changer : PlayerPanel;

	public static var game : Game;

	public function new()
	{
		super();
		game = this;
		panels = new Array();
		for(i in 0...4)
		{
			var panel = new PlayerPanel(i);
			panel.x = Startup.stageWidth(i*0.25);
			panel.y = Startup.stageHeight(0.25);
			panels.push(panel);
		}
		setMenu();
	}

	private function addInputListeners()
	{
		if(!hasEventListener(KeyboardEvent.KEY_DOWN))
			addEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		if(!hasEventListener(GamepadEvent.CHANGE))
			Gamepad.get().addEventListener(GamepadEvent.CHANGE, gameInput);
		if(!hasEventListener(PlayerPanel.READY))
			addEventListener(PlayerPanel.READY, checkReady);
	}

	private function removeInputListeners()
	{
		removeEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		Gamepad.get().removeEventListener(GamepadEvent.CHANGE, gameInput);
		removeEventListener(PlayerPanel.READY, checkReady);
	}

	public function checkReady()
	{
		var ready = true;
		for(p in panels)
		{
			if(p.isHuman() && !p.isReady())
			{
				ready = false;
				break;
			}
		}
		if(ready)
		{
			removeInputListeners();
			removeChildren();
			makeTestLevel();
		}
	}

	public function reset()
	{
		for(panel in panels)
			panel.reset();
		setMenu();
	}

	public function setMenu()
	{
		removeChildren();
		addInputListeners();
		for(panel in panels) addChild(panel);
		var t = new GameText(title.length*50,100,title);
		t.x = Startup.stageWidth(0.5) - t.width/2;
		t.fontSize = 50;
		addChild(t);
	}

	private function keyInput(e:KeyboardEvent)
	{
		if(changer == null)
		{
			for(panel in panels)
			{ panel.checkKeyInput(e.keyCode);}
		}
		else changer.checkKeyInput(e.keyCode);
	}

	private function gameInput(e:GamepadEvent)
	{
		//trace("Gamepad event", e.value, e.deviceIndex);
		if(e.value == 1)
		{
			if(changer == null)
			{
				for(panel in panels)
				{panel.checkPadInput(e);}
			}
			else changer.checkPadInput(e);
		}
	}

	public function canChange(panel : PlayerPanel) : Bool
	{
		for(p in panels)
		{
			if(p != panel && p.isHuman()
			&& p.isChangingCtrls())
			{
				return false;
				break;
			}
		}
		changer = panel;
		return true;
	}

	public function stopChange()
	{	changer = null;}

	private function makeTestLevel()
	{
		//make walls
		var walls = new Array<Wall>();
		var wall = new Wall(100, 200);
		wall.x = Startup.stageWidth(0.5) - wall.width/2;
		wall.y = Startup.stageHeight() - wall.height;
		walls.push(wall);

		var lavas = new Array<Lava>();
		var lava = new Lava(100,50);
		lava.x = wall.x; lava.y = wall.y-50;
		lavas.push(lava);

		//make platforms
		var plats = new Array<Platform>();
		var plat = new Platform(Startup.stageWidth(0.1), Startup.stageHeight(0.05));
		plat.y = wall.y - 100;
		plats.push(plat);

		var plat2 = plat.clone();
		plat2.x = Startup.stageWidth() - plat.width;
		plats.push(plat2);

		var plat3 = plat.clone();
		plat3.x += 150; plat3.y -= 100;
		plats.push(plat3);

		var plat4 = plat2.clone();
		plat4.x -= 150; plat4.y -= 100;
		plats.push(plat4);

		var wall5 = new Wall(Startup.stageWidth(0.1), Startup.stageHeight(0.1));
		wall5.x = plat.x; wall5.y = plat.y - 200;
		walls.push(wall5);

		var wall6 = wall5.clone();
		wall6.x = plat2.x;
		walls.push(wall6);

		addChild(new Level(Startup.stageWidth(2), Startup.stageHeight(),
		[new Point(0,10), new Point(160,10), new Point(Startup.stageWidth()-160,10),
		new Point(Startup.stageWidth()-48,10)],loadPlayers(), plats, walls, lavas));
	}

	private function loadPlayers() : Array<GameSprite>
	{
		var players = new Array<GameSprite>();
		var i = 0;
		for(panel in panels)
		{
			if(panel.isHuman())
			{
				var player = new Player(panel,i);
				players.push(player);
			}
			++i;
		}
		return players;
	}
}