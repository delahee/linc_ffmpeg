/**
 * following http://dranger.com/ffmpeg/tutorial02.html
 */

import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;

import sdl.SDL;
import sdl.SDL.*;
import sdl.Window;
import sdl.Renderer;
import sdl.Surface;
import sdl.Texture;

class State{
	public var window:Window;
	public var renderer:Renderer;
	public var videoTexture:Texture;
	
	public var buffer_u8 : cpp.RawPointer<cpp.UInt8>;
	public var buffer_len : Int;
	public var frame : cpp.Pointer<AVFrame>;
	public var frameRgb: cpp.Pointer<AVFrame>;
	public var frameYuv: cpp.Pointer<AVFrame>;
	public var codecCtx: cpp.Pointer<AVCodecContext>;
	public var ctxtClone: cpp.Pointer<AVCodecContext>;
	public var fc: cpp.Pointer<AVFormatContext>;
	
	public function new() {
		
	}
}

class TestSdl {
	static var st = new State();
	
    static function main() {
		
		//Ensure file system is available
		trace(Sys.getCwd());
		
		//Ensure C layer is binded
		var desc = ffmpeg.FFmpeg.describe_AVInputFormat( cast null );
		trace( desc );
		
		//let's start trying to decode something
		Av.registerAll();
		if(SDL.init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_TIMER) != 0) {
			trace("Could not initialize SDL\n");
			return;
		}
		else 
			trace("SDL init ok");
		
		sdl.SDL.GL_SetSwapInterval(true);
		var errCode = 0;
		var fc :cpp.Pointer<AVFormatContext> = AvFormat.allocContext();
		trace("fresh fc:" + fc);
		var filename = "data/Vikings.S04E05.720p.HDTV.x264-KILLERS[eztv].mkv";
		//var filename = "data/centaur_1.mpg";
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
		var videoStreamIdx = -1;
		//trace( fc );
		//trace("inspecting streams "+nbStream+ " from "+ fc.ptr.streams);
		for ( i in 0...nbStream ) {
			//trace(base);
			var stream = AvFormat.nthStream( fc, i );
			var codec = stream.ptr.codec;
			if ( codec.ptr.codec_type == AVMEDIA_TYPE_VIDEO ){
				video = stream;
				videoStreamIdx = i;
				
			}
		}
		
		if ( video != null) {
			trace("found video " + video);
		}
		else {
			trace( "No video found" );
			return;
		}
		
		//introspect codec 
		/*
		var a = [];
		var i = 0;
		var c :cpp.ConstPointer<AVCodec> = AvCodec.next(cast null);
		while ( c != null) {
			var str = "";
			if ( c != null && c.ptr != null) {
				//"#" + i + " " +c.ptr.name+" " + c.ptr.long_name+" \n "
				str += c.ptr.name;
				a.push( str );
			}
			c = AvCodec.next(c);
		}
		sys.io.File.saveContent( "d:\\codecs.txt", a.join(" ") );
		*/
		/*
		var a = [];
		var i = 0;
		var c :cpp.ConstPointer<AVHWAccel> = AcHWAccel.next(cast null);
		while ( c != null) {
			var str = "";
			if ( c != null && c.ptr != null) {
				str += c.ptr.name+" "+c.ptr.id;
				a.push( str );
			}
			c = AcHWAccel.next(c);
		}
		sys.io.File.saveContent( "d:\\hwcodecs.txt", a.join(" ") );
		*/
		
		var codecCtx = video.ptr.codec;
		var codec : cpp.ConstPointer< AVCodec >;// = codecCtx.ptr.codec;
		codec = AvCodec.findDecoder(codecCtx.ptr.codec_id);
		if ( codec == null ) {
			trace("Unsupported codec! #"+codecCtx.ptr.codec_id);
		}
		else {
			trace("ctxt:" + codecCtx 
			+ " fmt:" + codecCtx.ptr.pix_fmt
			+ " sw_pix_fmt:" + codecCtx.ptr.sw_pix_fmt
			+" w:"+codecCtx.ptr.width
			+" h:" + codecCtx.ptr.height
			+" cdc: "+codec.ptr.name
			+" lcdc: "+codec.ptr.long_name
			+" id: "+codec.ptr.id
			);
		}
		
		var w = codecCtx.ptr.width;
		var h = codecCtx.ptr.height;
		
		var undef = sdl.SDL.SDLWindowPos.SDL_WINDOWPOS_UNDEFINED;
		var create = SDL.createWindowAndRenderer(w, h, 0);
		
		st.window = create.window;
		st.renderer = create.renderer;
		if(st.window==null) {
			trace("SDL: could not create window");
			return;
		}
		else 
			trace("SDL: window opened");
		
		var renderer : Renderer = st.renderer;
		st.videoTexture = SDL.createTexture(renderer, SDL_PIXELFORMAT_YV12, SDL_TEXTUREACCESS_STREAMING, w, h);
		if(null==st.videoTexture) {
			trace("Couldn't set create texture\n");
			return;
		} else trace("created streamed yuv texture");
		
		var ctxtClone = AvCodec.allocContext3( codec );
		AvCodec.copyContext( ctxtClone, codecCtx );
		
		if ( (errCode=AvCodec.openNoOpt(ctxtClone, codec)) < 0 ) {
			trace( "cannot open codec" );
			trace( Av.error(errCode) );
			return;	
		}
		else {
			trace( "opened" );
		}
		
		var frame : cpp.Pointer <AVFrame> = AvFrame.alloc();
		
		function createFrameBufferRGB(){
			st.frameRgb = AvFrame.alloc();
			var rgb : _AVPixelFormat = AVPixelFormat.AV_PIX_FMT_RGB24.toNative();
			var nbytes = AvPicture.getSize( rgb, codecCtx.ptr.width, codecCtx.ptr.height);
			st.buffer_u8 = cast Av.malloc(nbytes);
			var pic : cpp.Pointer<AVPicture> = cast st.frameRgb;
			var sz = AvPicture.fill(pic, st.buffer_u8, rgb, codecCtx.ptr.width, codecCtx.ptr.height);
		}
		
		function createFrameBufferYUV(){
			st.frameYuv = AvFrame.alloc();
			var yuv : _AVPixelFormat = AVPixelFormat.AV_PIX_FMT_YUV420P.toNative();
			st.buffer_len = AvPicture.getSize( yuv, codecCtx.ptr.width, codecCtx.ptr.height);
			st.buffer_u8 = cast Av.malloc(st.buffer_len);
			var pic : cpp.Pointer<AVPicture> = cast st.frameYuv;
			AvPicture.fill(pic, st.buffer_u8, yuv, codecCtx.ptr.width, codecCtx.ptr.height);
		}
		
		var frameFinished : Int = 0;
		var swsCtx : cpp.Pointer<SwsContext> = null;
		
		st.frame = frame;
		st.codecCtx = codecCtx;
		
		st.ctxtClone = ctxtClone;
		st.fc = fc;
		
		inline function makeSwsContext( fmt : AVPixelFormat  ) {
			//trace( "origin pix fmt:"+fmt );
			var swsCtx : cpp.Pointer<SwsContext> = Sws.getContext(
				codecCtx.ptr.width,
				codecCtx.ptr.height,
				fmt.toNative(),
				
				codecCtx.ptr.width,
				codecCtx.ptr.height,
				AV_PIX_FMT_YUV420P.toNative(),
				
				SwsFlags.SWS_BILINEAR,
				cast null,
				cast null,
				cast null
				);
			return swsCtx;
		}
		var packetPtr : cpp.Pointer<AVPacket> = untyped __cpp__("new AVPacket()");
		
		createFrameBufferYUV();
		//var i=0;
		var loops = 0;
		while (Av.readFrame(fc, packetPtr ) >= 0) {
			var t0 = haxe.Timer.stamp();
			if (packetPtr.ptr.stream_index == videoStreamIdx) {
				//TODO
				AvCodec.decodeVideo2( ctxtClone, frame, cpp.Pointer.addressOf(frameFinished), packetPtr );
				
				if ( frameFinished != 0 ) {
					var fmt : AVPixelFormat = cast frame.ptr.format;
					if ( swsCtx == null) {
						swsCtx = makeSwsContext(fmt);
						trace("ctx:"+swsCtx);
					}
					
					Sws.scale(	swsCtx, frame.ptr.data,
								frame.ptr.linesize, 0, ctxtClone.ptr.height,
								st.frameYuv.ptr.data, st.frameYuv.ptr.linesize);
					
					var arr:Array<cpp.UInt8> = ffmpeg.Helper.ptrToArray( cast st.buffer_u8, st.buffer_len );
					var b : haxe.io.BytesData = cast arr; 
					SDL.updateTexture(st.videoTexture, null, b, codecCtx.ptr.width);
					SDL.renderClear(renderer);
					SDL.renderCopy(renderer, st.videoTexture, null, null);
					SDL.renderPresent(renderer);
				}
			}
			var t1 = haxe.Timer.stamp();
			loops++;
			if( loops < 100){
				trace(t1 - t0);
			}
		}
		
		destroy(st);
    }
	
	static function destroy(st:State) {
		Av.free( cast st.buffer_u8 );
		Av.free( cast st.frame.raw );
		
		if( st.frameRgb!=null)
			Av.free( cast st.frameRgb.raw );
			
		if( st.frameYuv!=null)
			Av.free( cast st.frameYuv.raw );
			
		AvCodec.close( st.codecCtx );
		AvCodec.close( st.ctxtClone );
		
		SDL.destroyRenderer(st.renderer);
		SDL.destroyTexture(st.videoTexture);
		
		var raw : cpp.RawPointer<AVFormatContext> = st.fc.get_raw();
		var rawraw : cpp.RawPointer<cpp.RawPointer<AVFormatContext>> = cpp.Pointer.addressOf( raw ).get_raw();
		AvFormat.closeInput( rawraw );
		trace( "finished" );
	}

}