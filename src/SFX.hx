import flash.media.*;

class SFX
{
	public static function play(s : String)
	{
		var sound = Root.assets.getSound(s);
		var channel = sound.play();
		channel.soundTransform = new SoundTransform(0.1);
	}
}