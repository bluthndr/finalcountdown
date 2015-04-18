import starling.display.*;
import starling.events.*;
import flash.ui.*;
import flash.filesystem.*;
import flash.geom.Point;

typedef Placeable = {x : Float, y : Float, w : Float, h : Float, type : Int}
class LevelEditor extends Sprite
{
	private var curplac : Placeable;
	private var placeable : Array<Placeable>;
	private var quad : Quad;
	private var tBox : GameText;

	private inline static var gWidth = 64;
	private inline static var gHeight = 64;

	/*
	Types:
	0 - wall
	1 - platform
	2 - lava
	3-10 - player start position
	*/

	public function new()
	{
		super();

		placeable =	//new Array();
		[{x : 0, y : 0, w : 64, h : 640, type : 2},
		{x : 64, y : 256, w : 192, h : 64, type : 0},
		{x : 256, y : 384, w : 192, h : 64, type : 0},
		{x : 448, y : 512, w : 192, h : 64, type : 0},
		{x : 640, y : 384, w : 192, h : 64, type : 0},
		{x : 832, y : 256, w : 192, h : 64, type : 0},
		{x : 1024, y : 0, w : 64, h : 640, type : 2},
		{x : 0, y : -64, w : 1088, h : 64, type : 2},
		{x : 64, y : 576, w : 960, h : 64, type : 2},
		{x : 832, y : 512, w : 192, h : 64, type : 0},
		{x : 64, y : 512, w : 192, h : 64, type : 0},
];

		for(place in placeable)
		{
			var q = new Quad(place.w, place.h, getColor(place));
			q.x = place.x; q.y = place.y;
			addChild(q);
		}

		curplac = {x : 0, y : 0, w : gWidth, h : gHeight, type : 0};
		quad = new Quad(gWidth, gHeight);
		addChild(quad);
		tBox = new GameText(gWidth, gHeight);
		addChild(tBox);
		update();
		addEventListener(Event.ADDED, init);
	}

	private function init()
	{
		removeEventListener(Event.ADDED, init);
		addEventListener(KeyboardEvent.KEY_DOWN, move);
	}

	private function move(e:KeyboardEvent)
	{
		switch(e.keyCode)
		{
			case Keyboard.LEFT:
				quad.x -= gWidth;
				checkPosition();
				tBox.x = quad.x;
			case Keyboard.RIGHT:
				quad.x += gWidth;
				checkPosition();
				tBox.x = quad.x;
			case Keyboard.UP:
				quad.y -= gHeight;
				checkPosition();
				tBox.y = quad.y;
			case Keyboard.DOWN:
				quad.y += gHeight;
				checkPosition();
				tBox.y = quad.y;
			case Keyboard.A:
				if(quad.scaleX > 1)
					--quad.scaleX;
			case Keyboard.D:
				++quad.scaleX;
			case Keyboard.W:
				if(quad.scaleY > 1)
					--quad.scaleY;
			case Keyboard.S:
				++quad.scaleY;
			case Keyboard.Q:
				if(curplac.type == 0) curplac.type = 10;
				else --curplac.type;
				update();
			case Keyboard.E:
				++curplac.type;
				update();
			case Keyboard.J:
				x += gWidth;
			case Keyboard.L:
				x -= gWidth;
			case Keyboard.I:
				y += gHeight;
			case Keyboard.K:
				y -= gHeight;
			case Keyboard.SPACE:
				add();
			case Keyboard.ENTER:
				save();
			case Keyboard.ESCAPE:
				Game.game.reset();
			case Keyboard.F1:
				haxe.Log.clear();
		}
	}

	private inline function update()
	{
		quad.color = getColor();
		tBox.text = getText();
	}

	private inline function getColor(?place : Placeable) : UInt
	{
		return switch(place == null ? curplac.type % 11 : place.type % 11)
		{
			case 0: 0x0000ff;
			case 1: 0x00ff00;
			case 2: 0xff0000;
			default: 0;
		}
	}

	private function checkPosition()
	{
		var globals = localToGlobal(new Point(quad.x, quad.y));

		if(globals.x < 0) globals.x = 0;
		else if(globals.x >= Startup.stageWidth())
			globals.x = Startup.stageWidth() - quad.width;
		if(globals.y < 0) globals.y = 0;
		else if(globals.y >= Startup.stageHeight())
			globals.y = Startup.stageHeight() - quad.height;

		globalToLocal(globals, globals);
		quad.x = globals.x; quad.y = globals.y;
	}

	private inline function getText() : String
	{
		return switch(curplac.type % 11)
		{
			case 0: "Wall";
			case 1: "Platform";
			case 2: "Lava";
			default: "Player #" + Std.string((curplac.type-2) % 11);
		}
	}

	private function clone(?plc : Placeable) : Dynamic
	{
		if(plc != null)
		{
			return {x : plc.x, y : plc.y, w : plc.w, h : plc.h, type : plc.type};
		}
		else
		{
			var q = new Quad(quad.width, quad.height, quad.color);
			q.x = quad.x; q.y = quad.y;
			return q;
		}
	}

	private inline function add()
	{
		addChildAt(clone(),0);
		var olx = x; var oly = y;
		x = y = 0;

		var globals = localToGlobal(new Point(quad.x, quad.y));
		curplac.x = globals.x; curplac.y = globals.y;
		curplac.w = quad.width; curplac.h = quad.height;
		x = olx; y = oly;
		trace(curplac);

		placeable.push(clone(curplac));
	}

	private function save()
	{
		var file = File.desktopDirectory.resolvePath("level.txt");
		var fout = new FileStream();
		fout.open(file, FileMode.WRITE);
		fout.writeUTFBytes(toString());
		fout.close();
		trace("Saved Level");
	}

	public function toString() : String
	{
		var s : String = "[";
		for(place in placeable)
		{
			s += "{x : " + place.x + ", y : " + place.y +
			", w : " + place.w + ", h : " + place.h + ", type : " +
			(place.type % 11) + "},\n";
		}
		s += "];";
		return s;
	}
}