import starling.textures.Texture;
import starling.display.*;
import starling.text.TextField;
import starling.events.*;
import flash.ui.*;
import bitmasq.*;

enum GameState
{
	Main;
	Options;
	Controls;
	Credits;
	Play;
}

class Menu extends Sprite
{
	private static inline var title = "Title";
	private static inline var credits =
	"Credits\n------------\nTemitope Alaga\nAdd other names later...";

	private var playerNum : UInt;
	private var ctrls : Array<Controller>;
	private var curChoice : UInt;
	private var curButtons : Array<MenuButton>;

	public function new()
	{
		super();

		curChoice = 0;
		curButtons = new Array();
		playerNum = 1;
		ctrls = new Array();
		for(i in 0...4)
		{
			ctrls.push(
			{left : Keyboard.LEFT,
			right : Keyboard.RIGHT,
			down : Keyboard.DOWN,
			up : Keyboard.UP,
			jump : Keyboard.SPACE,
			attack : Keyboard.ENTER,
			gamepadControl : false});
		}
		setMenu(Main);
	}

	private function addInputListeners()
	{
		if(!hasEventListener(KeyboardEvent.KEY_DOWN))
			addEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		if(!hasEventListener(GamepadEvent.CHANGE))
			Gamepad.get().addEventListener(GamepadEvent.CHANGE, gameInput);
	}

	private function removeInputListeners()
	{
		removeEventListener(KeyboardEvent.KEY_DOWN, keyInput);
		Gamepad.get().removeEventListener(GamepadEvent.CHANGE, gameInput);
	}

	private function setMenu(gs : GameState)
	{
		while(curButtons.length > 0)curButtons.pop();
		removeChildren();
		curChoice = 0;
		addInputListeners();
		switch(gs)
		{
			case Main:
				var t = new MenuText(100,100,title);
				t.y = Startup.stageHeight(0.1);
				addChild(t);

				var py = new MenuButton(100,100,"Play",
				function() {setMenu(Play);});
				py.y = Startup.stageHeight(0.25);
				curButtons.push(py);
				addChild(py);

				var op = new MenuButton(100,100,"Options",
				function() {setMenu(Options);});
				op.y = Startup.stageHeight(0.35);
				curButtons.push(op);
				addChild(op);

				var cred = new MenuButton(100,100,"Credits",
				function() {setMenu(Credits);});
				cred.y = Startup.stageHeight(0.45);
				curButtons.push(cred);
				addChild(cred);

			case Options:
				var t = new MenuText(100,100, "Options");
				addChild(t);

				var b = new MenuButton(100,100, "Back", reset);
				b.y = Startup.stageHeight(0.25);
				curButtons.push(b);
				addChild(b);

			case Credits:
				var t = new MenuText(300,200,credits);
				addChild(t);

				var b = new MenuButton(100,100, "Back", reset);
				b.y = Startup.stageHeight(0.25);
				curButtons.push(b);
				addChild(b);

			case Play:
				removeInputListeners();
				makeTestLevel();

			default:
				setMenu(Main);
		}
		setButtons();
	}

	public function reset()
	{	setMenu(Main);}

	private function keyInput(e:KeyboardEvent)
	{
		for(controller in ctrls)
		{
			if(e.keyCode == controller.up)
			{
				--curChoice;
				setButtons();
				break;
			}
			else if(e.keyCode == controller.down)
			{
				++curChoice;
				setButtons();
				break;
			}
			else if(e.keyCode == controller.jump)
			{
				confirmChoice();
				break;
			}
		}
	}

	private function gameInput(e:GamepadEvent)
	{
		for(controller in ctrls)
		{
			if(e.value == 1)
			{
				if(e.control == controller.up)
				{
					--curChoice;
					break;
				}
				else if(e.control == controller.down)
				{
					++curChoice;
					break;
				}
				else if(e.control == controller.jump)
				{
					confirmChoice();
					break;
				}
			}
		}
	}

	private function confirmChoice()
	{
		curButtons[curChoice % curButtons.length].action();
	}

	private function setButtons()
	{
		for(i in 0...curButtons.length)
		{
			curButtons[i].fontColor = cast(i,UInt) ==
			curChoice % curButtons.length ? 0xff0000 : 0;
		}
	}

	private function makeTestLevel()
	{
		//make walls
		var walls = new Array<Wall>();
		var wall = new Wall(Startup.stageWidth(), Startup.stageHeight(0.1));
		wall.y = Startup.stageHeight() - wall.height;
		walls.push(wall);

		var wall2 = new Wall(Startup.stageWidth(0.1), Startup.stageHeight());
		wall2.x = -wall2.width;
		walls.push(wall2);

		var wall3 = wall2.clone();
		wall3.x = Startup.stageWidth();
		walls.push(wall3);

		var wall4 = new Wall(100, 200);
		wall4.x = Startup.stageWidth(0.5) - wall4.width/2; wall4.y = wall.y - 200;
		walls.push(wall4);

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

		var players = new Array<Player>();
		for(i in 0...playerNum)
		{
			players[i] = new Player(ctrls[i]);
			players[i].x = Startup.stageWidth(i*0.25);
		}

		addChild(new Level(players, plats, walls));
	}
}

class MenuButton extends Button
{
	public var action : Void->Void;

	public function new(w : UInt = 100, h : UInt = 100, s : String = "", fn: Void->Void)
	{
		super(Texture.empty(w,h), s);

		action = fn;
		fontSize = 20;
		addEventListener(Event.TRIGGERED, fn);
		addEventListener(Event.ADDED, function()
		{	x = Startup.stageWidth(0.5) - w/2;});
	}
}

class MenuText extends TextField
{
	public function new(w : UInt = 100, h : UInt = 100, s : String = "")
	{
		super(w,h,s);
		fontSize = 20;
		addEventListener(Event.ADDED, function()
		{	x = Startup.stageWidth(0.5) - w/2;});
	}
}