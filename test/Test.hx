/**
 * testing procedure excerpt from aveasy ( https://github.com/datenwolf/aveasy )
 */
import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;

class Test {
	
        
    static function main() {
		var c : ffmpeg.FFmpeg.FormatContext = ffmpeg.FFmpeg.avformat_alloc_context();
		trace("go");
		trace( c );
		
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( cast null );
		trace( desc );
    }

}