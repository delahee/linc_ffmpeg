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
		//$type( c);
		trace(c.ptr.iformat);
		trace(c.ptr.ctx_flags);
		
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( cast null );
		trace( desc );
		
		new AVEasy("../data/SampleVideo_360x240_1mb.mp4");
    }

}