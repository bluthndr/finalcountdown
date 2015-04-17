import starling.core.Starling;
import starling.display.*;
import starling.events.*;
import starling.utils.*;
import GameText;
import bitmasq.*;
import flash.ui.*;
import flash.geom.*;

enum PlayerType
{
	HUMAN;
	CPU;
	NONE;
}

class PlayerPanel extends Sprite
{
	private var quad : Quad;
	private var ctrl : Controller;
	private var ready : Bool;
	private var type : PlayerType;
	private var colors : Array<Int>;
	private var buttons : Array<PanelButton>;
	public var cursor : Cursor;
	private var playerID : UInt;

	private static inline var colVal = 25;

	public function new(id : UInt)
	{
		super();
		playerID = id;
		type = id == 0 ? HUMAN : NONE;
		alpha = type == NONE ? 0.5 : 1.0;
		ready = false;
		colors = new Array();
		for(i in 0...3) colors.push(Std.random(256));

		quad = new Quad(Startup.stageWidth(0.125), Startup.stageHeight(0.75), getColor());
		addChild(quad);

		buttons = new Array();
		buttons.push(new PanelButton("Player Type: " + typeString(), changeType));
		buttons.push(new PanelButton("<R", decRed,null,0xff0000));
		buttons.push(new PanelButton("ED>", incRed,null,0xff0000));
		buttons.push(new PanelButton("<GR", decGreen,null,0x00ff00));
		buttons.push(new PanelButton("EEN>", incGreen,null,0x00ff00));
		buttons.push(new PanelButton("<BL", decBlue,null,0x0000ff));
		buttons.push(new PanelButton("UE>", incBlue,null,0x0000ff));
		buttons.push(new PanelButton("Change Controls", null, changeControls));
		buttons.push(new PanelButton("Ready: " + (ready ? "Yes" : "No"), triggerReady));

		var l = buttons.length;
		for(i in 0...l)
		{
			switch(i)
			{
				case 0:
					addChild(buttons[i]);
				case 1,3,5:
					buttons[i].width /= 2;
					buttons[i].y = buttons[i-1].y + buttons[i-1].height*1.5;
					addChild(buttons[i]);
					buttons[i].textHAlign = HAlign.RIGHT;
				case 2,4,6:
					buttons[i].width /= 2;
					buttons[i].x = buttons[i].width;
					buttons[i].y = buttons[i-1].y;
					buttons[i].textHAlign = HAlign.LEFT;
					addChild(buttons[i]);
				default:
					buttons[i].y = buttons[i-1].y + buttons[i-1].height*1.5;
					addChild(buttons[i]);
			}
		}

		cursor = new Cursor(getColor());
		ctrl = switch(id)
		{
			case 0:
				{left : Keyboard.LEFT,
				right : Keyboard.RIGHT,
				down : Keyboard.DOWN,
				up : Keyboard.UP,
				lAtt : Keyboard.SHIFT,
				hAtt : Keyboard.CONTROL,
				gamepad : false,
				padID: -1};
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
				{left : -1,
				right : -1,
				down : -1,
				up : -1,
				lAtt : -1,
				hAtt : -1,
				gamepad : false,
				padID : -1};

		};
		addEventListener(Event.ADDED_TO_STAGE, function()
		{
			touchable = false;
			var nx = x; x = Startup.stageWidth(switch(id)
			{
				case 0,1,2,3: -1;
				default: 2;
			});
			Starling.juggler.tween(this, 0.5, {x : nx, delay : 0,
			onComplete : function(){touchable = true;}});
		});
	}

	private inline function decRed()
	{
		colors[0] -= colVal;
		if(colors[0] < 0) colors[0] = 0;
		setColor();
	}

	private inline function incRed()
	{
		colors[0] += colVal;
		if(colors[0] > 255) colors[0] = 255;
		setColor();
	}

	private inline function decGreen()
	{
		colors[1] -= colVal;
		if(colors[1] < 0) colors[1] = 0;
		setColor();
	}

	private inline function incGreen()
	{
		colors[1] += colVal;
		if(colors[1] > 255) colors[1] = 255;
		setColor();
	}

	private inline function decBlue()
	{
		colors[2] -= colVal;
		if(colors[2] < 0) colors[2] = 0;
		setColor();
	}

	private inline function incBlue()
	{
		colors[2] += colVal;
		if(colors[2] > 255) colors[2] = 255;
		setColor();
	}

	public inline function getColor() : UInt
	{	return Color.rgb(colors[0], colors[1], colors[2]);}

	public inline function typeString() : String
	{
		return switch(type)
		{
			case HUMAN: "Human";
			case CPU: "CPU";
			case NONE: "None";
		}
	}

	public inline function isHuman() : Bool
	{	return type == HUMAN;}

	public inline function getCtrls() : Controller
	{	return ctrl;}

	public function reset()
	{	ready = false; cursor.reset(); updateText();}

	public inline function isReady() : Bool
	{	return ready;}

	private inline function setColor()
	{	cursor.color = quad.color = getColor();}

	public function checkKeyInput(val : Float)
	{
		if(!ctrl.gamepad)
		{
			if(val == ctrl.left) cursor.horiDir = NEGATIVE;
			else if(val == ctrl.right) cursor.horiDir = POSITIVE;
			else if(val == ctrl.up) cursor.vertDir = NEGATIVE;
			else if(val == ctrl.down) cursor.vertDir = POSITIVE;
			else if(val == ctrl.lAtt || val == ctrl.hAtt) checkPress();
		}
	}

	public function checkKeyOutput(val : Float)
	{
		if(!ctrl.gamepad)
		{
			if(val == ctrl.left || val == ctrl.right)
				cursor.horiDir = NO_DIR;
			else if(val == ctrl.up || val == ctrl.down)
				cursor.vertDir = NO_DIR;
		}
	}

	public function checkPadInput(e:GamepadEvent)
	{
		if(ctrl.gamepad && e.deviceIndex == ctrl.padID)
		{
			if(e.value == 0)
			{
				if(e.control == ctrl.left || e.control == ctrl.right)
					cursor.horiDir = NO_DIR;
				else if(e.control == Gamepad.D_UP || e.control == ctrl.down)
					cursor.vertDir = NO_DIR;
			}
			else if(e.value == 1)
			{
				if(e.control == ctrl.left) cursor.horiDir = NEGATIVE;
				else if(e.control == ctrl.right) cursor.horiDir = POSITIVE;
				else if(e.control == Gamepad.D_UP) cursor.vertDir = NEGATIVE;
				else if(e.control == ctrl.down) cursor.vertDir = POSITIVE;
				else if(e.control == ctrl.up || e.control == ctrl.lAtt ||
				e.control == ctrl.hAtt)	{checkPress();}
			}
		}
	}

	private function checkPress()
	{	cast(parent, GamePanel).trigger(cursor);}

	public function trigger(cur : Cursor)
	{
		var point = globalToLocal(new Point(cur.x, cur.y));
		var rect = new Rectangle(point.x, point.y, cur.width, cur.height);
		for(button in buttons)
		{
			if(rect.intersects(button.bounds))
			{
				try{button.trigger(playerID);}
				catch(d:Dynamic){button.trigger();}
			}
		}
	}

	public function updateText()
	{
		buttons[0].text = "Player Type: " + typeString();
		buttons[8].text = "Ready: " + (ready ? "Yes" : "No");
	}

	private function changeType()
	{
		type = switch(type)
		{
			case HUMAN: CPU;
			case CPU: NONE;
			case NONE: HUMAN;
		};
		alpha = type == NONE ? 0.5 : 1.0;
		reset();
	}

	private function changeControls(id : UInt)
	{
		if(type == HUMAN)
		{
			parent.dispatchEvent(new ControlChangerEvent(id));
			parent.removeChild(cursor);
		}
	}

	private function triggerReady()
	{
		if(type == HUMAN)
		{
			ready = !ready;
			parent.dispatchEventWith(Game.READY);
		}
	}
}

class PanelButton extends GameButton
{
	public var trigger : Dynamic;
	public function new(s : String, fn : Void->Void, ?fn2 : UInt->Void, ?c : UInt)
	{
		super(cast(Startup.stageWidth(0.125),Int),50,s,function()
		{
			if(fn != null) fn();
		});
		addChildAt(new Quad(Startup.stageWidth(0.125),50, c == null ? 0 : c), 0);
		trigger = fn == null ? fn2 : fn;
	}
}

enum CURSOR_DIRECTION
{
	POSITIVE;
	NEGATIVE;
	NO_DIR;
}

class Cursor extends Image
{
	public var vertDir : CURSOR_DIRECTION;
	public var horiDir : CURSOR_DIRECTION;
	public function new(c : UInt)
	{
		super(Root.assets.getTexture("fist"));
		vertDir = horiDir = NO_DIR;
		color = c;
		addEventListener(Event.ADDED_TO_STAGE, function()
		{
			removeEventListeners(Event.ADDED_TO_STAGE);
			addEventListener(Event.ENTER_FRAME, update);
		});
		scaleX = scaleY = 0.1;
		alignPivot();
	}

	public function reset()
	{	vertDir = horiDir = NO_DIR; rotation = 0;}

	private function update(e:EnterFrameEvent)
	{
		var velx = 0; var vely = 0;
		switch(vertDir)
		{
			case NEGATIVE:
				if(y > 0)vely = -5;
			case POSITIVE:
				if(y < Startup.stageHeight()) vely = 5;
			default:
		}
		switch(horiDir)
		{
			case NEGATIVE:
				if(x > 0) velx = -5;
			case POSITIVE:
				if(x < Startup.stageWidth()) velx = 5;
			default:
		}
		if(vely != 0 || velx != 0)
		{
			y += vely; x += velx;
			rotation = Math.atan2(vely,velx);
		}
	}
}