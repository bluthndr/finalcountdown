import starling.display.*;
import starling.text.TextField;
import starling.utils.*;

class PlayerMeter extends Sprite
{
	private var damage : Float;
	private var output : TextField;

	public function new(p : Player, i : UInt)
	{
		super();
		damage = 0;

		addChild(new Quad(100,50, p.getColor()));

		output = new TextField(100, 50, Std.string(damage)+"%");
		output.fontSize = 20;
		output.vAlign = VAlign.CENTER;
		output.hAlign = HAlign.CENTER;
		addChild(output);

		x = Startup.stageWidth(0.25*i) + Startup.stageWidth(0.05);
		y = Startup.stageHeight(0.9);
	}

	public function takeDamage(d : Float)
	{
		if(damage < 300)
		{
			damage += d;
			if(damage > 300) damage = 300;
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
		output.color = Color.rgb(cast(0.85*damage,Int),0,0);
	}
}