
//import sdl.SDL;

@:unreflective
extern class Vec {
	public var x:Float;
	public var y:Float;
	public var z:Float;
}

class UTest {
	
	@:generic
	public static inline function malloc<T>(size:Int) : cpp.Pointer<T>{
		var p : cpp.RawPointer<cpp.Void> = untyped __cpp__("malloc({0})",size);
		return cpp.Pointer.fromRaw( cast p);
	}
	
    static function main() {
		var a : cpp.Pointer<Vec> = malloc(3 * 4);
		trace( a.ref.x );
	}
}