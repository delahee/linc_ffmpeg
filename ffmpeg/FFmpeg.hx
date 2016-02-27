package ffmpeg;

#if (!cpp&&!display)
    #error "ffmpeg is only available with haxe + hxcpp ( cpp target )."
#end

//// refs
////http://dranger.com/ffmpeg/tutorial01.html
////

@:keep
@:include('linc_ffmpeg.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('ffmpeg'))
#end
extern class FFmpeg
{
	@:native('linc::aveasy::describe_AVInputFormat')
    static function describe_AVInputFormat(iformat : cpp.Pointer<AVInputFormat>) : Dynamic;
}

//(int( * cb)(void ** mutex, enum AVLockOp op)
//typedef LockMgrRegisterFN = cpp.Function< int(  mutex : Dynamic, op : Int ) >;

@:keep
extern class Av {
	@:native('av_register_all')
	public static function
		registerAll() : Void;
	
	@:native('linc::ffmpeg::av::error')
	public static function 
		error( code : Int ) : String;
	
	//@:native('av_lockmgr_register')
	//public static function lockMgrRegister( cbk : Dynamic ) : Int;
	@:native('av_dump_format')
	public static function
		dumpFormat(	ic : cpp.Pointer<AVFormatContext>,
					index : Int,
					url : cpp.ConstCharStar,
					is_output:Int) : Void;
}

@:keep
extern class AvDevice {
	@:native('avdevice_register_all')
	public static function registerAll() : Void;
}

@:keep
extern class AvFilter {
	@:native('avfilter_register_all')
	public static function registerAll() : Void;
}

@:keep
extern class AvFormat {
	
	@:native('avformat_alloc_context')
	static function allocContext() : cpp.Pointer<AVFormatContext>;
	
	@:native('avformat_network_init')
	static function networkInit() : Void;
	
	@:native('linc::ffmpeg::avformat::openInput')
	static function openInput( 
		filename : String,
		ps : cpp.Pointer<AVFormatContext>,//not memory managed 
		fmt : cpp.Pointer<AVInputFormat>,
		options : cpp.Pointer<AVDictionary>
	) : { retCode:Int, ctx : cpp.Pointer<AVFormatContext>, opt:cpp.Pointer<AVDictionary> };
	
	@:native('linc::ffmpeg::avformat::nthStream')
	static function nthStream( fc : cpp.Pointer<AVFormatContext>, nth : Int ) 
 	 : cpp.Pointer<AVStream>;
}

@:keep
extern class AvCodec {
	
	@:native('avcodec_alloc_context3')
	static function allocContect3( codec : cpp.ConstPointer<AVCodec> )
	: cpp.Pointer<AVCodecContext>;
	
	@:native('avcodec_copy_context')
	static function copyContext( dstCtxt:cpp.Pointer<AVCodecContext>, srcCtxt:cpp.ConstPointer<AVCodecContext> ) : Int;
	
	@:native('linc::ffmpeg::avcodec::openNoOpt')
	static function openNoOpt( ctxt:cpp.Pointer<AVCodecContext>, codec : cpp.ConstPointer<AVCodec> ) : Int;
	
	@:native('avcodec_find_decoder')
	static function findDecoder( codecId : AVCodecID ) : cpp.Pointer<AVCodec>;
}

@:keep
extern class AvFrame {
	@:native('av_frame_alloc')
	static function alloc() : cpp.Pointer<AVFrame>;
}

@:keep
extern class AvPicture {
	@:native('avpicture_get_size')
	static function getSize(fmt:AVPixelFormat,w:Int,h:Int) : Int;
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
	
	var streams  : cpp.Pointer<cpp.Pointer<AVStream>>;
}

@:include('linc_ffmpeg.h')
@:native("AVCodecContext") 	extern class AVCodecContext { 
	var codec_type : AVMediaType;
	var codec_id : AVCodecID;
	var codec : cpp.ConstPointer< AVCodec >;
	var width:Int;
	var height:Int;
}

@:include('linc_ffmpeg.h')
@:native("AVCodec") 		extern class AVCodec {}

@:include('linc_ffmpeg.h')
@:native("AVFrame") 		extern class AVFrame { }

@:include('linc_ffmpeg.h')
@:native("AVInputFormat")	extern class AVInputFormat { }

@:include('linc_ffmpeg.h')
@:native("AVClass")			extern class AVClass { }

@:include('linc_ffmpeg.h')
@:native("AVOutputFormat")	extern class AVOutputFormat { }

@:include('linc_ffmpeg.h')
@:native("AVStream")		extern class AVStream {
	
	var index : Int;
	var codec : cpp.Pointer<AVCodecContext>;
	var duration : cpp.Int64;
}

@:include('linc_ffmpeg.h') 
@:native("SwsContext") 		extern class SwsContext { }

@:include('linc_ffmpeg.h') 
@:native("AVDictionary") 	extern class AVDictionary { }


@:enum
abstract AVPixelFormat (Int) { 
	var PIX_FMT_NONE 		= 0;
	var PIX_FMT_YUV420P 	= 1;
	var PIX_FMT_YUYV422 	= 2;
	var PIX_FMT_RGB24 		= 3; 
}

@:enum
abstract AVCodecID (Int) { }

@:enum 
abstract  AVMediaType (Int) { 
	var AVMEDIA_TYPE_VIDEO	= 0;
	var AVMEDIA_TYPE_AUDIO	= 1;
	var AVMEDIA_TYPE_DATA	= 2;
	var AVMEDIA_TYPE_SUBTITLE = 3;
	var AVMEDIA_TYPE_ATTACHMENT = 4;
}




