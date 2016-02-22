#ifndef _LINC_FFMPEG_H_
#define _LINC_FFMPEG_H_
    
extern "C" {
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavutil/avutil.h"
#include "libavutil/dict.h"
#include "libavdevice/avdevice.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
}

#include <hxcpp.h>

extern "C" {
}

namespace linc {
    namespace ffmpeg {
		namespace avformat{
			extern Dynamic openInput(
				String filename, 
				AVFormatContext*ctx,
				AVInputFormat*fmt,
				AVDictionary*dict
			);
			
			extern AVStream * nthStream(AVFormatContext*ctx, int nth);
		}
		
		namespace av{
			extern String error( int errcode );
		}
    } 

	namespace aveasy{
		extern Dynamic describe_AVInputFormat( AVInputFormat * iformat );
		
		extern void modifyPtr( int ** val );
	}
} //linc

#endif //_LINC_EMPTY_H_
