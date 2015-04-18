import LevelEditor;

class GameLevel extends LevelMap
{
	public static inline var LEVEL_NUM = 4;

	public function new(index : UInt = 0)
	{
		super(getLevel(index));
		name = getName(index);
	}

	public static function getName(index : UInt) : String
	{
		return switch(index % LEVEL_NUM)
		{
			case 1: "Battlefield";
			case 2: "Big Battlefield";
			case 3: "Fire Pit";
			default: "Cage";
		}
	}

	private static function getLevel(index : UInt) : Array<Placeable>
	{
		return switch(index % LEVEL_NUM)
		{
			case 1: Battlefield();
			case 2: BigBattlefield();
			case 3: Norfair();
			default: FinalDestination();
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

	private static function FinalDestination() : Array<Placeable>
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

	private static function Norfair() : Array<Placeable>
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
}