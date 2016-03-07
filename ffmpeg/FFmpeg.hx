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
			
	@:native('av_malloc')
	public static function malloc(size : UInt) : cpp.RawPointer<cpp.Void>;
	
	@:native('av_free')
	public static function free(ptr : cpp.RawPointer<cpp.Void>) : Void;
	
	@:native('av_read_frame')
	public static function readFrame(fc:cpp.Pointer<AVFormatContext>,pck:cpp.Pointer<AVPacket>) : Int;
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
	
	@:native('avformat_close_input')
	static function closeInput(ctxt : cpp.RawPointer<cpp.RawPointer<AVFormatContext>>) : Void;
	
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
	
	@:native('avcodec_decode_video2')
	static function decodeVideo2(
		ctx:cpp.Pointer<AVCodecContext>,
		fr:cpp.Pointer<AVFrame>,
		finished:cpp.Pointer<Int>,
		pckt : cpp.ConstPointer<AVPacket>): Int;
		
	@:native('avcodec_close')
	static function close( ctx:cpp.Pointer<AVCodecContext> ) : Void;
	
}

@:keep
extern class AvFrame {
	@:native('av_frame_alloc')
	static function alloc() : cpp.Pointer<AVFrame>;
}

@:keep
extern class AvPicture {
	@:native('avpicture_get_size')
	static function getSize(fmt:_AVPixelFormat, w:Int, h:Int) : Int;
	
	@:native('avpicture_fill')
	static function fill(pic:cpp.Pointer<AVPicture>, buf:cpp.RawPointer<cpp.UInt8> , fmt:_AVPixelFormat, w:Int, h:Int):Int;
}

@:keep
extern class Sws {
	@:native('sws_getContext')
	static function getContext(
		srcW:Int, srcH:Int, srcFmt:_AVPixelFormat,
		dstW:Int, dstH:Int, dstFmt:_AVPixelFormat,
		flags:Int,
		srcFilter:cpp.Pointer<SwsFilter>,
		dstFilter:cpp.Pointer<SwsFilter>,
		param:cpp.Pointer<cpp.Float64>
		) : cpp.Pointer<SwsContext>;
		
	@:native('sws_scale')
	static function scale(
		ctxt : cpp.Pointer<SwsContext>,
		src : cpp.RawPointer<cpp.RawPointer<cpp.UInt8>>,
		srcStride : cpp.Pointer<Int>,
		srcSliceY : Int,
		srcSliceH : Int,
		dst : cpp.RawPointer<cpp.RawPointer<cpp.UInt8>>,
		dstStride : cpp.Pointer<Int>
	) : Int;
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
	var bit_rate:Int;
	var pix_fmt : _AVPixelFormat;
	var sw_pix_fmt : _AVPixelFormat;
	var sample_rate : Int;
	var channels : Int;
	//var sample_fmt : AVSampleFormat;
	var frame_size : Int;
}

@:include("linc_ffmpeg.h")
@:native("AVPacket")
extern class AVPacket{
	var stream_index:Int;
	
	@:native("new AVPacket")
	public static function create():cpp.Pointer<AVPacket>;
	
	@:native("~AVPacket")
	public function delete():Void;
}

@:native("cpp.Struct<AVPacket>")
extern class AVPacketStruct extends AVPacket{}

@:native("AVCodec") extern class AVCodec { }

extern class AVPacketList {
	var pkt:AVPacketStruct;
	var next:cpp.Pointer<AVPacketList>;
}



@:include('linc_ffmpeg.h')
@:native("AVFrame") 
extern class AVFrame { 
	var data 			: cpp.RawPointer<cpp.RawPointer<cpp.UInt8>>; //u8 * data[AV_NUM_DATA_POINTERS]
	var linesize 		: cpp.Pointer<Int>; //int data[AV_NUM_DATA_POINTERS]
	
	var width 			: Int;
	var height 			: Int;
	var colorspace 		: Int;
	var sample_rate 	: Int;
	var format 			: _AVPixelFormat;
	var flags		 	: Int;
	var channels	 	: Int;
	var pkt_size	 	: Int;
}

@:include('linc_ffmpeg.h')
@:native("AVPicture") 		extern class AVPicture { }

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

@:include("linc_ffmpeg.h")
@:native("AVPixelFormat")	extern class _AVPixelFormat{ }

@:include('linc_ffmpeg.h')
@:native("SwsFilter") 		extern class SwsFilter {}

/**
 * @see https://groups.google.com/forum/#!topic/Haxelang/cirmD1EZGMA
 */
@:enum
abstract AVPixelFormat (Int) from Int to Int{ 
	var AV_PIX_FMT_NONE 	= -1;
	var AV_PIX_FMT_YUV420P 	= 0;
	var AV_PIX_FMT_YUYV422 	= 1;
	var AV_PIX_FMT_RGB24 	= 2; 
	
	@:to(_AVPixelFormat)
	@:unreflective
	inline public function toNative() : _AVPixelFormat {
		return untyped __cpp__("((AVPixelFormat)({0}))",this);
	}
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


@:enum 
abstract  SwsFlags (Int) to Int { 
	var SWS_FAST_BILINEAR  	= 1;
	var SWS_BILINEAR   	= 2		;
	var SWS_BICUBIC   	= 4     ;
	var SWS_X   		= 8     ;
	var SWS_POINT   	= 0x10  ;
	var SWS_AREA   		= 0x20  ;
	var SWS_BICUBLIN   	= 0x40  ;
	var SWS_GAUSS   	= 0x80  ;
	var SWS_SINC   		= 0x100 ;
	var SWS_LANCZOS  	= 0x200 ;
	var SWS_SPLINE  	= 0x400 ;
}

class Helper {
	
	public static inline function ptrToArray<T>( ptr:cpp.Pointer<T>,length:Int ):Array<T> {
		var a :Array<T>= [];
		//cpp.NativeArray.setUnmanagedData( a, ptr,
		//untyped a.setUnmanagedData(cpp.CastCharStar ptr.raw, length);
		untyped __cpp__("{0}->setUnmanagedData({1},{2});",a,ptr.raw,length);
		return a;
	}
	
	public static function saveFrameToPPM(fr:cpp.Pointer<AVFrame>, width:Int, height:Int, i:Int) {
		var w = new haxe.io.BytesOutput();
		w.writeString("P6\n" + width + " " + height + "\n255\n");
		
		var dataPtr = cpp.Pointer.fromRaw( fr.ptr.data );
		var buf : cpp.RawPointer<cpp.UInt8> = dataPtr.at(0);
		var bufPtr = cpp.Pointer.fromRaw(buf);
		var lineSizePtr :cpp.Pointer<Int>= fr.ptr.linesize;
		var lineSize = lineSizePtr.at(0);
		
		for (y in 0...height) {
			var	linePtr : cpp.Pointer<cpp.UInt8>= bufPtr.add( y * lineSize );
			var pos = 0;
			//Awefully Slow
			for ( x in 0...width) {
				w.writeByte( linePtr.at( pos ) );
				w.writeByte( linePtr.at( pos+1 ) );
				w.writeByte( linePtr.at( pos+2 ) );
				pos += 3;
			}
		}
		
		var file = sys.io.File.write( "frame" + i + ".ppm", true);
		file.writeInput( new haxe.io.BytesInput( w.getBytes() ) );
		file.close();
	}
}
