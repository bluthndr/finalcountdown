import starling.display.Sprite;
import starling.events.*;
import bitmasq.*;

class ControlChanger extends Sprite
{
	private var curState : Int;
	private var stateText : GameText;
	private var ctrl : Controller;

	public inline static var DONE = "DoneChangingControls";

	private static var stateTexts : Array<String> =
	["Press a button on the device you want to use",
	"Set the left button", "Set the right button",
	"Set the down button", "Set the jump button",
	"Set the light attack button", "Set the heavy attack button"];

	public function new(id : UInt, p_ctrl : Controller)
	{
		super();

		addChild(new starling.display.Quad(200,400,0));
		addChild(new GameText(200,200, "Setting Controls for Player #" + (id+1)));

		curState = 0;
		stateText = new GameText(200,200, stateTexts[curState]);
		stateText.y = 200;
		addChild(stateText);

		ctrl = p_ctrl;
		addEventListener(Event.ADDED, function()
		{
			removeEventListeners(Event.ADDED);
			Gamepad.get().addEventListener(GamepadEvent.CHANGE, changePadCtrl);
			addEventListener(KeyboardEvent.KEY_DOWN, changeKeyboardCtrl);
		});
	}

	private function update(val : Float)
	{
		switch(curState)
		{
			case 1: ctrl.left = val;
			case 2: ctrl.right = val;
			case 3: ctrl.down = val;
			case 4: ctrl.up = val;
			case 5: ctrl.lAtt = val;
			case 6: ctrl.hAtt = val;
		}
		if(++curState >= stateTexts.length)
		{
			parent.dispatchEventWith(DONE);
			removeEventListeners();
			Gamepad.get().removeEventListener(GamepadEvent.CHANGE, changePadCtrl);
		}
		else stateText.text = stateTexts[curState];
	}

	private function changePadCtrl(e:GamepadEvent)
	{
		if(curState == 0)
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, changeKeyboardCtrl);
			ctrl.gamepad = true;
			ctrl.padID = e.deviceIndex;
		}
		if(e.value == 1)
			update(e.control);
	}

	private function changeKeyboardCtrl(e:KeyboardEvent)
	{
		if(curState == 0)
		{
			Gamepad.get().removeEventListener(GamepadEvent.CHANGE, changePadCtrl);
			ctrl.gamepad = false;
		}
		update(e.keyCode);
	}
}