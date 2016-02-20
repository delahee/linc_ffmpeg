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
	public var iformat :  cpp.Pointer<AVInputFormat>;
	public var ctx_flags : Int;
}


@:native("AVCodecContext")
@:include('linc_ffmpeg.h')
private extern class AVCodecContext { }

@:native("AVInputFormat")
@:include('linc_ffmpeg.h')
private extern class AVInputFormat { }

@:native("AVClass")
@:include('linc_ffmpeg.h')
private extern class AVClass { }

@:native("AVOutputFormat")
@:include('linc_ffmpeg.h')
private extern class AVOutputFormat { }





