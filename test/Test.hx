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
		
		var p = null;
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( p );
		trace( desc );
		Av.registerAll();
		trace(Sys.getCwd());
		var ret = AvFormat.openInput("data/SampleVideo_360x240_1mb.mp4", AvFormat.allocContext(), cast null, cast null);
		if( ret.retCode != 0 )
			trace( Av.error( ret.retCode ));
		trace( ret );
		
		//var p = sys.io.File.read( "data/SampleVideo_360x240_1mb.mp4");
		return 0;
    }

}