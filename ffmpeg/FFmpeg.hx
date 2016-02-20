package ffmpeg;

#if !cpp
    #error "ffmpeg is only available with haxe + hxcpp ( cpp target )."
#end

typedef FormatContext = cpp.Pointer<AVFormatContext>;
typedef CodecContext = cpp.Pointer<AVCodecContext>;
typedef InputFormat = cpp.Pointer<AVInputFormat>;

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
    static function describe_AVInputFormat(iformat : InputFormat) : Dynamic;
}

@:native("AVFormatContext")
@:include('linc_ffmpeg.h')
private extern class AVFormatContext { }


@:native("AVCodecContext")
@:include('linc_ffmpeg.h')
private extern class AVCodecContext { }

@:native("AVInputFormat")
@:include('linc_ffmpeg.h')
private extern class AVInputFormat {}
