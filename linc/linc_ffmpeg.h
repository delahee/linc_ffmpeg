#ifndef _LINC_FFMPEG_H_
#define _LINC_FFMPEG_H_
    
#include "../lib/ffmpeg/include/libavcodec"
#include "../lib/ffmpeg/include/libavdevice"
#include "../lib/ffmpeg/include/libavfilter"
#include "../lib/ffmpeg/include/libavutil"
#include "../lib/ffmpeg/include/libavformat"
#include "../lib/ffmpeg/include/libpostproc"
#include "../lib/ffmpeg/include/libswscale"
#include "../lib/ffmpeg/include/libswresample"

#include <hxcpp.h>

namespace linc {

    namespace ffmpeg {
		extern AVFormatContext * avformat_alloc_context();
    } //empty namespace

} //linc

#endif //_LINC_EMPTY_H_
