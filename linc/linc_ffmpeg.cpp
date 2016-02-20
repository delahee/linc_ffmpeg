#ifndef _LINC_FFMPEG_CPP_
#define _LINC_FFMPEG_CPP_

#include "linc_ffmpeg.h"

#include <hxcpp.h>

namespace linc {

    namespace ffmpeg {

    } //empty namespace

	namespace aveasy{
		
		Dynamic describe_AVInputFormat( AVInputFormat * iformat ) {
			hx::Anon out = hx::Anon_obj::Create();
			if( !iformat )
				return out;
				
			/*
				"name: %s\n"
				"long_name: %s\n"
				"priv_data_size: %d\n"
				"read_probe: %p\n"
				"read_header: %p\n" "read_packet: %p\n" "read_close: %p\n"
				"read_timestamp: %p\n"
				"flags %x\n"
				"read_play: %p\n"
				"read_pause: %p\n"
				"read_seek2: %p\n",*/
			out->Add(HX_CSTRING("name")				,::String(iformat->name));
			out->Add(HX_CSTRING("long_name")		,::String(iformat->long_name));
			out->Add(HX_CSTRING("priv_data_size")	,iformat->priv_data_size);
			out->Add(HX_CSTRING("read_probe")		,iformat->read_probe);
			out->Add(HX_CSTRING("read_header")		,iformat->read_header);
			out->Add(HX_CSTRING("read_packet")		,iformat->read_packet);
			out->Add(HX_CSTRING("read_close")		,iformat->read_close);
			out->Add(HX_CSTRING("read_timestamp")	,iformat->read_timestamp),
			out->Add(HX_CSTRING("flags")			,iformat->flags),
			out->Add(HX_CSTRING("read_play")		,iformat->read_play);
			out->Add(HX_CSTRING("read_pause")		,iformat->read_pause);
			out->Add(HX_CSTRING("read_seek2")		,iformat->read_seek2);
			return out;
		}
	}
} //linc

#endif