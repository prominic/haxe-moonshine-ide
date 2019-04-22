package actionScripts.valueObjects;

class WorkerNativeProcessResult {

	public static inline var OUTPUT_TYPE_ERROR:String = 'typeError';
	public static inline var OUTPUT_TYPE_DATA:String = 'typeData';
	public static inline var OUTPUT_TYPE_CLOSE:String = 'typeProcessClose';

	public var output:String;
	public var type:String;
	public var queue:Dynamic;

	public function new(type:String, output:String, queue:Dynamic = null /** type of NativeProcessQueueVO **/  /** type of NativeProcessQueueVO **/ ) {
		this.type = type;
		this.output = output;
		this.queue = queue;
	}

}