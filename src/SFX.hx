import flash.media.*;

class SFX
{
	public static var soundVol = 0.1;
	public static var isStepping = false;
	
	public inline static function play(s : String)
	{	Root.assets.playSound(s,0,0,new SoundTransform(soundVol));}
	
	public inline static function step(s : String)
	{
		if(!isStepping)
		{
			isStepping = true;
			var sound = Root.assets.getSound(s);
			var stepChannel = sound.play();
			stepChannel.soundTransform = new SoundTransform(soundVol-0.03);
			stepChannel.addEventListener(flash.events.Event.SOUND_COMPLETE,
			function(e:flash.events.Event)
			{
				isStepping = false;
			});
		}	
	}
}