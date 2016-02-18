package ffmpeg;

#if !cpp
    #error "ffmpeg is only available with haxe + hxcpp ( cpp target )."
#end

typedef Context = cpp.Pointer<AVFormatContext>;

@:keep
@:include('linc_ffmpeg.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('ffmpeg'))
#end

extern class FFmpeg
{
	@:native('avformat_alloc_context')
	public static function avformat_alloc_context() : Context;
}

:native("AVFormatContext")
@:include('linc_ffmpeg.h')
private extern class AVFormatContext {}