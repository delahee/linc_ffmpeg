package ffmpeg;

#if (!cpp&&!display)
    #error "ffmpeg is only available with haxe + hxcpp ( cpp target )."
#end

@:keep
@:include('linc_ffmpeg.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('ffmpeg'))
#end

extern class FFmpeg
{
	@:native('avformat_alloc_context')
	public static function avformat_alloc_context() : cpp.Pointer<AVFormatContext>;
	
	@:native('linc::aveasy::describe_AVInputFormat')
    static function describe_AVInputFormat(iformat : cpp.Pointer<AVInputFormat>) : Dynamic;
}

@:native("AVFormatContext")
@:include('linc_ffmpeg.h')
extern class AVFormatContext { 
	var av_class :  cpp.ConstPointer<AVClass>;
	var iformat :  cpp.Pointer<AVInputFormat>;
	var oformat : cpp.Pointer<AVOutputFormat>;
	var ctx_flags : Int;
	var nb_streams : cpp.UInt32;
	var filename : cpp.ConstCharStar;
	
	var start_time : cpp.Int64;
	var duration : cpp.Int64;
	var bit_rate : cpp.Int64;
	var flags : Int;
}

@:native("AVCodecContext")
@:include('linc_ffmpeg.h')
extern class AVCodecContext { }

@:native("AVCodec")
@:include('linc_ffmpeg.h')
extern class AVCodec { }

@:native("AVFrame")
@:include('linc_ffmpeg.h')
extern class AVFrame { }

@:native("AVInputFormat")
@:include('linc_ffmpeg.h')
extern class AVInputFormat { }

@:native("AVClass")
@:include('linc_ffmpeg.h')
extern class AVClass { }

@:native("AVOutputFormat")
@:include('linc_ffmpeg.h')
extern class AVOutputFormat { }

@:native("SwsContext")
@:include('linc_ffmpeg.h')
extern class SwsContext { }

@:enum
abstract AVPixelFormat (Int){ 
	
}



