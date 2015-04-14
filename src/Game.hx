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
		t.fontSize = 50; t.color = 0;
		addChild(t);
	}

	private function keyInput(e:KeyboardEvent)
	{
		if(e.keyCode == Keyboard.F1)
		{
			removeInputListeners();
			removeChildren();
			addChild(new Animator());
		}
		else if(changer == null)
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
		//lists
		var lavas = new Array<Lava>();
		var plats = new Array<Platform>();
		var positions = new Array<Point>();
		var levelWidth = Startup.stageWidth(2);
		var levelHeight = Startup.stageHeight(1.1);

		var i : Float = 0; var top = true;
		while(i < levelWidth)
		{
			var plat = new Platform(100,50);
			plat.x = i;
			plat.y = levelHeight * (top ? 0.5 : 0.75);
			top = !top;
			plats.push(plat);
			if(i < levelWidth * 0.4)
				positions.push(new Point(i + 50, 10));
			i += (levelWidth * 0.1);
		}

		addChild(new Level(levelWidth,levelHeight,
		positions,loadPlayers(), plats, null, null, true));
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