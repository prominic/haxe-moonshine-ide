package actionScripts.plugin.actionscript.as3project.vo;

import actionScripts.plugin.build.vo.BuildActionVO;
import actionScripts.utils.SerializeUtil;

class MavenBuildOptions {

	private var _defaultMavenBuildPath:String;
	private var _buildActions:Array<Dynamic>;

	public function new(defaultMavenBuildPath:String) {
		_defaultMavenBuildPath = defaultMavenBuildPath;
	}

	public var commandLine:String;
	public var settingsFilePath:String;

	private var _mavenBuildPath:String;

	public var mavenBuildPath(get, set):String;
	private function get_mavenBuildPath():String {
		return (_mavenBuildPath == null) ? _defaultMavenBuildPath : _mavenBuildPath;
	}

	private function set_mavenBuildPath(value:String):String {
		_mavenBuildPath = value;
		return value;
	}

	public var buildActions(get, never):Array<Dynamic>;
	private function get_buildActions():Array<Dynamic> {
		if (_buildActions == null) {
			_buildActions = cast [
					new BuildActionVO('Build', 'install'),
					new BuildActionVO('Clean and package', 'clean package'),
					new BuildActionVO('Clean', 'clean'),
					new BuildActionVO('Clean and Build', 'clean install'),
					new BuildActionVO('Exploded', 'war:exploded')
			];
		}

		return _buildActions;
	}

	public function getCommandLine():Array<Dynamic> {
		var commandLineOptions:Array<String> = cast [];

		if (settingsFilePath != null) {
			commandLineOptions.push('-settings '.concat('"', settingsFilePath, '"'));
		}

		if (commandLine != null) {
			if (commandLineOptions.length > 0) {
				commandLineOptions = commandLineOptions.concat(commandLine.split(' '));
			} else {
				commandLineOptions = commandLine.split(' ');
			}
			commandLineOptions = as3hx.Compat.filter(commandLineOptions, function(item:String, index:Int, arr:Array<Dynamic>):Bool {
								item = Std.string(StringTools.trim(item));
								if (item != null) {
									return true;
								}

								return false;
							});
		}

		return cast commandLineOptions;
	}

	public function parse(build:FastXMLList):Void {
		parseOptions(build.descendants('option'));
		parseActions(build.descendants('actions').descendants('action'));
	}

	public function toXML():FastXML {
		var build:FastXML = FastXML.parse('<mavenBuild/>');

		var pairs:Dynamic = {
			'mavenBuildPath': SerializeUtil.serializeString(mavenBuildPath),
			'commandLine': SerializeUtil.serializeString(commandLine),
			'settingsFilePath': SerializeUtil.serializeString(settingsFilePath)
		};

		build.node.appendChild(SerializeUtil.serializePairs(pairs, FastXML.parse('<option/>')));

		var availableOptions:FastXML = FastXML.parse('<actions/>');
		for (item_ in this.buildActions) {
			var item:BuildActionVO = cast item_;
			availableOptions.node.appendChild(SerializeUtil.serializeObjectPairs(
							{
								'action': Reflect.field(item, 'action'),
								'actionName': Reflect.field(item, 'actionName')
							},
							FastXML.parse('<action />')
				));
		}

		build.node.appendChild(availableOptions);

		return build;
	}

	private function parseOptions(options:FastXMLList):Void {
		mavenBuildPath = SerializeUtil.deserializeString(options.att.mavenBuildPath);
		commandLine = SerializeUtil.deserializeString(options.att.commandLine);
		settingsFilePath = SerializeUtil.deserializeString(options.att.settingsFilePath);
	}

	private function parseActions(actions:FastXMLList):Void {
		if (actions.length() > 0) {
			buildActions.splice(0, _buildActions.length);
			for (i in 0...actions.length()) {
				if (actions.get(i) != null) {
					buildActions.push(new BuildActionVO(Std.string(actions.get(i).att.actionName), Std.string(actions.get(i).att.action)));
				}
			}
		}
	}

}