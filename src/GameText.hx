import starling.text.TextField;
import starling.display.*;
import starling.events.*;
import starling.textures.Texture;

interface Bordered
{
	private var quad : Quad;
	public function setColor(c : UInt) : Void;
	public function removeBorder() : Void;
}

class GameText extends TextField implements Bordered
{
	//Name of bitmap font to be used for all text
	public inline static var bitmapFont = "EggWhite";
	public inline static var defaultFontSize = 45;
	private var quad : Quad;

	public function new(w : UInt, h : UInt, s : String = "")
	{
		super(w,h,s,bitmapFont,defaultFontSize,0xffffff);
		quad = new Quad(w,h,0);
		addChild(quad);
	}

	public function setColor(c : UInt)
	{	quad.color = c;}

	public function removeBorder()
	{	removeChild(quad);}
}

class GameButton extends Button implements Bordered
{
	private var quad : Quad;

	public function new(w : UInt, h : UInt, s : String, fn : Void->Void)
	{
		super(Texture.empty(w,h), s);
		fontColor = 0xffffff;
		fontName = GameText.bitmapFont;
		fontSize = GameText.defaultFontSize;
		addEventListener(Event.TRIGGERED, fn);
		quad = new Quad(w,h,0);
		addChildAt(quad,0);
	}

	public function setColor(c : UInt)
	{	quad.color = c;}

	public function removeBorder()
	{	removeChild(quad);}
}