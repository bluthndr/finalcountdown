import starling.display.*;
import starling.events.*;
import starling.text.TextField;
import starling.utils.Color;
import bitmasq.*;
import Level;

class LevelSelector extends Sprite
{
	private var cursor : Cursor;
	private var buttons : Array<GameText>;
	private var buttons2 : Array<GameText>;
	private var ctrl : Controller;
	private var conditions : GameConditions;

	public static inline var MAX_LEVELS = 10;

	public function new()
	{
		super();

		var gt = new GameText(Std.int(Startup.stageWidth(0.7)),
		Std.int(Startup.stageHeight(0.2)),"Select a stage");
		gt.fontSize = 50; gt.setColor(0xffffff);
		gt.x = Startup.stageWidth(0.3); addChild(gt);

		buttons = new Array();
		for(i in 0...MAX_LEVELS)
		{
			var t = new GameText(Std.int(Startup.stageWidth(0.25)),
			Std.int(Startup.stageHeight(1/MAX_LEVELS)), GameLevel.getName(i));
			t.y = Startup.stageHeight(i/MAX_LEVELS);
			t.setColor(i % 2 == 0 ? 0xffffaa : 0xffff00);
			buttons.push(t);
			addChild(t);
		}

		buttons2 = new Array();
		var gameType = new GameText(Std.int(Startup.stageWidth(0.35)),
		Std.int(Startup.stageHeight(0.1)), "Game Type: STOCK");
		gameType.x = gt.x; gameType.y = Startup.stageHeight(0.9);
		buttons2.push(gameType);
		addChild(gameType);

		var gameGoal = new GameText(Std.int(Startup.stageWidth(0.35)),
		Std.int(Startup.stageHeight(0.1)), "Lives: 1");
		gameGoal.x = gameType.x + gameType.width; gameGoal.y = gameType.y;
		buttons2.push(gameGoal);
		addChild(gameGoal);

		ctrl = Game.game.getTopCtrls();
		cursor = new Cursor();
		cursor.x = Startup.stageWidth(0.5) - cursor.width;
		cursor.y = Startup.stageHeight(0.5) - cursor.height;
		addChild(cursor);

		conditions = {type : STOCK, goal : 1};

		if(ctrl.gamepad) Gamepad.get().addEventListener(GamepadEvent.CHANGE, padInput);
		else
		{
			addEventListener(KeyboardEvent.KEY_DOWN, keyInput);
			addEventListener(KeyboardEvent.KEY_UP, keyOutput);
		}
		addEventListener(Event.REMOVED, removeListeners);
	}

	private function removeListeners()
	{
		removeEventListeners();
		Gamepad.get().removeEventListener(GamepadEvent.CHANGE, padInput);
	}

	private function keyInput(e:KeyboardEvent)
	{
		if(equals(e.keyCode, ctrl.up)) cursor.vertDir = NEGATIVE;
		else if(equals(e.keyCode, ctrl.down)) cursor.vertDir = POSITIVE;
		else if(equals(e.keyCode, ctrl.left)) cursor.horiDir = NEGATIVE;
		else if(equals(e.keyCode, ctrl.right)) cursor.horiDir = POSITIVE;
		else if(equals(e.keyCode, ctrl.lAtt)) confirmAction();
		else if(equals(e.keyCode, ctrl.hAtt)) Game.game.reset();
	}

	private function keyOutput(e:KeyboardEvent)
	{
		if(equals(e.keyCode, ctrl.left) || equals(e.keyCode, ctrl.right))
			cursor.horiDir = NO_DIR;
		else if(equals(e.keyCode, ctrl.up) || equals(e.keyCode, ctrl.down))
			cursor.vertDir = NO_DIR;
	}

	private function padInput(e:GamepadEvent)
	{
		if(e.value == 1)
		{
			if(equals(e.control, Gamepad.D_UP)) cursor.vertDir = NEGATIVE;
			else if(equals(e.control, ctrl.down)) cursor.vertDir = POSITIVE;
			else if(equals(e.control, ctrl.left)) cursor.horiDir = NEGATIVE;
			else if(equals(e.control, ctrl.right)) cursor.horiDir = POSITIVE;
			else if(equals(e.control, ctrl.lAtt) || equals(e.control, ctrl.up)) confirmAction();
			else if(equals(e.control, ctrl.hAtt)) Game.game.reset();
		}
		else if(e.value == 0)
		{
			if(equals(e.control, ctrl.left) || equals(e.control, ctrl.right))
				cursor.horiDir = NO_DIR;
			else if(equals(e.control, Gamepad.D_UP) || equals(e.control, ctrl.down))
				cursor.vertDir = NO_DIR;
		}
	}

	private inline static function equals(a : Float, b : Float) : Bool
	{	return a == b;}

	private function confirmAction()
	{
		var l = buttons.length;
		for(i in 0...l)
		{
			if(cursor.bounds.intersects(buttons[i].bounds))
			{
				Game.game.removeChildren();
				Game.game.addChild(new Level(new GameLevel(i), Game.game.getPlayers(), conditions));
				Game.game.play(i%3+2);
				return;
			}
		}
		if(cursor.bounds.intersects(buttons2[1].bounds))
		{
			switch(conditions.type)
			{
				case STOCK:
					if(++conditions.goal > 10)
						conditions.goal = 1;
				case TIME:
					conditions.goal += 30000;
					if(conditions.goal > 300000)
						conditions.goal = 30000;
			}
			SFX.play("Select");
			updateText();
		}
		else if(cursor.bounds.intersects(buttons2[0].bounds))
		{
			switch(conditions.type)
			{
				case STOCK:
					conditions.type = TIME;
					conditions.goal = 30000;
				case TIME:
					conditions.type = STOCK;
					conditions.goal = 1;
			}
			SFX.play("Select");
			updateText();
		}
	}

	private function updateText()
	{
		buttons2[0].text = "Game Type: " + switch(conditions.type)
		{
			case STOCK: "STOCK";
			case TIME: "TIME";
		};
		buttons2[1].text = switch(conditions.type)
		{
			case STOCK: "Lives: " + conditions.goal;
			case TIME: "Time " + Math.floor(conditions.goal / 60000) + ":" +
						Math.floor((conditions.goal % 60000) / 1000);
		};
		if(StringTools.endsWith(buttons2[1].text, ":0")) buttons2[1].text += "0";
	}
}