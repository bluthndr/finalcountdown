import starling.display.*;
import starling.utils.*;

class PlayerMeter extends Sprite
{
	private var damage : Float;
	private var output : GameText;

	public inline static var MAX_DAMAGE = 300;

	public function new(p : Player, i : UInt)
	{
		super();
		damage = 0;

		addChild(new Quad(100,50,p.getColor()));
		var q = new Quad(80,30, 0);
		q.x = q.y = 10;
		addChild(q);

		output = new GameText(100, 50, Std.string(Math.floor(damage))+"%");
		output.vAlign = VAlign.CENTER;
		output.hAlign = HAlign.CENTER;
		addChild(output);

		alpha = 0.5;

		if(i < 4)
		{
			x = Startup.stageWidth(0.25*i) + Startup.stageWidth(0.05);
			y = Startup.stageHeight(0.9);
		}
		else
		{
			x = Startup.stageWidth(0.25*(i-4)) + Startup.stageWidth(0.05);
		}
	}

	public function takeDamage(d : Float, t : UInt = 60) : Int
	{
		if(damage < MAX_DAMAGE)
		{
			damage += d;
			if(damage > MAX_DAMAGE)
				damage = MAX_DAMAGE;
			updateText();
		}
		return Std.int(damage * t / MAX_DAMAGE);
	}

	public inline function getDamage() : Float
	{	return damage;}

	public function reset()
	{
		damage = 0;
		updateText();
	}

	private function updateText()
	{
		output.text = Std.string(Math.floor(damage)) + "%";
		var gb : UInt = cast(255 - damage * 255 / MAX_DAMAGE, UInt);
		output.color = Color.rgb(255,gb,gb);
	}
}