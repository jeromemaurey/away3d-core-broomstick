WARNING:
this is a very, very, very experimental fork of the main Away3D Broomstick repository. Use at your own risk. 

Changes:

//// 110606 ////

CCTV Material
implemented modifications to the API mentioned in this thread to allow context.drawToBitmap()
http://groups.google.com/group/away3d-dev/browse_thread/thread/7b2ad43fefc688b3/54771671c04a1cde

Sound3D
Changed the return value of void to SoundChannel on Sound3D.play() to allow the implementation of Event.SOUND_COMPLETE and loop the audio attached to the Sound3D.