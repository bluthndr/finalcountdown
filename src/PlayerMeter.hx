import starling.display.*;
import starling.utils.*;

class PlayerMeter extends Sprite
{
	private var damage : Float;
	private var output : GameText;

	private inline static var MAX_DAMAGE = 200;

	public function new(p : Player, i : UInt)
	{
		super();
		damage = 0;

		addChild(new Quad(100,50,p.getColor()));
		var q = new Quad(80,30, 0);
		q.x = q.y = 10;
		addChild(q);

		output = new GameText(100, 50, Std.string(damage)+"%");
		output.vAlign = VAlign.CENTER;
		output.hAlign = HAlign.CENTER;
		addChild(output);

		x = Startup.stageWidth(0.25*i) + Startup.stageWidth(0.05);
		y = Startup.stageHeight(0.9);
	}

	public function takeDamage(d : Float)
	{
		if(damage < MAX_DAMAGE)
		{
			damage += d;
			if(damage > MAX_DAMAGE)
				damage = MAX_DAMAGE;
		}
		updateText();
	}

	public function getDamage() : Float
	{	return damage;}

	public function reset()
	{
		damage = 0;
		updateText();
	}

	private function updateText()
	{
		output.text = Std.string(damage) + "%";
		var gb : UInt = cast(255 - damage * 255 / MAX_DAMAGE, UInt);
		output.color = Color.rgb(255,gb,gb);
	}
}