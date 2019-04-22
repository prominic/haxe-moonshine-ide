package actionScripts.plugin.actionscript.as3project.vo;

import actionScripts.utils.SerializeUtil;

class JavaMavenBuildOptions extends MavenBuildOptions {

	public function new(defaultMavenBuildPath:String) {
		super(defaultMavenBuildPath);
	}

	@:access(FastXMLList) override public function parse(build:FastXMLList):Void {
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		commandLine = SerializeUtil.deserializeString(build.projectbuildaction);
	}

}