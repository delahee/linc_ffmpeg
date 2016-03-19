/**
 * following http://dranger.com/ffmpeg/tutorial03.html
 */

import ffmpeg.FFmpeg;
import ffmpeg.FFmpeg.*;
import ffmpeg.FFmpeg.AVPacketList;

import sdl.SDL;
import sdl.SDL.*;
import sdl.Thread;
import sdl.Audio;
import sdl.Window;
import sdl.Renderer;
import sdl.Surface;
import sdl.Texture;
import sdl.Event;

/**
 * todo:
 * 
 */

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
	public var audioq : PacketQueue;
	
	public var audio_buf : cpp.Pointer<cpp.UInt8>;
	public var audio_buf_size : Int = 0;
	public var audio_buf_index : Int = 0;

	
	public function new() {
		
	}
}

class PacketQueue {
	var first_pkt 	: cpp.Pointer<AVPacketList>	= null;
	var last_pkt 	: cpp.Pointer<AVPacketList>	= null;
	var nb_packets 	: Int						= 0;
	var size 		: Int						= 0;
	var mutex 		: Mutex;
	var cond 		: Cond;
	
	public function new() {
		trace("audioq init");
		mutex = SDL.CreateMutex();
		cond = SDL.CreateCond();
	}
	
	//todo test
	public function put(pkt:cpp.Pointer<AVPacket>) : Int {
		//trace("put");
		if (pkt == null) throw "assertion : invariant broken";
		var q = this;
		var pkt1 : cpp.Pointer<AVPacketList>=cast null;
		if (Av.dupPacket(pkt) < 0) {
			trace("oom");	
			return -1;
		}
		pkt1 = Helper.malloc( untyped __cpp__("sizeof(AVPacketList)") );
		if ( pkt1 == null) {
			trace("oom");
			return -1;
		}
		pkt1.ptr.pkt = pkt.ref;
		pkt1.ptr.next = cast null;
		SDL.LockMutex(q.mutex);
		
		if (null==q.last_pkt)
			q.first_pkt = pkt1;
		  else
			q.last_pkt.ptr.next = pkt1;
		q.last_pkt = pkt1;
		
		q.nb_packets++;
		var pktStruct : AVPacketStruct = cast pkt1.ptr.pkt;
		q.size += pktStruct.size;
		
		SDL.CondSignal(q.cond);
  
		SDL.UnlockMutex(q.mutex);
		//trace("done");
		return 0;
	}
	
	public function get(pkt:cpp.Pointer<AVPacket>, block:Int) : Int {
		var pkt1: cpp.Pointer<AVPacketList>;
		var ret:Int=0;
		var q = this;
		SDL.LockMutex(mutex);
		  
		while(true){
			if(TestSdlSound.requestExit!=0) {
				ret = -1;
				break;
			}
			pkt1 = first_pkt;
			if (null!=pkt1) {
				first_pkt = pkt1.ptr.next;
				if (null==first_pkt)
					last_pkt = null;
				nb_packets--;
				var pktStruct : AVPacketStruct = cast pkt1.ptr.pkt;
				size -= pktStruct.size;
				
				pkt.set_ref( pkt1.ptr.pkt );
				Av.free(cast pkt1.get_raw());
				ret = 1;
				break;
			} else if (0==block) {
				ret = 0;
				break;
			} else {
				SDL.CondWait(cond, mutex);
			}
		}
		SDL.UnlockMutex(mutex);
		return ret;
	}
}

class Lib {
	
}


@:cppFileCode('
/*
int audio_decode_frame(AVCodecContext *aCodecCtx, uint8_t *audio_buf, int buf_size) {

  static AVPacket pkt;
  static uint8_t *audio_pkt_data = NULL;
  static int audio_pkt_size = 0;
  static AVFrame frame;

  int len1, data_size = 0;

  for(;;) {
    while(audio_pkt_size > 0) {
      int got_frame = 0;
      len1 = avcodec_decode_audio4(aCodecCtx, &frame, &got_frame, &pkt);
      if(len1 < 0) {
	audio_pkt_size = 0;
	break;
      }
      audio_pkt_data += len1;
      audio_pkt_size -= len1;
      data_size = 0;
      if(got_frame) {
	data_size = av_samples_get_buffer_size(NULL, 
					       aCodecCtx->channels,
					       frame.nb_samples,
					       aCodecCtx->sample_fmt,
					       1);
	//assert(data_size <= buf_size);
	memcpy(audio_buf, frame.data[0], data_size);
      }
      if(data_size <= 0) {
	continue;
      }
      return data_size;
    }
    if(pkt.data)
      av_free_packet(&pkt);

    if(quit) {
      return -1;
    }

    if(packet_queue_get(&audioq, &pkt, 1) < 0) {
      return -1;
    }
    audio_pkt_data = pkt.data;
    audio_pkt_size = pkt.size;
  }
}*/

void dummy(void * userdata, Uint8 * stream, int len) {
	//printf("DUM\\n");
}

/*
void audioCallback(void * userdata, Uint8 * stream, int len) {
	#define MAX_AUDIO_FRAME_SIZE 192000	
	AVCodecContext *aCodecCtx = (AVCodecContext *)userdata;
	int len1, audio_size;

	static uint8_t audio_buf[(MAX_AUDIO_FRAME_SIZE * 3) / 2];
	static unsigned int audio_buf_size = 0;
	static unsigned int audio_buf_index = 0;

	while(len > 0) {
		if(audio_buf_index >= audio_buf_size) {
		  //We have already sent all our data; get more
		  //audio_size = audio_decode_frame(aCodecCtx, audio_buf, sizeof(audio_buf));
		  if(audio_size < 0) {
			//If error, output silence
			audio_buf_size = 1024; // arbitrary?
			memset(audio_buf, 0, audio_buf_size);
		  } else {
			audio_buf_size = audio_size;
		  }
		  audio_buf_index = 0;
		}
		len1 = audio_buf_size - audio_buf_index;
		if(len1 > len)
		  len1 = len;
		memcpy(stream, (uint8_t *)audio_buf + audio_buf_index, len1);
		len -= len1;
		stream += len1;
		audio_buf_index += len1;
	}
}
*/
')
class TestSdlSound {
	public static var st = new State();
	
	public static var audio_pkt_data : U8Buffer = null;
	public static var audio_pkt_size : Int = 0;
	
	public static var adcPkt : cpp.Pointer<AVPacket>;
	public static var adcFrame : cpp.Pointer<AVFrame>;
	public static var requestExit = 0;
	
    static function main() {
		//Ensure file system is available
		trace(Sys.getCwd());
		var p = new PacketQueue();
		p.put;
		p.get;
		//Lib.audio_decode_frame;
		//audio_decode_frame;
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
		
		st.audioq = new PacketQueue();
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
		var audio = null;
		var videoStreamIdx = -1;
		var audioStreamIdx = -1;
		
		for ( i in 0...nbStream ) {
			//trace(base);
			var stream = AvFormat.nthStream( fc, i );
			var codec = stream.ptr.codec;
			
			if( codec.ptr.codec_type == AVMEDIA_TYPE_VIDEO ){
				video = stream;
				videoStreamIdx = i;
			}
			
			if ( codec.ptr.codec_type == AVMEDIA_TYPE_AUDIO ) {
				audio = stream;
				audioStreamIdx=i;
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
		if ( codec == null ) 
			trace("Unsupported codec! #"+codecCtx.ptr.codec_id);
		else {
			trace("ctxt:" + codecCtx 
			+ " fmt:" + codecCtx.ptr.pix_fmt
			+ " sw_pix_fmt:" + codecCtx.ptr.sw_pix_fmt
			+" w:"+codecCtx.ptr.width
			+" h:" + codecCtx.ptr.height
			);
		}
		
		var aCodecCtxOrig : cpp.Pointer<AVCodecContext>;
		var aCodecClone : cpp.Pointer<AVCodecContext>;
		
		aCodecCtxOrig = audio.ptr.codec;
		var aCodec : cpp.ConstPointer< AVCodec > = AvCodec.findDecoder(aCodecCtxOrig.ptr.codec_id);
		
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
		
		var ctxtClone = AvCodec.allocContect3( codec );
		AvCodec.copyContext( ctxtClone, codecCtx );
		
		aCodecClone = AvCodec.allocContect3( aCodec );
		AvCodec.copyContext(aCodecClone, aCodecCtxOrig );
		
		if ( (errCode=AvCodec.openNoOpt(ctxtClone, codec)) < 0 ) {
			trace( "cannot open video codec" );
			trace( Av.error(errCode) );
			return;	
		}
		else {
			trace( "opened" );
		}
		
		if ( (errCode=AvCodec.openNoOpt(aCodecClone, aCodec)) < 0 ) {
			trace( "cannot open audio codec" );
			trace( Av.error(errCode) );
			return;	
		}
		else {
			trace( "opened" );
		}
		
		var SDL_AUDIO_BUFFER_SIZE = 1024;
		var wantedSpec : AudioSpec = SDL_AudioSpec.create();
		var spec : AudioSpec = SDL_AudioSpec.create();
		//codecs are opened
		//opening audio
		wantedSpec.ptr.freq = aCodecClone.ptr.sample_rate;
		wantedSpec.ptr.channels = aCodecClone.ptr.channels>2?2:aCodecClone.ptr.channels;
		wantedSpec.ptr.silence = 0;
		wantedSpec.ptr.samples = SDL_AUDIO_BUFFER_SIZE;
		wantedSpec.ptr.format = AudioFormat.toNative(AudioFormat.af_s16lsb);
		wantedSpec.ptr.userdata = cast aCodecClone;
		
		var callable : cpp.Callable <
		cpp.RawPointer<cpp.Void> -> cpp.RawPointer<cpp.UInt8> -> Int -> Void >  = cpp.Callable.fromStaticFunction(audioCallback);
		
		wantedSpec.ptr.callback = untyped __cpp__("(SDL_AudioCallback)({0})",callable.get_call());
		//wantedSpec.ptr.callback = untyped __cpp__("dummy");
		
		for ( i in 0...SDL.getNumAudioDevices(false)) 
			trace( SDL.getAudioDeviceName(i,false));
	
		
		var device = SDL.openAudioDevice(null, false, wantedSpec, spec, 
			SDL_AUDIO_ALLOW_ANY_CHANGE);
		if ( device <= 0 ) {
			trace("unable to fetch audio : "+SDL.getError());
			return;
		}
		else 
			trace( "selected: "+SDL.getAudioDeviceName(device, false) );
		trace("spec freq: " + spec.ptr.freq);
		trace("spec chann: " + spec.ptr.channels);
		trace("spec samples: " + spec.ptr.samples);
		trace("spec format: " + spec.ptr.format);
		
		//var err = SDL.openAudio(wantedSpec, spec);
		//if ( err < 0 )  { trace("unable to fetch audio "+SDL.getError() ); return; }
		//trace("spec freq: " + wantedSpec.ptr.freq);
		//trace("spec chann: " + wantedSpec.ptr.channels);
		//trace("spec samples: " + wantedSpec.ptr.samples);
		//trace("spec format: " + wantedSpec.ptr.format);
		
		//trace("fetched audio " + spec.ptr.format + " <> " + wantedSpec.ptr.format);
		//trace( spec.ptr.callback.call );
		//untyped __cpp__('printf("cbk ptr:0x%x\\n",{0})', wantedSpec.ptr.callback);
		//untyped __cpp__('printf("cbk ptr:0x%x\\n",{0})', spec.ptr.callback);
		//untyped __cpp__('printf("cbk ptr:0x%x\\n",dummy)');
		var aErr = AvCodec.openNoOpt(aCodecClone, aCodec);
		if ( aErr < 0) {
			trace("ac codec open err");
			return;
		}
		
		SDL.pauseAudio(0);
		SDL.pauseAudioDevice(device,0);
		
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
		var packetPtr : cpp.Pointer<AVPacket> = AVPacket.create();
		
		createFrameBufferYUV();
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
								st.frameYuv.ptr.data, st.frameYuv.ptr.linesize);
					
					var arr:Array<cpp.UInt8> = ffmpeg.Helper.ptrToArray( cast st.buffer_u8, st.buffer_len );
					var b : haxe.io.BytesData = cast arr; 
					SDL.updateTexture(st.videoTexture, null, b, codecCtx.ptr.width);
					SDL.renderClear(renderer);
					SDL.renderCopy(renderer, st.videoTexture, null, null);
					SDL.renderPresent(renderer);
				}
			}
			else if(packetPtr.ptr.stream_index==audioStreamIdx) {
				st.audioq.put(packetPtr);
			}
			else {
				Av.freePacket( packetPtr );
			}
			
			var event = SDL.pollEvent();
			switch(event.type) {
				case SDL_QUIT:
					trace("exit requested");
					TestSdlSound.requestExit = 1;
					SDL.quit();
					Sys.exit(0);
				default:
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
	
	/**
	 * 
	 * test audio_decode_frame(_codecCtx:cpp.Pointer<RGB>)
	 * 
	 */
	
	@:unreflective
	@:void
	public static function audioCallback(userdata:cpp.RawPointer<cpp.Void>, stream:cpp.RawPointer<cpp.UInt8>, len:Int) : Void{
		trace("called");
		var MAX_AUDIO_FRAME_SIZE = 192000;
		var aCodecCtx : cpp.Pointer<AVCodecContext> = cast  userdata;
		var len1:Int=0;
		var audio_size : Int=0;

		if ( st.audio_buf == null){
			st.audio_buf = Helper.malloc((MAX_AUDIO_FRAME_SIZE * 3) >> 1);
			st.audio_buf_size = 0;
			st.audio_buf_index = 0;
		}
		var pStream = cpp.Pointer.fromPointer(stream);
		while(len > 0) {
			if(st.audio_buf_index >= st.audio_buf_size) {
			  //We have already sent all our data; get more
			  //audio_size = audio_decode_frame(aCodecCtx, st.audio_buf, (MAX_AUDIO_FRAME_SIZE * 3) >> 1);
			  if(audio_size < 0) {
				//If error, output silence
				st.audio_buf_size = 1024; // arbitrary?
				untyped __cpp__("memset({0}, 0, {1})",st.audio_buf,st.audio_buf_size);
			  } else {
				st.audio_buf_size = audio_size;
			  }
			  st.audio_buf_index = 0;
			}
			len1 = st.audio_buf_size - st.audio_buf_index;
			if(len1 > len)
			  len1 = len;
			//memcpy(stream, (uint8_t * ) audio_buf + audio_buf_index, len1);
			untyped __cpp__("memcpy({0}, (uint8_t * ) {1} + {2}, {3})",stream,st.audio_buf,st.audio_buf_index,len1);
			len -= len1;
			pStream.incBy(len1);
			st.audio_buf_index += len1;
		}
		
	}
		
	public static function audio_decode_frame(
		aCodecCtx:AVCodecContextPtr,
		buf:cpp.Pointer<cpp.UInt8>,
		buf_size:Int
	) : Int {
		/*/
		trace("decoding");
		var len1 = 0;
		var data_size = 0;
		var t = TestSdlSound;
		if( t.adcFrame == null) t.adcFrame = AVFrame.create();
		if( t.adcPkt == null ) t.adcPkt = AVPacket.create();

		var frame = TestSdlSound.adcFrame;
		var pkt = TestSdlSound.adcPkt;
		
		while(true) {
			while(TestSdlSound.audio_pkt_size > 0) {
				var got_frame = 0;
				len1 = AvCodec.decodeAudio4(aCodecCtx, frame, cpp.Pointer.addressOf(got_frame), pkt );
				if(len1 < 0) {
					//if error, skip frame
					t.audio_pkt_size = 0;
					break;
				}
				t.audio_pkt_data.incBy( len1 );
				t.audio_pkt_size -= len1;
				data_size = 0;
				if(got_frame!=0) {
					data_size = AvSamples.getBufferSize(cast null, 
					aCodecCtx.ptr.channels,
					frame.ptr.nb_samples,
					aCodecCtx.ptr.sample_fmt,
					1);
					if (data_size <= buf_size) throw "audio_decode:assert";
					
					var buf = frame.ptr.data;
					//untyped __cpp__("memcpy(audio_buf, frame.data[0], data_size)");
				}
				if(data_size <= 0) {
					//No data yet, get more frames
					continue;
				}
				//We have data, return it and come back for more later
				return data_size;
			}
			
			if(pkt.ptr.data!=null)
				Av.freePacket(pkt);

			if(t.requestExit!=0) 
				return -1;

			if( t.st.audioq.get(pkt, 1) < 0) 
				return -1;
			
			t.audio_pkt_data = pkt.ptr.data;
			t.audio_pkt_size = pkt.ptr.size;
		}
		*/
		return 0;
	}
	
	

}