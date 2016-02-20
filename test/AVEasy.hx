
import ffmpeg.FFmpeg;

class AVEasy {
	
	public var format_context 		: cpp.Pointer<ffmpeg.FFmpeg.AVFormatContext>;
	public var input_format 		: cpp.Pointer<ffmpeg.FFmpeg.AVInputFormat>;
	public var codec_context 		: cpp.Pointer<ffmpeg.FFmpeg.AVCodecContext>;
	public var codec 				: cpp.Pointer<ffmpeg.FFmpeg.AVCodec>;
	public var encoded_frame 		: cpp.Pointer<ffmpeg.FFmpeg.AVFrame>;
	public var raw_frame 			: cpp.Pointer<ffmpeg.FFmpeg.AVFrame>;
	public  var sws_context 		: cpp.Pointer<ffmpeg.FFmpeg.SwsContext>;
	public  var video_stream 		: Int;
	public  var buffer_size 		: haxe.Int64;
	public  var buffer 				: haxe.io.Bytes;
//	public  var pixel_format : AVPixelFormat;
	//public var format_parameters 	: cpp.Pointer<ffmpeg.FFmpeg.AVFormatParameters>;
	/*
	
	
	//public  var pixel_format : AVPixelFormat;
	
	*/
	public function new( path:String ) {
		//var ff = ffmpeg.FFmpeg;
		//format_context = ffmpeg.FFmpeg.avformat_alloc_context();
		//trace("ave:" + format_context);
	}
	
}