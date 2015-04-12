import starling.display.*;
import starling.text.TextField;
import starling.utils.*;

class PlayerMeter extends Sprite
{
	private var damage : Float;
	private var output : TextField;
	private var quad : Quad;

	public function new(p : Player, i : UInt)
	{
		super();
		damage = 0;

		var q = new Quad(100,50, p.getColor());
		q.alpha = 0.25;
		addChild(q);

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
		output.text = Std.string(damage) + "%";
		output.color = Color.rgb(cast(0.85*damage,Int),0,0);
	}

	public function getDamage() : Float
	{	return damage;}
}