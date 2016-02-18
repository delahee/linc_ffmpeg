
import ffmpeg.FFmpeg;

class Test {
        
    static function main() {
		
		var c : ffmpeg.FFmpeg.FormatContext = ffmpeg.FFmpeg.avformat_alloc_context();
		trace("go");
    }

}