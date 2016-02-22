#ifndef _LINC_FFMPEG_CPP_
#define _LINC_FFMPEG_CPP_

#include "linc_ffmpeg.h"

#include <hxcpp.h>

namespace linc {
    namespace ffmpeg {
		namespace avformat{
			Dynamic openInput(
				::String filename, 
				AVFormatContext*ctx,
				AVInputFormat*fmt,
				AVDictionary*dict
			){
				printf("openInput: %d %d %d\n",ctx,fmt,dict);
				hx::Anon out = hx::Anon_obj::Create();
				printf("*\n");
				AVFormatContext** pctx = ctx==0? 0 : &ctx;
				printf("*\n");
				AVDictionary** pdict = dict==0?0: &dict;
				printf("*\n");
				int retCode = avformat_open_input(pctx,filename.c_str(),fmt,pdict);
				printf("retCode %d *\n",retCode);
				out->Add(HX_CSTRING("retCode"), retCode);
				if( pctx ) 	out->Add(HX_CSTRING("ctx"), *pctx);
				if( pdict ) out->Add(HX_CSTRING("opt"), *pdict);
				printf("*\n");
				return out;
			}
		}
		
		namespace av{
			::String error( int errcode ){
				char * err = (char*) malloc( 512 );
				err[0]=0;
				
				av_make_error_string(err,512,errcode);
				
				return ::String(err);
			}
		}

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
		
		/*
		void modifyPtr( int ** val ) {
			int * v = (int*) malloc( sizeof(int) );
			*v = 1;
			val = &v;
		}
		*/
	}
} //linc

#endif