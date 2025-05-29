package flxanimate.data;

import flxanimate.effects.*;
import flxanimate.motion.AdjustColor;
import flixel.util.FlxDirection;
import flixel.util.FlxColor;
import openfl.geom.ColorTransform;
import openfl.filters.*;

@:noCompletion
class AnimationData
{

	// public static var internalParam:EReg = ~/_FA{/;

	// public static var bracketReg:EReg = ~/(\{([^{}]|(?R))*\})/s;.

	/**
	 * Checks a value, using `Reflection`.
	 * @param abstracto The abstract in specific.
	 * @param things The fields you want to use.
	 * @param set What value you want to set.
	 * @return The value in specific casted as `Dynamic`.
	 */
	public static function setFieldBool(abstracto:Dynamic, things:Array<String>, ?set:Dynamic):Dynamic
	{
		//TODO: The comment below this comment.
		// GeoKureli told me that Reflect is shit, but I have literally no option but to use this.
		// If I have another thing to use that works the same, should replace this lol
		if (abstracto == null)
			return Reflect.field({}, "");
		for (thing in things)
		{
			if (set != null)
			{
				Reflect.setField(abstracto, thing, set);
				return set;
			}
			if (Reflect.hasField(abstracto, thing))
			{
				return Reflect.field(abstracto, thing);
			}
		}
		return Reflect.field(abstracto, "");
	}
	/**
	 * Parses a Color Effect from a JSON file into a enumeration of `ColorEffect`.
	 * @param effect The json field.
	 */
	public static function fromColorJson(effect:ColorEffects = null)
	{
		var colorEffect = None;

		if (effect == null) return colorEffect;

		switch (effect.M)
		{
			case Tint, "Tint":
				colorEffect = Tint(colorFromString(effect.TC), effect.TM);
			case Alpha, "Alpha":
				colorEffect = Alpha(effect.AM);
			case Brightness, "Brightness":
				colorEffect = Brightness(effect.BRT);
			case Advanced, "Advanced":
			{
				var CT = new ColorTransform();
				CT.redMultiplier = effect.RM;
				CT.redOffset = effect.RO;
				CT.greenMultiplier = effect.GM;
				CT.greenOffset = effect.GO;
				CT.blueMultiplier = effect.BM;
				CT.blueOffset = effect.BO;
				CT.alphaMultiplier = effect.AM;
				CT.alphaOffset = effect.AO;
				colorEffect = Advanced(CT);
			}
			default:
				flixel.FlxG.log.error('color Effect mode "${effect.M}" is invalid or not supported!');
		}
		return colorEffect;
	}
	static function colorFromString(color:String)
	{
		return Std.parseInt( "0x" + color.substring(1));
	}

	/**
	 * Parses a filter from a JSON file into a `BitmapFilter`
	 * @param filters The JSON field.
	 */
	public static function fromFilterJson(filters:Filters = null)
	{
		if (filters == null) return null;

		var bitmapFilter:Array<BitmapFilter> = [];

		for (filter in Reflect.fields(filters))
		{
			switch (filter.split("_")[0])
			{
				case "DSF", "DropShadowFilter":
				{
					var drop:DropShadowFilter = Reflect.field(filters, filter);
					bitmapFilter.unshift(new openfl.filters.DropShadowFilter(drop.DST, drop.AL, colorFromString(drop.C), drop.A, drop.BLX, drop.BLY, drop.STR, drop.Q, drop.IN, drop.KK));
				}
				case "GF", "GlowFilter":
				{
					var glow:GlowFilter = Reflect.field(filters, filter);
					bitmapFilter.unshift(new openfl.filters.GlowFilter(colorFromString(glow.C), glow.A, glow.BLX, glow.BLY, glow.STR, glow.Q, glow.IN, glow.KK));
				}
				case "BF", "BevelFilter": // Friday Night Funkin reference ?!??!?!''1'!'?1'1''?1''
				{
					var bevel:BevelFilter = Reflect.field(filters, filter);
					bitmapFilter.unshift(new flxanimate.filters.BevelFilter(bevel.DST, bevel.AL, colorFromString(bevel.HC), bevel.HA, colorFromString(bevel.SC), bevel.SA, bevel.BLX, bevel.BLY, bevel.STR, bevel.Q, bevel.TP, bevel.KK));
				}
				case "BLF", "BlurFilter":
				{
					var blur:BlurFilter = Reflect.field(filters, filter);
					bitmapFilter.unshift(new openfl.filters.BlurFilter(blur.BLX, blur.BLY, blur.Q));
				}
				case "ACF", "AdjustColorFilter":
				{
					var adjustColor:AdjustColorFilter = Reflect.field(filters, filter);

					var colorAdjust = new AdjustColor();

					colorAdjust.hue = adjustColor.H;
					colorAdjust.brightness = adjustColor.BRT;
					colorAdjust.contrast = adjustColor.CT;
					colorAdjust.saturation = adjustColor.SAT;

					bitmapFilter.unshift(new openfl.filters.ColorMatrixFilter(colorAdjust.calculateFinalFlatArray()));
				}

				case "GGF", "GradientGlowFilter":
				{
					var gradient:GradientFilter = Reflect.field(filters, filter);
					var colors:Array<Int> = [];
					var alphas:Array<Float> = [];
					var ratios:Array<Int> = [];

					for (entry in gradient.GE)
					{
						colors.push(colorFromString(entry.C));
						alphas.push(entry.A);
						ratios.push(Std.int(entry.R * 255));
					}


					bitmapFilter.unshift(new flxanimate.filters.GradientGlowFilter(gradient.DST, gradient.AL, colors, alphas, ratios, gradient.BLX, gradient.BLY, gradient.STR, gradient.Q, gradient.TP, gradient.KK));
				}
				case "GBF", "GradientBevelFilter":
				{
					var gradient:GradientFilter = Reflect.field(filters, filter);
					var colors:Array<Int> = [];
					var alphas:Array<Float> = [];
					var ratios:Array<Int> = [];

					for (entry in gradient.GE)
					{
						colors.push(colorFromString(entry.C));
						alphas.push(entry.A);
						ratios.push(Math.round(entry.R * 255));
					}


					bitmapFilter.unshift(new flxanimate.filters.GradientBevelFilter(gradient.DST, gradient.AL, colors, alphas, ratios, gradient.BLX, gradient.BLY, gradient.STR, gradient.Q, gradient.TP, gradient.KK));
				}
			}
		}

		return bitmapFilter;
	}
	/**
	 * Transforms a `ColorEffect` into a `ColorTransform`.
	 * @param colorEffect The `ColorEffect`.
	 */
	public static function parseColorEffect(colorEffect:ColorEffect = None)
	{
		var CT = null;

		//if ([None, null].indexOf(colorEffect) == -1)
		if(colorEffect != None && colorEffect != null)
		{
			var params = colorEffect.getParameters();
			CT = switch (colorEffect.getName())
			{
				case "Tint": new FlxTint(params[0], params[1]);
				case "Alpha": new FlxAlpha(params[0]);
				case "Brightness": new FlxBrightness(params[0]);
				case "Advanced": new FlxAdvanced(params[0]);
				default: new FlxColorEffect();
			}
		}


		return CT;
	}
}
/**
 * The types of Color Effects the symbol can have.
 */
enum ColorEffect
{
	None;
	Brightness(Bright:Float);
	Tint(Color:flixel.util.FlxColor, Opacity:Float);
	Alpha(Alpha:Float);
	Advanced(transform:ColorTransform);
}
/**
 * The looping method for the current symbol.
 */
enum Loop
{
	Loop;
	PlayOnce;
	SingleFrame;
}
/**
 * The type the symbol can be.
 */
enum SymbolT
{
	Graphic;
	MovieClip;
	Button;
}
/**
 * The type of behaviour `FlxLayer` can become.
 */
enum LayerType
{
	Normal;
	Clipper;
	Clipped(layer:String);
	Folder;
}

/**
 * The main structure of a basic Animation file in the texture atlas.
 */
abstract AnimAtlas(AnimAtlasData) from AnimAtlasData
{
	/**
	 * The main thing, the animation that makes the different drawings animate together and shit
	 */
	public var AN(get, never):Animation;
	/**
	 * This is where all the symbols that the main animation uses are stored. Can be `null`!
	 */
	public var SD(get, never):SymbolDictionary;
	/**
	 * A metadata, consisting of the framerate the document had been exported.
	 */
	public var MD(get, never):MetaData;

	inline function get_AN():Animation
	{
		return this.AN ?? this.ANIMATION;
	}

	inline function get_MD():MetaData
	{
		return this.MD ?? this.metadata;
	}
	inline function get_SD()
	{
		return this.SD ?? this.SYMBOL_DICTIONARY;
	}
}

typedef AnimAtlasData = {
	?AN:Animation,
	?ANIMATION:Animation,
	?MD:MetaData,
	?metadata:MetaData,
	?SD:SymbolDictionary,
	?SYMBOL_DICTIONARY:SymbolDictionary
}
/**
 * An `Array` of multiple symbols. All symbols in the Dictionary are supposedly used in the main Animation or in other symbols.
 */
abstract SymbolDictionary(SymbolDictionaryData) from SymbolDictionaryData
{
	/**
	 * The list of symbols.
	 */
	public var S(get, never):Array<Symbol>;

	inline function get_S():Array<Symbol>
	{
		return this.S ?? this.Symbols;
	}
}

typedef SymbolDictionaryData = {
	?S:Array<Symbol>,
	?Symbols:Array<Symbol>
}

abstract Animation(AnimationTypeData) from AnimationTypeData
{
	/**
	 * The name of the Flash document the texture atlas was exported with.
	 */
	public var N(get, never):String;
	/**
	 * The Stage Instance. This represents the element settings the texture atlas was exported when clicking on-stage
	 * **WARNING:** if you export the texture atlas inside the symbol dictionary, this field won't appear, meaning it can be `null`.
	 */
	public var STI(get, never):StageInstance;

	/**
	 * The name of the symbol.
	 */
	public var SN(get, never):String;

	/**
	 * The timeline of the Symbol.
	 */
	public var TL(get, never):Timeline;

	

	inline function get_N():String
	{
		return this.N ?? this.name;
	}

	inline function get_STI()
	{
		return this.STI ?? this.StageInstance;
	}

	inline function get_SN():String
	{
		return this.SN ?? this.SYMBOL_name;
	}

	inline function get_TL():Timeline
	{
		return this.TL ?? this.TIMELINE;
	}
}

typedef AnimationTypeData = {
	?N:String,
	?name:String,
	?STI:StageInstance,
	?StageInstance:StageInstance,
	?SN:String,
	?SYMBOL_name:String,
	?TL:Timeline,
	?TIMELINE:Timeline
}

/**
 * The main position how the symbol you exported was set, Acting almost identically as an `Element`, with the exception of not having an Atlas Sprite to call (not that I'm aware of).
 * **WARNING:** This may depend on how you exported your texture atlas, Meaning that this can be `null`
 */
abstract StageInstance(StageInstanceData) from StageInstanceData
{
	/**
	 * The instance of the Element flagged as a `Symbol`.
	 * **WARNING:** This can be `null`!
	 */
	public var SI(get, never):SymbolInstance;

	inline function get_SI():SymbolInstance
	{
		return this.SI ?? this.SYMBOL_Instance;
	}
}


typedef StageInstanceData = {
	?SI:SymbolInstance,
	?SYMBOL_Instance:SymbolInstance
}

/**
 * A small Symbol specifier, consisting of the name of the Symbol and its timeline.
 */
abstract Symbol(SymbolData) from SymbolData
{
	/**
	 * The name of the symbol.
	 */
	public var SN(get, never):String;
	/**
	 * The timeline of the Symbol.
	 */
	public var TL(get, never):Timeline;

	inline function get_SN():String
	{
		return this.SN ?? this.SYMBOL_name;
	}

	inline function get_TL():Timeline
	{
		return this.TL ?? this.TIMELINE;
	}
}

typedef SymbolData = {
	?SN:String,
	?SYMBOL_name:String,
	?TL:Timeline,
	?TIMELINE:Timeline
}

/**
 * The main timeline of the symbol.
 */
abstract Timeline(TimelineData) from TimelineData
{
	/**
	 * An `Array` that goes in a inverted order, from the bottom to the top.
	 */
	public var L(get, set):Array<Layers>;

	inline function get_L():Array<Layers>
	{
		return this.L ?? this.LAYERS;
	}
	function set_L(value:Array<Layers>)
	{
		if (this.L != null)
			return this.L = value;
		else 
			return this.LAYERS = value;
	}
}

typedef TimelineData = {
	?L:Array<Layers>,
	?LAYERS:Array<Layers>
}

/**
 * A layer instance inside the `Timeline`.
 */
abstract Layers(LayersData) from LayersData
{
	/**
	 * The name of the layer.
	 */
	public var LN(get, never):String;
	/**
	 * Type of layer, It's usually to indicate that the Layer is a mask or is masked.
	 */
	public var LT(get, never):String;
	/**
	 * if the layer is masked, this field will appear to explain which layer is being clipped to, usually the next one.
	 */
	public var Clpb(get, never):String;
	/**
	 * An `Array` of KeyFrames inside the layer.
	 */
	public var FR(get, set):Array<Frame>;

	inline function get_LN():String
	{
		return this.LN ?? this.Layer_name;
	}
	inline function get_LT():String
	{
		return this.LT ?? this.Layer_type;
	}
	inline function get_Clpb():String
	{
		return this.Clpb ?? this.Clipped_by;
	}
	inline function get_FR():Array<Frame>
	{
		return this.FR ?? this.Frames;
	}
	function set_FR(value:Array<Frame>):Array<Frame>
	{
		if (this.FR != null)
			return this.FR = value;
		else
			return this.Frames = value;
	}
}

typedef LayersData = {
	?LN:String,
	?Layer_name:String,
	?LT:String,
	?Layer_type:String,
	?Clpb:String,
	?Clipped_by:String,
	?FR:Array<Frame>,
	?Frames:Array<Frame>,

}

/**
 * The metadata, consisting of a single variable to indicate the framerate the texture atlas was exported with.
 */
abstract MetaData(MetaDataTypeData) from MetaDataTypeData
{

	/**
	 * The framerate.
	 */
	public var FRT(get, never):Float;

	inline function get_FRT()
	{
		return this.FRT ?? this.framerate;
	}
}

typedef MetaDataTypeData = {
	?FRT:Float,
	?framerate:Float
}
/**
 * A KeyFrame with everything essential + labels and ColorEffects/Filters.
 */
abstract Frame(FrameData) from FrameData
{
	/**
	 * The "name of the frame", basically labels that you can use as thingies for more cool stuff to program lol
	 */
	public var N(get, never):String;
	/**
	 * The frame index, aka the current number frame.
	 */
	public var I(get, never):Int;
	/**
	 * The duration of the frame.
	 */
	public var DU(get, never):Int;
	/**
	 * The elements that the frame has. Drawings/symbols to be specific
	 */
	public var E(get, never):Array<Element>;

	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, set):ColorEffects;

	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;

	inline function get_N():String
	{
		return this.N ?? this.name;
	}

	inline function get_I():Int
	{
		return this.I ?? this.index;
	}

	inline function get_DU():Int
	{
		return this.DU ?? this.duration;
	}

	inline function get_E():Array<Element>
	{
		return this.E ?? this.elements;
	}

	inline function get_C():ColorEffects
	{
		return this.C ?? this.color;
	}

	function set_C(value:ColorEffects)
	{
		if (this.C != null)
			return this.C = value;
		else
			return this.color = value;
	}

	inline function get_F():Filters
	{
		return this.F ?? this.filters;
	}
}

typedef FrameData =
{
	var ?N:String;
	var ?name:String;
	var ?I:Int;
	var ?index:Int;
	var ?DU:Int;
	var ?duration:Int;
	var ?E:Array<Element>;
	var ?elements:Array<Element>;
	var ?C:ColorEffects;
	var ?color:ColorEffects;
	var ?F:Filters;
	var ?filters:Filters;
}
/**
 * The Element thing inside the frame
 */
@:forward
abstract Element(ElementData) from ElementData
{
	/*
	 * the Sprite of the animation, aka the non Symbol.
	 */
	public var ASI(get, never):AtlasSymbolInstance;

	public var SI(get, never):SymbolInstance;

	inline function get_SI():SymbolInstance
	{
		return this.SI ?? this.SYMBOL_Instance;
	}

	inline function get_ASI():AtlasSymbolInstance
	{
		return this.ASI ?? this.ATLAS_SPRITE_instance;
	}
}

typedef ElementData = StageInstanceData & {
	?ASI:AtlasSymbolInstance,
	?ATLAS_SPRITE_instance:AtlasSymbolInstance
}

/**
 * The Symbol Abstract
 */
abstract SymbolInstance(SymbolInstanceData) from SymbolInstanceData
{
	/**
	 * the name of the symbol.
	 */
	public var SN(get, never):String;

	/**
	 * the name instance of the Symbol.
	 */
	public var IN(get, never):String;
	/**
	 * the type of symbol,
	 * Which can be a:
	 * - Graphic
	 * - MovieClip
	 * - Button
	 */
	public var ST(get, never):SymbolType;

	/**
	 * bitmap Settings, Used in 2018 and 2019
	 */
	public var bitmap(get, never):Bitmap;

	/**
	 * this sets on which frame it's the symbol, Graphic only
	 */
	public var FF(get, never):Int;
	/**
	 * the Loop Type of the symbol, which can be:
	 * - Loop
	 * - Play Once
	 * - Single Frame
	 */
	public var LP(get, never):LoopType;
	/**
	 * the Transformation Point of the symbol, basically the pivot that determines how it scales or not in Flash
	 */
	public var TRP(get, never):TransformationPoint;
	/**
	 * The Matrix of the Symbol, Be aware from Neo! He can be anywhere!!! :fearful:
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;
	/**
	 * The Color Effect of the symbol, it says color but it affects alpha too lol.
	 */
	public var C(get, set):ColorEffects;

	/**
	 * Filter stuff, this is the reason why you can't add custom shaders, srry
	 */
	public var F(get, never):Filters;

	inline function get_SN()
	{
		return this.SN ?? this.SYMBOL_name;
	}

	inline function get_IN()
	{
		return this.IN ?? this.Instance_Name;
	}

	inline function get_ST()
	{
		return this.ST ?? this.symbolType;
	}

	inline function get_bitmap()
	{
		return this.BM ?? this.bitmap;
	}
	inline function get_FF()
	{
		var ff:Null<Int> = this.FF ?? this.firstFrame;
		return (ff == null) ? 0 : ff;
	}

	inline  function get_LP()
	{
		return this.LP ?? this.loop;
	}

	inline function get_TRP()
	{
		return this.TRP ?? this.transformationPoint;
	}

	inline function get_M3D()
	{
		return this.M3D ?? this.Matrix3D;
	}

	inline function get_C()
	{
		return this.C ?? this.color;
	}
	inline function set_C(value:ColorEffects)
	{
		if (this.C != null)
			return this.C = value;
		else
			return this.color = value;
	}

	inline function get_F()
	{
		return this.F ?? this.filters;
	}
}

typedef SymbolInstanceData = {
	?SN:String,
	?SYMBOL_name:String,
	?IN:String,
	?Instance_Name:String,
	?ST:String,
	?symbolType:String,
	?BM:Bitmap,
	?bitmap:Bitmap,
	?FF:Int,
	?firstFrame:Int,
	?LP:String,
	?loop:String,
	?TRP:TransformationPoint,
	?transformationPoint:TransformationPoint,
	?M3D:OneOfTwo<Array<Float>, Matrix3D>,
	?Matrix3D:OneOfTwo<Array<Float>, Matrix3D>,
	?C:ColorEffects,
	?color:ColorEffects,
	?F:Filters,
	?filters:Filters
}


abstract ColorEffects(ColorEffectsData) from ColorEffectsData
{
	/**
	 * What type of Effect is it.
	 */
	public var M(get, never):ColorMode;
	/**
	 * tint Color, basically, How's the color gonna be lol.
	 */
	public var TC(get, never):String;
	/**
	 * tint multiplier, or the alpha of **THE COLOR!** Don't forget that.
	 */
	public var TM(get, never):Float;

	public var AM(get, never):Float;
	public var AO(get, never):Int;

	// Red Multiplier and Offset
	public var RM(get, never):Float;
	public var RO(get, never):Int;
	// Green Multiplier and Offset
	public var GM(get, never):Float;
	public var GO(get, never):Int;
	// Blue Multiplier and Offset
	public var BM(get, never):Float;
	public var BO(get, never):Int;

	public var BRT(get, never):Float;

	inline function get_M()
	{
		return this.M ?? this.mode;
	}
	inline function get_TC()
	{
		return this.TC ?? this.tintColor;
	}
	inline function get_TM()
	{
		return this.TM ?? this.tintMultiplier;
	}
	inline function get_AM()
	{
		return this.AM ?? this.alphaMultiplier;
	}
	inline function get_AO()
	{
		return this.AO ?? this.AlphaOffset;
	}
	inline function get_RM()
	{
		return this.RM ?? this.RedMultiplier;
	}
	inline function get_RO()
	{
		return this.RO ?? this.redOffset;
	}
	inline function get_GM()
	{
		return this.GM ?? this.greenMultiplier;
	}
	inline function get_GO()
	{
		return this.GO ?? this.greenOffset;
	}
	inline function get_BM()
	{
		return this.BM ?? this.blueMultiplier;
	}
	inline function get_BO()
	{
		return this.BO ?? this.blueOffset;
	}
	inline function get_BRT()
	{
		return this.BRT ?? this.Brightness;
	}
}

typedef ColorEffectsData = {
	?M:ColorMode,
	?mode:ColorMode,
	?TC:String,
	?tintColor:String,
	?TM:Float,
	?tintMultiplier:Float,
	?AM:Float,
	?alphaMultiplier:Float,
	?AO:Int,
	?AlphaOffset:Int,
	?RM:Float,
	?RedMultiplier:Float,
	?RO:Int,
	?redOffset:Int,
	?GM:Float,
	?greenMultiplier:Float,
	?GO:Int,
	?greenOffset:Int,
	?BM:Float,
	?blueMultiplier:Float,
	?BO:Int,
	?blueOffset:Int,
	?BRT:Float,
	?Brightness:Float
}

abstract Filters(FiltersData) from FiltersData
{
	/**
	 * Adjust Color filter is a workaround to give some color adjustment, including hue-rotation, saturation, brightness and contrast.
	 * After calculating every required adjustment, it gets the matrix and then the filter is applied as a `ColorMatrixFilter`.
	 * @see flxanimate.motion.AdjustColor
	 * @see flxanimate.motion.ColorMatrix
	 * @see flxanimate.motion.DynamicMatrix
	 * @see openfl.filters.ColorMatrixFilter
	 */
	public var ACF(get, never):AdjustColorFilter;

	public var GF(get, never):GlowFilter;

	inline function get_ACF()
	{
		return this.ACF ?? this.AdjustColorFilter;
	}
	inline function get_GF()
	{
		// does this glowfilter have an accompyaning alias?
		return this.GF;
	}
}

typedef FiltersData = {
	?ACF:AdjustColorFilter,
	?AdjustColorFilter:AdjustColorFilter,
	?GF:GlowFilter
}

/**
 * A full matrix calculation thing that seems to behave like a special HSV adjust.
 */
abstract AdjustColorFilter(AdjustColorFilterData) from AdjustColorFilterData
{
	/**
	 * The brightness value. Can be from -100 to 100
	 */
	public var BRT(get, never):Float;
	/**
	 * The value of contrast. Can be from -100 to 100
	 */
	public var CT(get, never):Float;
	/**
	 * The value of saturation. Can be from -100 to 100
	 */
	public var SAT(get, never):Float;
	/**
	 * The hue value. Can be from -180 to 180
	 */
	public var H(get, never):Float;

	inline function get_BRT()
	{
		return this.BRT ?? this.brightness;
	}
	inline function get_CT()
	{
		return this.CT ?? this.contrast;
	}
	inline function get_SAT()
	{
		return this.SAT ?? this.saturation;
	}
	inline function get_H()
	{
		return this.H ?? this.hue;
	}
}

typedef AdjustColorFilterData = { 
	?BRT:Float,
	?brightness:Float,
	?CT:Float,
	?contrast:Float,
	?SAT:Float,
	?saturation:Float,
	?H:Float,
	?hue:Float
}

/**
 * This blur filter gives instructions of how the blur should be applied onto the symbol/frame.
 */
abstract BlurFilter(BlurFilterData) from BlurFilterData
{
	/**
	 * The amount of blur horizontally.
	 */
	public var BLX(get, never):Float;
	/**
	 * The amount of blur vertically.
	 */
	public var BLY(get, never):Float;
	/**
	 * The number of passes the filter has.
	 * When the quality is set to three, it should approximate to a Gaussian Blur.
	 * Obviously you can go beyond three, but it'll take more time to render.
	 */
	public var Q(get, never):Int;

	inline function get_BLX()
	{
		return this.BLX ?? this.blurX;
	}
	inline function get_BLY()
	{
		return this.BLY ?? this.blurY;
	}
	inline function get_Q()
	{
		return this.Q ?? this.quality;
	}
}

typedef BlurFilterData = {
	?BLX:Float,
	?blurX:Float,
	?BLY:Float,
	?blurY:Float,
	?Q:Int,
	?quality:Int
}

// Note: through the code there's these repeated variables! Previously these were @:forward'ed
// but idk how to do that lol ! So we just copy-paste...
abstract GlowFilter(GlowFilterData)
{
	// See BlurFilter 
	public var BLX(get, never):Float;
	public var BLY(get, never):Float;
	public var Q(get, never):Int;

	
	public var C(get, never):String;
	public var A(get, never):Float;
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var IN(get, never):Bool;

	inline function get_BLX()
	{
		return this.BLX ?? this.blurX;
	}

	inline function get_BLY()
	{
		return this.BLY ?? this.blurY;
	}

	inline function get_Q()
	{
		return this.Q ?? this.quality;
	}

	inline function get_C()
	{
		return this.C ?? this.color;
	}
	inline function get_A()
	{
		return this.A ?? this.alpha;
	}
	inline function get_STR()
	{
		return this.STR ?? this.strength;
	}
	inline function get_KK()
	{
		return this.KK ?? this.knockout;
	}
	inline function get_IN()
	{
		return this.IN ?? this.inner;
	}
}

typedef GlowFilterData = BlurFilterData & {
	?C:String,
	?color:String,
	?A:Float,
	?alpha:Float,
	?STR:Float,
	?strength:Float,
	?KK:Bool,
	?knockout:Bool,
	?IN:Bool,
	?inner:Bool
}

abstract DropShadowFilter(DropShadowFilterData)
{
	// blur variables
	public var BLX(get, never):Float;
	public var BLY(get, never):Float;
	public var Q(get, never):Int;

	// glow filter variables
	public var C(get, never):String;
	public var A(get, never):Float;
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var IN(get, never):Bool;

	// dropshadow variables
	public var HO(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;

	inline function get_BLX()
	{
		return this.BLX ?? this.blurX;
	}

	inline function get_BLY()
	{
		return this.BLY ?? this.blurY;
	}

	inline function get_Q()
	{
		return this.Q ?? this.quality;
	}

	inline function get_C()
	{
		return this.C ?? this.color;
	}

	inline function get_A()
	{
		return this.A ?? this.alpha;
	}

	inline function get_STR()
	{
		return this.STR ?? this.strength;
	}

	inline function get_KK()
	{
		return this.KK ?? this.knockout;
	}

	inline function get_IN()
	{
		return this.IN ?? this.inner;
	}

	inline function get_HO()
	{
		return this.HO ?? this.hideObject;
	}
	inline function get_AL()
	{
		return this.AL ?? this.angle;
	}
	inline function get_DST()
	{
		return this.DST ?? this.distance;
	}
}

typedef DropShadowFilterData = GlowFilterData & {
	?HO:Bool,
	?hideObject:Bool,
	?AL:Float,
	?angle:Float,
	?DST:Float,
	?distance:Float
}

abstract BevelFilter(BevelFilterData) from BevelFilterData
{
	public var BLX(get, never):Float;
	public var BLY(get, never):Float;
	public var Q(get, never):Int;

	public var SC(get, never):String;
	public var SA(get, never):Float;
	public var HC(get, never):String;
	public var HA(get, never):Float;
	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;
	public var TP(get, never):String;

	inline function get_BLX()
		return this.BLX ?? this.blurX;

	inline function get_BLY()
		return this.BLY ?? this.blurY;

	inline function get_Q()
		return this.Q ?? this.quality;

	inline function get_SC()
	{
		return this.SC ?? this.shadowColor;
	}
	inline function get_SA()
	{
		return this.SA ?? this.shadowAlpha;
	}
	inline function get_HC()
	{
		return this.HC ?? this.highlightColor;
	}

	inline function get_HA()
	{
		return this.HA ?? this.highlightAlpha;
	}
	inline function get_STR()
	{
		return this.STR ?? this.strength;
	}
	inline function get_KK()
	{
		return this.KK ?? this.knockout;
	}
	inline function get_AL()
	{
		return this.AL ?? this.angle;
	}
	inline function get_DST()
	{
		return this.DST ?? this.distance;
	}
	inline function get_TP()
	{
		return this.TP ?? this.type;
	}
}
typedef BevelFilterData = BlurFilterData & {
	?SC:String,
	?shadowColor:String,
	?SA:Float,
	?shadowAlpha:Float,
	?HC:String,
	?highlightColor:String,
	?HA:Float,
	?highlightAlpha:Float,
	?STR:Float,
	?strength:Float,
	?KK:Bool,
	?knockout:Bool,
	?AL:Float,
	?angle:Float,
	?DST:Float,
	?distance:Float,
	?TP:String,
	?type:String
}

abstract GradientFilter(GradientFilterData) from GradientFilterData
{
	public var BLX(get, never):Float;
	public var BLY(get, never):Float;
	public var Q(get, never):Int;

	public var STR(get, never):Float;
	public var KK(get, never):Bool;
	public var AL(get, never):Float;
	public var DST(get, never):Float;
	public var TP(get, never):String;
	public var GE(get, never):Array<GradientEntry>;

	inline function get_BLX()
		return this.BLX ?? this.blurX;

	inline function get_BLY()
		return this.BLY ?? this.blurY;

	inline function get_Q()
		return this.Q ?? this.quality;

	inline function get_STR()
	{
		return this.STR ?? this.strength;
	}
	inline function get_KK()
	{
		return this.KK ?? this.knockout;
	}
	inline function get_AL()
	{
		return this.AL ?? this.angle;
	}
	inline function get_DST()
	{
		return this.DST ?? this.distance;
	}
	inline function get_TP()
	{
		return this.TP ?? this.type;
	}
	inline function get_GE()
	{
		return this.GE ?? this.GradientEntries;
	}
}

typedef GradientFilterData = BlurFilterData & {
	?STR:Float,
	?strength:Float,
	?KK:Bool,
	?knockout:Bool,
	?AL:Float,
	?angle:Float,
	?DST:Float,
	?distance:Float,
	?TP:String,
	?type:String,
	?GE:Array<GradientEntry>,
	?GradientEntries:Array<GradientEntry>
}

abstract GradientEntry(GradientEntryData) from GradientEntryData
{
	public var R(get, never):Float;
	public var C(get, never):String;
	public var A(get, never):Float;


	inline function get_R()
	{
		return this.R ?? this.ratio;
	}
	inline function get_C()
	{
		return this.C ?? this.color;
	}
	inline function get_A()
	{
		return this.A ?? this.alpha;
	}

}

typedef GradientEntryData = {
	?R:Float,
	?ratio:Float,
	?C:String,
	?color:String,
	?A:Float,
	?alpha:Float
}

enum abstract ColorMode(String) from String to String
{
	var Tint = "T";
	var Advanced = "AD";
	var Alpha = "CA";
	var Brightness = "CBRT";
}

abstract Bitmap(BitmapTypeData) from BitmapTypeData
{
	/**
	 * The name of the drawing, basically determines which one of the sprites on spritemap should be used.
	 */
	public var N(get, never):String;

	/**
	 * Only used in earliest versions of texture atlas release. checks the position, nothing else lol
	 */
	public var POS(get, never):TransformationPoint;
	
	inline function get_N()
	{
		return this.N ?? this.name;
	}
	inline function get_POS()
	{
		return this.POS ?? this.Position;
	}
}

// This doesn't follow the naming convention of "abstractnameData" because it would be "BitmapData"
// Which could be confused for OpenFL's BitmapData class!
// note: unimplemented
typedef BitmapTypeData = {
	?N:String,
	?name:String,
	?POS:TransformationPoint,
	?Position:TransformationPoint
}

/**
 * The Sprite/Drawing abstract
 */
abstract AtlasSymbolInstance(AtlasSymbolInstanceData) from AtlasSymbolInstanceData
{
	/**
	 * The name of the drawing, basically determines which one of the sprites on spritemap should be used.
	 */
	public var N(get, never):String;

	/**
	 * Only used in earliest versions of texture atlas release. checks the position, nothing else lol
	 */
	public var POS(get, never):TransformationPoint;

	/**
	 * The matrix of the sprite itself. Can be either an array or a typedef.
	 */
	public var M3D(get, never):OneOfTwo<Array<Float>, Matrix3D>;


	inline function get_N()
	{
		return this.N ?? this.name;
	}

	inline function get_POS()
	{
		return this.POS ?? this.Position;
	}

	
	inline function get_M3D()
	{	
		return this.M3D ?? this.Matrix3D;
	}
}

typedef AtlasSymbolInstanceData = {
	?N:String,
	?name:String,
	?POS:TransformationPoint,
	?Position:TransformationPoint,
	?M3D:OneOfTwo<Array<Float>, Matrix3D>,
	?Matrix3D:OneOfTwo<Array<Float>, Matrix3D>
}

typedef Matrix3D =
{
	var m00:Float;
	var m01:Float;
	var m02:Float;
	var m03:Float;
	var m10:Float;
	var m11:Float;
	var m12:Float;
	var m13:Float;
	var m20:Float;
	var m21:Float;
	var m22:Float;
	var m23:Float;
	var m30:Float;
	var m31:Float;
	var m32:Float;
	var m33:Float;
}
/**
 * Position Stuff
 */
typedef TransformationPoint =
{
	var x:Float;
	var y:Float;
}

@:forward
enum abstract LoopType(String) from String to String
{
	var loop = "LP";
	var playonce = "PO";
	var singleframe = "SF";
}

enum abstract SymbolType(String) from String to String
{
	var graphic = "G";
	var movieclip = "MC";
	var button = "B";
}
@:forward
abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 {}