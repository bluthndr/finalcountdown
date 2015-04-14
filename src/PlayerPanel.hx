import starling.display.*;
import bitmasq.*;
import starling.utils.Color;
import flash.ui.*;

enum PlayerType
{
	HUMAN;
	CPU;
	NONE;
}

enum PanelState
{
	REGULAR;
	CHANGE_CTRL_TYPE;
	CHANGE_CTRL;
}

class PlayerPanel extends Sprite
{
	private var quad : Quad;
	private var ctrl : Controller;
	private var ready : Bool;
	private var state : PanelState;
	private var type : PlayerType;
	private var r : Int;
	private var g : Int;
	private var b : Int;
	private var curChoice : UInt;
	private var texts : Array<PanelText>;

	private static inline var choiceNum = 6;
	public static inline var READY = "ReadyEvent";

	public function new(id : UInt)
	{
		super();
		state = REGULAR;
		type = id == 0 ? HUMAN : NONE;
		ready = false;
		r = Std.random(256);
		g = Std.random(256);
		b = Std.random(256);
		curChoice = 0;

		quad = new Quad(Startup.stageWidth(0.2), Startup.stageHeight(0.75), Color.rgb(r,g,b));
		addChild(quad);

		texts = new Array();
		for(i in 0...choiceNum)
		{
			var t = new PanelText(switch(i)
			{
				case 0: "Player Type: " + typeString();
				case 1: "Red Color: " + Std.string(r);
				case 2: "Green Color: " + Std.string(g);
				case 3: "Blue Color: " + Std.string(b);
				case 4: "Change Controls";
				default: "Ready: " + (ready ? "Yes" : "No");
			});
			t.y = i * 75;
			texts.push(t);
			addChild(t);
		}
		updateCursor();

		ctrl = switch(id)
		{
			case 1:
				{left : Keyboard.A,
				right : Keyboard.D,
				down : Keyboard.S,
				up : Keyboard.W,
				lAtt : Keyboard.Q,
				hAtt : Keyboard.E,
				gamepad : false,
				padID: -1};
			case 2:
				{left : Keyboard.F,
				right : Keyboard.H,
				down : Keyboard.G,
				up : Keyboard.T,
				lAtt : Keyboard.R,
				hAtt : Keyboard.Y,
				gamepad : false,
				padID: -1};
			case 3:
				{left : Keyboard.J,
				right : Keyboard.L,
				down : Keyboard.K,
				up : Keyboard.I,
				lAtt : Keyboard.U,
				hAtt : Keyboard.O,
				gamepad : false,
				padID: -1};
			default:
				{left : Keyboard.LEFT,
				right : Keyboard.RIGHT,
				down : Keyboard.DOWN,
				up : Keyboard.UP,
				lAtt : Keyboard.SHIFT,
				hAtt : Keyboard.CONTROL,
				gamepad : false,
				padID: -1};
		};
	}

	public function typeString() : String
	{
		return switch(type)
		{
			case HUMAN: "Human";
			case CPU: "CPU";
			case NONE: "None";
		}
	}

	public function isHuman() : Bool
	{	return type == HUMAN;}

	public function isChangingCtrls() : Bool
	{	return state != REGULAR;}

	public function getCtrls() : Controller
	{	return ctrl;}

	public function getColor() : UInt
	{	return quad.color;}

	public function reset()
	{	ready = false; updateText();}

	public function isReady() : Bool
	{	return ready;}

	private function setColor()
	{	quad.color = Color.rgb(r,g,b);}

	/*Choices
	Regular State			Control Change State
	----------------		----------------
	0->playerType			0->left
	1->r					1->right
	2->g					2->down
	3->b					3->up
	4->Change Controls		4->lAtt
	5->Ready				5->hAtt
	*/
	public function checkKeyInput(val : Float)
	{
		//trace("Execute: keyInput with " + val);
		switch(state)
		{
			case REGULAR:
			if(!ctrl.gamepad)
			{
				if(val == ctrl.left) leftAction();
				else if(val == ctrl.right) rightAction();
				else if(val == ctrl.up) upAction();
				else if(val == ctrl.down) downAction();
				else if(val == ctrl.lAtt || val == ctrl.hAtt) confirmAction();
			}
			case CHANGE_CTRL_TYPE:
				ctrl.gamepad = false;
				changeState(CHANGE_CTRL);
			case CHANGE_CTRL:
			{
				if(!ctrl.gamepad)
				{
					switch(curChoice++ % choiceNum)
					{
						case 0: ctrl.left = val;
						case 1: ctrl.right = val;
						case 2: ctrl.down = val;
						case 3: ctrl.up = val;
						case 4: ctrl.lAtt = val;
						default:
							ctrl.hAtt = val;
							changeState(REGULAR);
					}
					updateText();
				}
			}
		}
	}

	public function checkPadInput(e:GamepadEvent)
	{
		//trace("Execute: padInput with " + e.deviceIndex, e.control);
		switch(state)
		{
			case REGULAR:
			if(ctrl.gamepad &&
			e.deviceIndex == ctrl.padID)
			{
				if(e.control == ctrl.left) leftAction();
				else if(e.control == ctrl.right) rightAction();
				else if(e.control == Gamepad.D_UP) upAction();
				else if(e.control == ctrl.down) downAction();
				else if(e.control == ctrl.up || e.control == ctrl.lAtt ||
				e.control == ctrl.hAtt)	{confirmAction();}
			}
			case CHANGE_CTRL_TYPE:
				ctrl.gamepad = true;
				ctrl.padID = e.deviceIndex;
				ctrl.left = Gamepad.D_LEFT;
				ctrl.right = Gamepad.D_RIGHT;
				ctrl.down = Gamepad.D_DOWN;
				changeState(CHANGE_CTRL);
			case CHANGE_CTRL:
			{
				if(ctrl.gamepad)
				{
					switch(curChoice++ % choiceNum)
					{
						/*case 0: ctrl.left = e.control;
						case 1: ctrl.right = e.control;
						case 2: ctrl.down = e.control;*/
						case 3: ctrl.up = e.control;
						case 4: ctrl.lAtt = e.control;
						default:
							ctrl.hAtt = e.control;
							changeState(REGULAR);
					}
					updateText();
				}
			}
		}
	}

	private function leftAction()
	{
		switch(curChoice % choiceNum)
		{
			case 0:
			type = switch(type)
			{
				case HUMAN: NONE;
				case NONE: CPU;
				case CPU: HUMAN;
			};
			ready = (type == CPU);
			case 1:
				r -= 5;
				if(r < 0) r = 0;
				setColor();
			case 2:
				g -= 5;
				if(g < 0) g = 0;
				setColor();
			case 3:
				b -= 5;
				if(b < 0) b = 0;
				setColor();
			case 4:
				changeState(CHANGE_CTRL_TYPE);
		}
		updateText();
	}

	private function rightAction()
	{
		switch(curChoice % choiceNum)
		{
			case 0:
			type = switch(type)
			{
				case HUMAN: CPU;
				case NONE: HUMAN;
				case CPU: NONE;
			};
			ready = (type == CPU);
			case 1:
				r += 5;
				if(r > 255) r = 255;
				setColor();
			case 2:
				g += 5;
				if(g > 255) g = 255;
				setColor();
			case 3:
				b += 5;
				if(b > 255) b = 255;
				setColor();
			case 4:
				changeState(CHANGE_CTRL_TYPE);
		}
		updateText();
	}

	private function upAction()
	{
		if(curChoice == 0) curChoice = choiceNum-1;
		else --curChoice;
		updateCursor();
	}

	private function downAction()
	{
		++curChoice;
		updateCursor();
	}

	private function updateCursor()
	{
		for(i in 0...texts.length)
		{
			if(cast(i, UInt) == curChoice % choiceNum)
				texts[i].color = 0xff0000;
			else texts[i].color = 0xffffff;
		}
	}

	private function confirmAction()
	{
		switch(curChoice % choiceNum)
		{
			case 4:
				changeState(CHANGE_CTRL_TYPE);
			case 5:
				if(type != NONE) ready = !ready;
				cast(parent, Game).checkReady();
		}
		updateText();
	}

	private function changeState(gs : PanelState)
	{
		switch(gs)
		{
			case REGULAR:
				curChoice = 0;
				ready = false;
				state = REGULAR;
				cast(parent, Game).stopChange();
			case CHANGE_CTRL_TYPE:
				if(cast(parent, Game).canChange(this))
				{
					curChoice = 0;
					ready = false;
					state = CHANGE_CTRL_TYPE;
				}
				updateText();
			case CHANGE_CTRL:
				if(cast(parent, Game).canChange(this))
				{
					curChoice = ctrl.gamepad ? 3 : 0;
					ready = false;
					state = CHANGE_CTRL;
				}
				updateText();
		}
		updateCursor();
	}

	private function updateText()
	{
		switch(state)
		{
			case REGULAR:
			for(i in 0...choiceNum)
			{
				texts[i].text = switch(i)
				{
					case 0: "Player Type: " + typeString();
					case 1: "Red Color: " + Std.string(r);
					case 2: "Green Color: " + Std.string(g);
					case 3: "Blue Color: " + Std.string(b);
					case 4: "Change Controls";
					default: "Ready: " + (ready ? "Yes" : "No");
				};
			}
			case CHANGE_CTRL_TYPE:
			for(i in 0...choiceNum)
			{
				texts[i].text = switch(i)
				{
					case 0: "Press a button on the device";
					default: "";
				};
			}
			case CHANGE_CTRL:
			for(i in 0...choiceNum)
			{
				texts[i].text = switch(i)
				{
					case 0: "Control Type: " + (ctrl.gamepad ? "Gamepad" : "Keyboard");
					case 1: "Press a button/key to set the ";
					case 2: (switch(curChoice % choiceNum)
					{
						case 0: "Left";
						case 1: "Right";
						case 2: "Down";
						case 3: "Jump";
						case 4: "Light Attack";
						default: "Heavy Attack";
					}) + " button";
					default: "";
				};
			}
		}
	}
}

class PanelText extends GameText
{
	private var quad : Quad;
	public function new(s : String)
	{
		super(cast(Startup.stageWidth(0.2),Int),50,s);
		fontSize = 10;
		quad = new Quad(Startup.stageWidth(0.2),50,0);
		addChild(quad);
	}
}