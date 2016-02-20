/**
 * testing procedure excerpt from aveasy ( https://github.com/datenwolf/aveasy )
 */
import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;

class Test {
	
        
    static function main() {
		var c : cpp.Pointer<ffmpeg.FFmpeg.AVFormatContext> = ffmpeg.FFmpeg.avformat_alloc_context();
		trace("go");
		trace( c );
		//trace( Std.string(c.ref) );
		//trace(  );
		$type( c);
		trace(c.ptr.iformat);
		trace(c.ptr.ctx_flags);
		
		//$type( c.ref);
		//trace( Reflect.fields( c ));
		
		//var 
		//trace( Reflect.fields( c.ref ));
		//$type( c.ctx_flags);
		
		//var r : ffmpeg.FFmpeg.InputFormat = c.iformat; 
		//$type( c.ref.ctx_flags);
		//var r = c.ref;
		//var i = r.ref.iformat;
		
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( cast null );
		trace( desc );
		
		
    }

}