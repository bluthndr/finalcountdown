import LevelEditor;

class GameLevel extends LevelMap
{
	public function new(index : UInt)
	{
		super(getLevel(index), getColor(index));
		name = getName(index);
	}

	public static function getName(index : UInt) : String
	{
		return switch(index % LevelSelector.MAX_LEVELS)
		{
			case 1: "Big Cage";
			case 2: "Pyramid";
			case 3: "Big Pyramid";
			case 4: "Pit";
			case 5: "Castle";
			case 6: "Field";
			case 7: "Hill";
			case 8: "Decline";
			case 9: "Incline";
			default: "Cage";
		}
	}

	private static function getLevel(index : UInt) : Array<Placeable>
	{
		return switch(index % LevelSelector.MAX_LEVELS)
		{
			case 1: BigCage();
			case 2: Battlefield();
			case 3: BigBattlefield();
			case 4: FirePit();
			case 5: Castle();
			case 6: Field();
			case 7: Hill();
			case 8: Decline();
			case 9: Incline();
			default: Cage();
		}
	}

	private static function getColor(index : UInt) : UInt
	{
		return switch(index % LevelSelector.MAX_LEVELS)
		{
			case 2,3,4,7: 0xff6347;
			case 8,9: 0xaaaaaa;
			default: 0x00bfff;
		}
	}

	private inline static function Battlefield() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 960, type : 0},
				{x : 960, y : 0, w : 64, h : 960, type : 0},
				{x : 0, y : -64, w : 1024, h : 64, type : 0},
				{x : 64, y : 640, w : 896, h : 320, type : 2},
				{x : 192, y : 512, w : 640, h : 64, type : 1},
				{x : 256, y : 384, w : 128, h : 64, type : 1},
				{x : 640, y : 384, w : 128, h : 64, type : 1},
				{x : 384, y : 256, w : 256, h : 64, type : 1},
				{x : 192, y : 384, w : 64, h : 64, type : 3},
				{x : 768, y : 384, w : 64, h : 64, type : 4},
				{x : 384, y : 128, w : 64, h : 64, type : 5},
				{x : 576, y : 128, w : 64, h : 64, type : 6},
				{x : 256, y : 256, w : 64, h : 64, type : 7},
				{x : 704, y : 256, w : 64, h : 64, type : 8},
				{x : 384, y : 384, w : 64, h : 64, type : 9},
				{x : 576, y : 384, w : 64, h : 64, type : 10}];
	}

	private static function BigBattlefield() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 1280, type : 0},
				{x : 1280, y : 0, w : 64, h : 1280, type : 0},
				{x : 0, y : -64, w : 1344, h : 64, type : 0},
				{x : 64, y : 960, w : 1216, h : 320, type : 2},
				{x : 192, y : 832, w : 960, h : 64, type : 1},
				{x : 256, y : 704, w : 192, h : 64, type : 1},
				{x : 896, y : 704, w : 192, h : 64, type : 1},
				{x : 576, y : 704, w : 192, h : 64, type : 1},
				{x : 384, y : 576, w : 256, h : 64, type : 1},
				{x : 704, y : 576, w : 256, h : 64, type : 1},
				{x : 512, y : 448, w : 320, h : 64, type : 1},
				{x : 256, y : 576, w : 64, h : 64, type : 3},
				{x : 1024, y : 576, w : 64, h : 64, type : 4},
				{x : 448, y : 704, w : 64, h : 64, type : 5},
				{x : 832, y : 704, w : 64, h : 64, type : 6},
				{x : 640, y : 576, w : 64, h : 64, type : 7},
				{x : 448, y : 448, w : 64, h : 64, type : 8},
				{x : 832, y : 448, w : 64, h : 64, type : 9},
				{x : 640, y : 320, w : 64, h : 64, type : 10}];
	}

	private static function Cage() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 640, type : 0},
			{x : 576, y : 0, w : 64, h : 640, type : 0},
			{x : 64, y : 576, w : 512, h : 64, type : 1},
			{x : 64, y : 0, w : 512, h : 64, type : 0},
			{x : 64, y : 448, w : 64, h : 64, type : 3},
			{x : 512, y : 448, w : 64, h : 64, type : 4},
			{x : 128, y : 448, w : 64, h : 64, type : 5},
			{x : 448, y : 448, w : 64, h : 64, type : 6},
			{x : 192, y : 448, w : 64, h : 64, type : 7},
			{x : 384, y : 448, w : 64, h : 64, type : 8},
			{x : 256, y : 448, w : 64, h : 64, type : 9},
			{x : 320, y : 448, w : 64, h : 64, type : 10}];
	}

	private static function BigCage() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 640, type : 0},
				{x : 1216, y : 0, w : 64, h : 640, type : 0},
				{x : 0, y : -64, w : 1280, h : 64, type : 0},
				{x : 0, y : 640, w : 1280, h : 64, type : 0},
				{x : 128, y : 512, w : 64, h : 64, type : 3},
				{x : 1088, y : 512, w : 64, h : 64, type : 4},
				{x : 256, y : 512, w : 64, h : 64, type : 5},
				{x : 960, y : 512, w : 64, h : 64, type : 6},
				{x : 384, y : 512, w : 64, h : 64, type : 7},
				{x : 832, y : 512, w : 64, h : 64, type : 8},
				{x : 512, y : 512, w : 64, h : 64, type : 9},
				{x : 704, y : 512, w : 64, h : 64, type : 10}];
	}

	private static function FirePit() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 640, type : 2},
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
				{x : 448, y : 256, w : 192, h : 64, type : 0},
				{x : 128, y : 128, w : 64, h : 64, type : 3},
				{x : 896, y : 128, w : 64, h : 64, type : 4},
				{x : 896, y : 384, w : 64, h : 64, type : 6},
				{x : 128, y : 384, w : 64, h : 64, type : 5},
				{x : 320, y : 256, w : 64, h : 64, type : 7},
				{x : 704, y : 256, w : 64, h : 64, type : 8},
				{x : 512, y : 128, w : 64, h : 64, type : 9},
				{x : 512, y : 384, w : 64, h : 64, type : 10}];
	}

	private static function Castle() : Array<Placeable>
	{
		return [{x : 0, y : 192, w : 64, h : 384, type : 0},
				{x : 128, y : 384, w : 192, h : 64, type : 1},
				{x : 448, y : 384, w : 192, h : 64, type : 1},
				{x : 640, y : 64, w : 192, h : 512, type : 0},
				{x : 256, y : 128, w : 256, h : 64, type : 1},
				{x : -128, y : 576, w : 128, h : 64, type : 2},
				{x : -192, y : -320, w : 64, h : 960, type : 0},
				{x : 960, y : 128, w : 256, h : 64, type : 1},
				{x : 832, y : 384, w : 192, h : 64, type : 1},
				{x : 1152, y : 384, w : 192, h : 64, type : 1},
				{x : 1344, y : 192, w : 64, h : 384, type : 0},
				{x : 0, y : 576, w : 1408, h : 64, type : 0},
				{x : 1408, y : 576, w : 128, h : 64, type : 2},
				{x : 1536, y : -320, w : 64, h : 960, type : 0},
				{x : -192, y : -384, w : 1792, h : 64, type : 0},
				{x : 192, y : 256, w : 64, h : 64, type : 3},
				{x : 1216, y : 256, w : 64, h : 64, type : 4},
				{x : 512, y : 256, w : 64, h : 64, type : 5},
				{x : 896, y : 256, w : 64, h : 64, type : 6},
				{x : 320, y : 448, w : 64, h : 64, type : 7},
				{x : 1088, y : 448, w : 64, h : 64, type : 8},
				{x : 320, y : 0, w : 64, h : 64, type : 9},
				{x : 1088, y : 0, w : 64, h : 64, type : 10}];
	}

	private static inline function Field() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 960, type : 0},
				{x : 64, y : 768, w : 576, h : 192, type : 1},
				{x : 640, y : 704, w : 64, h : 256, type : 0},
				{x : 704, y : 704, w : 704, h : 256, type : 1},
				{x : 896, y : 576, w : 192, h : 64, type : 1},
				{x : 1088, y : 448, w : 192, h : 64, type : 1},
				{x : 896, y : 320, w : 192, h : 64, type : 1},
				{x : 1408, y : 704, w : 64, h : 256, type : 0},
				{x : 1472, y : 768, w : 256, h : 192, type : 1},
				{x : 1728, y : 704, w : 128, h : 256, type : 2},
				{x : 1856, y : 768, w : 256, h : 192, type : 1},
				{x : 1728, y : 192, w : 128, h : 384, type : 0},
				{x : 0, y : -64, w : 2112, h : 64, type : 0},
				{x : 2112, y : -64, w : 64, h : 1024, type : 0},
				{x : 704, y : 576, w : 64, h : 64, type : 3},
				{x : 1344, y : 576, w : 64, h : 64, type : 4},
				{x : 960, y : 192, w : 64, h : 64, type : 5},
				{x : 1152, y : 320, w : 64, h : 64, type : 6},
				{x : 1600, y : 640, w : 64, h : 64, type : 7},
				{x : 128, y : 640, w : 64, h : 64, type : 8},
				{x : 448, y : 640, w : 64, h : 64, type : 9},
				{x : 1984, y : 640, w : 64, h : 64, type : 10}];
	}

	private static inline function Hill() : Array<Placeable>
	{
		return [{x : 0, y : 448, w : 960, h : 192, type : 2},
				{x : 0, y : -832, w : 64, h : 1280, type : 0},
				{x : 896, y : -832, w : 64, h : 1280, type : 0},
				{x : 0, y : -896, w : 960, h : 64, type : 0},
				{x : 64, y : 256, w : 192, h : 192, type : 1},
				{x : 704, y : 256, w : 192, h : 192, type : 1},
				{x : 256, y : 64, w : 448, h : 384, type : 1},
				{x : 64, y : -128, w : 192, h : 64, type : 1},
				{x : 704, y : -128, w : 192, h : 64, type : 1},
				{x : 256, y : -256, w : 448, h : 64, type : 1},
				{x : 128, y : 128, w : 64, h : 64, type : 3},
				{x : 768, y : 128, w : 64, h : 64, type : 4},
				{x : 320, y : -64, w : 64, h : 64, type : 5},
				{x : 576, y : -64, w : 64, h : 64, type : 6},
				{x : 768, y : -256, w : 64, h : 64, type : 7},
				{x : 128, y : -256, w : 64, h : 64, type : 8},
				{x : 320, y : -384, w : 64, h : 64, type : 9},
				{x : 576, y : -384, w : 64, h : 64, type : 10}];
	}

	private static inline function Decline() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 640, type : 0},
				{x : 64, y : 64, w : 64, h : 576, type : 0},
				{x : 128, y : 128, w : 64, h : 512, type : 0},
				{x : 192, y : 192, w : 64, h : 448, type : 0},
				{x : 256, y : 256, w : 64, h : 384, type : 0},
				{x : 320, y : 320, w : 64, h : 320, type : 0},
				{x : 384, y : 384, w : 64, h : 256, type : 0},
				{x : 448, y : 448, w : 64, h : 192, type : 0},
				{x : 512, y : 512, w : 64, h : 128, type : 0},
				{x : 576, y : 576, w : 64, h : 64, type : 0},
				{x : 640, y : 576, w : 64, h : 64, type : 0},
				{x : 704, y : 576, w : 64, h : 64, type : 0},
				{x : 768, y : 576, w : 64, h : 64, type : 0},
				{x : 832, y : 576, w : 64, h : 64, type : 0},
				{x : 896, y : 512, w : 64, h : 128, type : 0},
				{x : 960, y : 448, w : 64, h : 192, type : 0},
				{x : 1024, y : 384, w : 64, h : 256, type : 0},
				{x : 1088, y : 320, w : 64, h : 320, type : 0},
				{x : 1152, y : 256, w : 64, h : 384, type : 0},
				{x : 1216, y : 192, w : 64, h : 448, type : 0},
				{x : 1280, y : 128, w : 64, h : 512, type : 0},
				{x : 1344, y : 64, w : 64, h : 576, type : 0},
				{x : 1408, y : 0, w : 64, h : 640, type : 0},
				{x : 0, y : -64, w : 1472, h : 64, type : 0},
				{x : 256, y : 64, w : 64, h : 64, type : 3},
				{x : 384, y : 192, w : 64, h : 64, type : 5},
				{x : 512, y : 320, w : 64, h : 64, type : 7},
				{x : 640, y : 448, w : 64, h : 64, type : 9},
				{x : 768, y : 448, w : 64, h : 64, type : 10},
				{x : 896, y : 320, w : 64, h : 64, type : 8},
				{x : 1024, y : 192, w : 64, h : 64, type : 6},
				{x : 1152, y : 64, w : 64, h : 64, type : 4}];
	}

	private static inline function Incline() : Array<Placeable>
	{
		return [{x : 0, y : 0, w : 64, h : 640, type : 0},
				{x : 64, y : 576, w : 64, h : 64, type : 0},
				{x : 128, y : 576, w : 64, h : 64, type : 0},
				{x : 192, y : 576, w : 64, h : 64, type : 0},
				{x : 256, y : 576, w : 64, h : 64, type : 0},
				{x : 320, y : 576, w : 64, h : 64, type : 0},
				{x : 384, y : 512, w : 64, h : 128, type : 0},
				{x : 448, y : 448, w : 64, h : 192, type : 0},
				{x : 512, y : 384, w : 64, h : 256, type : 0},
				{x : 576, y : 320, w : 64, h : 320, type : 0},
				{x : 640, y : 256, w : 64, h : 384, type : 0},
				{x : 704, y : 192, w : 64, h : 448, type : 0},
				{x : 768, y : 192, w : 64, h : 448, type : 0},
				{x : 832, y : 256, w : 64, h : 384, type : 0},
				{x : 896, y : 320, w : 64, h : 320, type : 0},
				{x : 960, y : 384, w : 64, h : 256, type : 0},
				{x : 1024, y : 448, w : 64, h : 192, type : 0},
				{x : 1088, y : 512, w : 64, h : 128, type : 0},
				{x : 1152, y : 576, w : 64, h : 64, type : 0},
				{x : 1216, y : 576, w : 64, h : 64, type : 0},
				{x : 1280, y : 576, w : 64, h : 64, type : 0},
				{x : 1344, y : 576, w : 64, h : 64, type : 0},
				{x : 1408, y : 576, w : 64, h : 64, type : 0},
				{x : 1472, y : 0, w : 64, h : 640, type : 0},
				{x : 0, y : -64, w : 1536, h : 64, type : 0},
				{x : 128, y : 448, w : 64, h : 64, type : 3},
				{x : 1344, y : 448, w : 64, h : 64, type : 4},
				{x : 256, y : 448, w : 64, h : 64, type : 5},
				{x : 1216, y : 448, w : 64, h : 64, type : 6},
				{x : 448, y : 256, w : 64, h : 64, type : 7},
				{x : 576, y : 128, w : 64, h : 64, type : 9},
				{x : 896, y : 128, w : 64, h : 64, type : 10},
				{x : 1024, y : 256, w : 64, h : 64, type : 8}];
	}
}