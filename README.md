# linc_ffmpeg

The linc FFmpeg is a low level stub for the ffmpeg library (https://www.ffmpeg.org/) in the haxe language. It is not part of the snowkit Linc initiative ( yet ? ) but we tried to follow the guidelines they put up.

We also tried to stick as much as possible to raw binding and tried not to reinterpret the library so that regular ffmpeg tutorials are easy to follow.

This means you'll have to work around low level cpp.Pointer everywhere. Please, get used to it (for now ). We'll consider writing a more "Haxey" layer as a side lib later if collaborators pops up.

Haxe : https://github.com/HaxeFoundation/haxe
Snowkit's Linc : http://snowkit.github.io/linc/

Q&A :

What is the state of the library ?
- Is is under active development, we are now dumping data, decoding frames, next step is having an operational SDL player.

Is there dependencies ?
- We use ffmpeg binaries directly so ffmpeg binaries is a dependency, no other libraries should be involved.

Why choose binaries not recompile source ?
- Ffmpeg requires a tremendous amount of libs to be built, since there are good quality binaries, let's disminish the burden of rebuilding.

Which platform are available ?
- Ffmpeg binaries exists for nearly all platforms ever, currently we only aim for win32 and macos support feel free to submit PR for binaries but be careful with testing first. ( And testing ffmpeg is quite challenging )

Contributing ?
- We accept contributions, no problem, please stick to codestyle and test your work.

Hardware acceleration ? 
- Be wary that on performance sensitive platoforms like android/ios, ffmpeg will underperform because blitting video requires heavy CPU bandwith as GPU Blitting is not so easy to get working. The HW decoding would be taken care by your build like in all ffmpeg release and GPU blitting would be taken care by your video playing setup lib ( like SDL or Native whatever ). 

How to build ?

Here is my current setup. Since linc_ffmpeg is not in production and relying on a moderately stable hxcpp features, be careful 
- haxe -version
3.3.0 (git build development @ 3d8d06a)
- hxcpp revision : a802af374ba3cc3be8927a93678a7193d679f1d4
- for samples ( recommended ), you'll need SDL from github.com/delahee/linc_sdl
- if you want to build for other plaftorms, you have to retrieve ffmpeg binaries and place them aside windows binaries AND add the ffmpeg necessary build step in the linc/linc_ffmpeg.xml ( please refer to other linc libraries for these) 
 
We strongly emphasize that hw and performances are generally a touchy problem with ffmpeg, the layer itself is free of superfluous allocation so everything should be in order but be careful about setup.




