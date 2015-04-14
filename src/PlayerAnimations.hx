import PlayerAttributes;

class PlayerAnimations
{
	public static var standAnim : Array<Anim> =
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0},{x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
	{x : 6, y : 30, rot : 0}];

	public static var jumpAnim : Array<Anim> =
	[{x : 30, y : 6, rot : -Math.PI/4}, {x : 30, y : 58, rot : Math.PI/8},{x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : -Math.PI/4}, {x : 6, y : 58, rot : Math.PI/8},
	{x : 6, y : 30, rot : 0}];

	public static var fallAnim : Array<Anim> =
	[{x : 30, y : 6, rot : 0.43633231299858233}, {x : 34, y : 52, rot : -0.39269908169872414}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0.6108652381980153}, {x : 14, y : 56, rot : -0.39269908169872414},
	{x : 6, y : 30, rot : 0}];

	public static var stunAnim : Array<Anim> =
	[{x : 30, y : 6, rot : 0}, {x : 31, y : 52, rot : -0.34906585039886584}, {x : 37, y : 38, rot : 1.570796326794899},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 11, y : 53, rot : -0.34906585039886584},
	{x : 0, y : 41, rot : 1.570796326794899}];

	public static var walkAnim : Array<Array<Anim>> = [
	//0
	[{x : 30, y : 6, rot : 0}, {x : 37, y : 47, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
	{x : 6, y : 30, rot : 0}],

	//1
	[{x : 30, y : 6, rot : 0}, {x : 44, y : 45, rot : -0.6981317007977318}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : -3, y : 48, rot : 0.6981317007977318},
	{x : 6, y : 30, rot : 0}],

	//2
	[{x : 30, y : 6, rot : 0}, {x : 19, y : 58, rot : 5.551115123125783e-17}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 4, y : 48, rot : 1.5707963267948966},
	{x : 6, y : 30, rot : 0}],

	//3
	[{x : 30, y : 6, rot : 0}, {x : 11, y : 58, rot : 5.551115123125783e-17}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 17, y : 48, rot : 1.5707963267948966},
	{x : 6, y : 30, rot : 0}],

	//4
	[{x : 30, y : 6, rot : 0}, {x : 6, y : 58, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 37, y : 47, rot : 0},
	{x : 6, y : 30, rot : 0}],

	//5
	[{x : 30, y : 6, rot : 0}, {x : -3, y : 48, rot : 0.6981317007977318}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 44, y : 45, rot : -0.6981317007977318},
	{x : 6, y : 30, rot : 0}],

	//6
	[{x : 30, y : 6, rot : 0}, {x : 4, y : 48, rot : 1.5707963267948966}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 19, y : 58, rot : 5.551115123125783e-17},
	{x : 6, y : 30, rot : 0}],

	//7
	[{x : 30, y : 6, rot : 0}, {x : 17, y : 48, rot : 1.5707963267948966}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 11, y : 58, rot : 5.551115123125783e-17},
	{x : 6, y : 30, rot : 0}]
	];

	public static var lgPunchAnim : Array<Array<Anim>> =
	[

	//0
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 34, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 2, y : 54, rot : 0.5235987755982988},
	{x : -4, y : 30, rot : 0}],

	//1
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 2, y : 54, rot : 0.5235987755982988},
	{x : 11, y : 30, rot : 0}],

	//2
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 10, y : 54, rot : 0.5235987755982988},
	{x : 25, y : 30, rot : 0}],

	//3
	[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 17, y : 58, rot : -5.551115123125783e-17},
	{x : 41, y : 30, rot : 0}],

	//4
	[{x : 30, y : 6, rot : 0}, {x : 20, y : 58, rot : 0}, {x : 26, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 27, y : 58, rot : -5.551115123125783e-17},
	{x : 53, y : 30, rot : 0}],

	//5
	[{x : 30, y : 6, rot : 0}, {x : 13, y : 58, rot : 0}, {x : 6, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 31, y : 58, rot : -5.551115123125783e-17},
	{x : 58, y : 30, rot : 0}],

	//5
	[{x : 30, y : 6, rot : 0}, {x : 13, y : 58, rot : 0}, {x : 6, y : 30, rot : 0},
	{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 31, y : 58, rot : -5.551115123125783e-17},
	{x : 58, y : 30, rot : 0}],
	];

	public static var hgPunchAnim : Array<Array<Anim>>  =
	[
		//0
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 27, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -1, y : 30, rot : 0}],

		//1
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//2
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//3
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//4
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//5
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//6
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : -4, y : 26, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -11, y : 30, rot : 0}],

		//7
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 27, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : -1, y : 30, rot : 0}],

		//8
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 41, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 26, y : 30, rot : 0}],

		//9
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 54, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 41, y : 30, rot : 0}],

		//10
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 67, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 56, y : 30, rot : 0}],

		//11
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 67, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 56, y : 30, rot : 0}],

		//12
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 67, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 56, y : 30, rot : 0}],

		//13
		[{x : 30, y : 6, rot : 0}, {x : 30, y : 58, rot : 0}, {x : 54, y : 30, rot : 0},
		{x : 18, y : 29, rot : 0}, {x : 6, y : 6, rot : 0}, {x : 6, y : 58, rot : 0},
		{x : 41, y : 30, rot : 0}],
	];
}