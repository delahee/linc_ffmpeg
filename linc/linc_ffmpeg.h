#ifndef _LINC_FFMPEG_H_
#define _LINC_FFMPEG_H_
    
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
/*
#include "../lib/ffmpeg/include/libavdevice"
#include "../lib/ffmpeg/include/libavfilter"
#include "../lib/ffmpeg/include/libavutil"
#include "../lib/ffmpeg/include/libavformat"
#include "../lib/ffmpeg/include/libpostproc"
#include "../lib/ffmpeg/include/libswscale"
#include "../lib/ffmpeg/include/libswresample"
*/
#include <hxcpp.h>

extern "C" {
	AVFormatContext * avformat_alloc_context();
}

namespace linc {

    namespace ffmpeg {
		//extern AVFormatContext * avformat_alloc_context(void);
		//extern AVCodecContext avformat_alloc_context(void);
    } //empty namespace

} //linc

#endif //_LINC_EMPTY_H_
