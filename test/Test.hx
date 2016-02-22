/**
 * testing procedure excerpt from aveasy ( https://github.com/datenwolf/aveasy )
 */

import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;

class TestClassImport {
	public var v0:cpp.Pointer<AVCodecContext>;
	public var v1:cpp.Pointer<AVCodec>;
	public var v2:cpp.Pointer<AVFrame>;
	public var v3:cpp.Pointer<AVInputFormat>;
	public var v4:cpp.Pointer<AVClass>;
	public var v5:cpp.Pointer<AVOutputFormat>;
	public var v6:cpp.Pointer<SwsContext>;
	public var v7:cpp.Pointer<AVDictionary>;
	
	public static function main() {
		
	}
}



class Test {
	
	
	
        
    static function main() {
		
		var pint = 0;
		//var p : cpp.Pointer<Int> = cpp.Pointer.addressOf( null );
		//var p : cpp.Pointer<Int> = cpp.Pointer.addressOf( 0 );
		//var p : cpp.Pointer<Int> = cpp.Pointer.fromRaw( 0 );
		//var p : cpp.Pointer<Int> = new cpp.Pointer(0);
		//var p : cpp.Pointer<Int> = cpp.Pointer.addressOf( pint );
		//var p : cpp.Pointer<Int> = cast null;
		//var p : cpp.Pointer<Int> = null;
		//var str = Sys.command("dir");
		//trace("pop");
		
		//Ensure file system is available
		trace(Sys.getCwd());
		
		//Ensure C layer is binded
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( cast null );
		trace( desc );
		
		//let's start trying to decode something
		Av.registerAll();
		
		//
		var errCode = 0;
		var fc :cpp.Pointer<AVFormatContext> = AvFormat.allocContext();
		trace("fresh fc:" + fc);
		var filename = "data/SampleVideo_360x240_1mb.mp4";
		var ret = AvFormat.openInput( filename, fc, cast null, cast null);
		if ( ret.retCode < 0 ) {
			trace( "Error" );
			trace( Av.error( ret.retCode ));
			return;
		}
		trace("file opened " + ret);
		//trace(ret.ctx);
		
		// Dump information about file onto standard error
		Av.dumpFormat(fc, 0, filename, 0);
		
		var nbStream : Int = cast fc.ptr.nb_streams;
		var base = fc.ptr.streams; 
		var video = null;
		trace( fc );
		trace("inspecting streams "+nbStream+ " from "+ fc.ptr.streams);
		for ( i in 0...nbStream ) 
		{
			//trace(base);
			var stream = AvFormat.nthStream( fc, i );
			var codec = stream.ptr.codec;
			if ( codec.ptr.codec_type == AVMEDIA_TYPE_VIDEO )
				video = stream;
			//var stream = fc.ref.streams.incBy(i).raw;
			//equivalent to fc.incBy(i) ?
			
			
			//trace(stream);
			//var stream : cpp.Pointer<AVStream> = base.ptr;
			//var streamCodec : cpp.Pointer<AVCodecContext> = stream.ptr.codec;
			//base = base.inc();
			//trace("inspected stream "+i);
		}
		
		if ( video != null) {
			trace("found video "+video);
		}
		else {
			trace( "No video found" );
			return;
		}
		
		var codecCtx = video.ptr.codec;
		var codec : cpp.ConstPointer< AVCodec > = codecCtx.ptr.codec;
		
		trace("codec?:" + codec);
		//todo trackback to corrrect codec!
		
		var ctxtClone = AvCodec.allocContect3( codec );
		AvCodec.copyContext( ctxtClone, codecCtx );
		
		if ( (errCode=AvCodec.openNoOpt(ctxtClone, codec)) < 0 ) {
			trace( "cannot open codec" );
			trace( Av.error(errCode) );
			return;	
		}
		else {
			trace( "opened" );
		}
		trace( "finished" );
    }

}