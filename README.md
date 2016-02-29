# linc_ffmpeg

The linc FFmpeg is a low level stub for the ffmped library in the haxe language. It is not part of the snowkit Linc initiative ( yet ? ) but we tried to follow the guidelines, they put up.

We also tried to stick as much as possible to raw binding and tried not to reinterpret the library so that regular ffmpeg tutorials are easy to follow.

This means you'll have to work around low level cpp.Pointer everywhere. Please, get used to it (for now ). We'll consider writing a more "Haxey" layer as a side lib later if collaborators pops up.

Haxe : https://github.com/HaxeFoundation/haxe
Snowkit's Linc : http://snowkit.github.io/linc/

Q&A :

What is the state of the library ?
- Is is under active development, we are now dumping data, decoding frames, next step is having an operational SDL player.

Is there dependencies ?
- We use ffmpeg binaries directly so ffmpeg binaries is a dependency, no other libraries should be involved.

Which platform are available ?
- Ffmpeg binaries exists for nearly all platforms ever, currently we only aim for win32 and macos support feel free to submit PR for binaries but be careful with testing first. ( And testing ffmpeg is quite challenging )

Contributing ?
- We accept contributions, no problem, please stick to codestyle and test your work.

Hardware acceleration ? 
- Be wary that on performance sensitive platoforms like android/ios, ffmpeg will underperform because blitting video requires heavy CPU bandwith as GPU Blitting is not so easy to get working. The HW decoding would be taken care by your build like in all ffmpeg release and GPU blitting would be taken care by your video playing setup lib ( like SDL or Native whatever ). So we strongly emphasize that hw and performances are generally a problem with linc_ffmpeg as there are strictly no overhead with this haxe layer but with the setups.




