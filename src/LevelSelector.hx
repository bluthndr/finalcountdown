import starling.display.*;
import starling.events.*;
import starling.text.TextField;
import starling.utils.Color;
import bitmasq.*;

class LevelSelector extends Sprite
{
	private var cursor : Cursor;
	private var buttons : Array<GameText>;
	private var ctrl : Controller;

	private static inline var MAX_LEVELS = 10;

	public function new()
	{
		super();

		var gt = new GameText(Std.int(Startup.stageWidth(0.7)),
		Std.int(Startup.stageHeight(0.2)),"Select a stage");
		gt.fontSize = 50;
		gt.x = Startup.stageWidth(0.3); addChild(gt);

		buttons = new Array();
		for(i in 0...GameLevel.LEVEL_NUM)
		{
			var c = Std.int(i * 255/GameLevel.LEVEL_NUM);
			var t = new GameText(Std.int(Startup.stageWidth(0.25)),
			Std.int(Startup.stageHeight(1/MAX_LEVELS)), GameLevel.getName(i));
			t.setColor(Color.rgb(c,c,c));
			t.y = Startup.stageHeight(i/MAX_LEVELS);
			buttons.push(t);
			addChild(t);
		}

		ctrl = Game.game.getTopCtrls();
		cursor = new Cursor();
		cursor.x = Startup.stageWidth(0.5) - cursor.width;
		cursor.y = Startup.stageHeight(0.5) - cursor.height;
		addChild(cursor);

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
			if(equals(e.control, ctrl.up)) cursor.vertDir = NEGATIVE;
			else if(equals(e.control, ctrl.down)) cursor.vertDir = POSITIVE;
			else if(equals(e.control, ctrl.left)) cursor.horiDir = NEGATIVE;
			else if(equals(e.control, ctrl.right)) cursor.horiDir = POSITIVE;
			else if(equals(e.control, ctrl.lAtt)) confirmAction();
			else if(equals(e.control, ctrl.hAtt)) Game.game.reset();
		}
		else if(e.value == 0)
		{
			if(equals(e.control, ctrl.left) || equals(e.control, ctrl.right))
				cursor.horiDir = NO_DIR;
			else if(equals(e.control, ctrl.up) || equals(e.control, ctrl.down))
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
				Game.game.addChild(new Level(new GameLevel(i), Game.game.getPlayers()));
				break;
			}
		}
	}
}