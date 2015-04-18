import starling.text.TextField;
import starling.display.*;
import starling.events.*;
import starling.textures.Texture;

class GameText extends TextField
{
	//Name of bitmap font to be used for all text
	public inline static var bitmapFont = "Arial";
	private var quad : Quad;

	public function new(w : UInt, h : UInt, s : String = "")
	{
		super(w,h,s,bitmapFont,20,0xffffff);
		quad = new Quad(w,h,0);
		addChild(quad);
	}

	public function setColor(c : UInt)
	{	quad.color = c;}
}

class GameButton extends Button
{
	public function new(w : UInt, h : UInt, s : String, fn : Void->Void)
	{
		super(Texture.empty(w,h), s);
		fontColor = 0xffffff;
		fontName = GameText.bitmapFont;
		fontSize = 20;
		addEventListener(Event.TRIGGERED, fn);
	}
}