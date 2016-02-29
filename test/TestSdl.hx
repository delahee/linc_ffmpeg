/**
 * following http://dranger.com/ffmpeg/tutorial01.html
 */

import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;

import sdl.SDL;
import sdl.SDL.*;
import sdl.Window;
import sdl.Renderer;
import sdl.Surface;



class TestSdl {
	static var state : {
		var screen:Window;
		}={ screen:null};
	
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
		
		var errCode = 0;
		var fc :cpp.Pointer<AVFormatContext> = AvFormat.allocContext();
		trace("fresh fc:" + fc);
		var filename = "data/SampleVideo_360x240_1mb.mp4";
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
			);
		}
		
		var w = codecCtx.ptr.width;
		var h = codecCtx.ptr.height;
		
		var undef = sdl.SDL.SDLWindowPos.SDL_WINDOWPOS_UNDEFINED;
		state.screen = SDL.createWindow("video",undef,undef,w,h,0);
		if(state.screen!=null) {
			trace("SDL: could not set video mode - exiting\n");
			return;
		}
		
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
		
		var frame : cpp.Pointer <AVFrame> = AvFrame.alloc();
		var frameRgb = AvFrame.alloc();
		
		var rgb : _AVPixelFormat = AVPixelFormat.AV_PIX_FMT_RGB24.toNative();
		var nbytes = AvPicture.getSize( rgb, codecCtx.ptr.width, codecCtx.ptr.height);
		trace("need " + nbytes + " bytes ");
		
		var buffer_u8 : cpp.RawPointer<cpp.UInt8> = cast Av.malloc(nbytes);
		
		trace( "allocated:" + buffer_u8);
		
		var pic : cpp.Pointer<AVPicture> = cast frameRgb;
		var sz = AvPicture.fill(pic, buffer_u8, rgb, codecCtx.ptr.width, codecCtx.ptr.height);
		trace("filled " + sz );
		
		var frameFinished : Int = 0;
		var packetPtr : cpp.Pointer<AVPacket> = untyped __cpp__("new AVPacket()");
		var swsCtx : cpp.Pointer<SwsContext> = null;
		
		inline function makeSwsContext( fmt : AVPixelFormat  ) {
			//trace( "origin pix fmt:"+fmt );
			var swsCtx : cpp.Pointer<SwsContext> = Sws.getContext(
				codecCtx.ptr.width,
				codecCtx.ptr.height,
				fmt.toNative(),
				
				codecCtx.ptr.width,
				codecCtx.ptr.height,
				rgb,
				
				SwsFlags.SWS_FAST_BILINEAR,
				cast null,
				cast null,
				cast null
				);
			return swsCtx;
		}
		
		var i=0;
		while (Av.readFrame(fc, packetPtr ) >= 0) {
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
								frameRgb.ptr.data, frameRgb.ptr.linesize);
					  
					if (++i <= 5)
						Helper.saveFrameToPPM(frameRgb, ctxtClone.ptr.width, ctxtClone.ptr.height, i);
						
				}
			}
		}
		
		Av.free( cast buffer_u8 );
		Av.free( cast frame.raw );
		Av.free( cast frameRgb.raw );
		AvCodec.close( codecCtx );
		AvCodec.close( ctxtClone );
		
		var raw : cpp.RawPointer<AVFormatContext> = fc.get_raw();
		var rawraw : cpp.RawPointer<cpp.RawPointer<AVFormatContext>> = cpp.Pointer.addressOf( raw ).get_raw();
		AvFormat.closeInput( rawraw );
		trace( "finished" );
    }

}