package actionScripts.plugin.java.javaproject.vo;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.actionscript.as3project.settings.PathListSetting;
import actionScripts.plugin.actionscript.as3project.vo.MavenBuildOptions;
import actionScripts.plugin.java.javaproject.exporter.JavaExporter;
import actionScripts.plugin.settings.vo.BuildActionsListSettings;
import actionScripts.plugin.settings.vo.ISetting;
import actionScripts.plugin.settings.vo.ProjectDirectoryPathSetting;
import actionScripts.plugin.settings.vo.SettingsWrapper;
import actionScripts.valueObjects.ProjectVO;

class JavaProjectVO extends ProjectVO {

	public static inline var CHANGE_CUSTOM_SDK:String = 'CHANGE_CUSTOM_SDK';

	public var mavenBuildOptions:MavenBuildOptions;
	public var classpaths:Array<FileLocation> = new Array<FileLocation>();
	public var sourceFolder:FileLocation;

	public var mainClassName:String;

	public function new(folder:FileLocation, projectName:String = null, updateToTreeView:Bool = true) {
		super(folder, projectName, updateToTreeView);

		projectReference.hiddenPaths.splice(0, projectReference.hiddenPaths.length);
		mavenBuildOptions = new MavenBuildOptions(projectFolder.nativePath);
	}

	public function hasPom():Bool {
		var pomFile:FileLocation = new FileLocation(mavenBuildOptions.mavenBuildPath).resolvePath('pom.xml');
		return AS3.as(pomFile.fileBridge.exists, Bool);
	}

	public function hasGradleBuild():Bool {
		var gradleFile:FileLocation = projectFolder.file.fileBridge.resolvePath('build.gradle');
		return AS3.as(gradleFile.fileBridge.exists, Bool);
	}

	override public function getSettings():Array<SettingsWrapper> {
		function order(a:Dynamic, b:Dynamic):Float {
			if (Reflect.field(a, 'name') < Reflect.field(b, 'name')) {
				return -1;
			} else if (Reflect.field(a, 'name') > Reflect.field(b, 'name')) {
				return 1;
			}
			return 0;
		};
		var settings:Array<SettingsWrapper> = cast getJavaSettings();
		settings.sort(function order(a:Dynamic, b:Dynamic):Float {
					if (Reflect.field(a, 'name') < Reflect.field(b, 'name')) {
						return -1;
					} else if (Reflect.field(a, 'name') > Reflect.field(b, 'name')) {
						return 1;
					}
					return 0;
				});

		return settings;
	}

	override public function saveSettings():Void {
		JavaExporter.export(this);
	}

	private function getJavaSettings():Array<SettingsWrapper> {
		var settings:Array<SettingsWrapper> = [
				new SettingsWrapper('Paths',
				[
						new PathListSetting(this, 'classpaths', 'Class paths', folderLocation, false, true, true, true)
			])
		];

		if (hasPom()) {
			settings.push(new SettingsWrapper('Maven Build', [
							new ProjectDirectoryPathSetting(this.mavenBuildOptions, this.projectFolder.nativePath, 'mavenBuildPath', 'Maven Build File', this.mavenBuildOptions.mavenBuildPath),
							new BuildActionsListSettings(this.mavenBuildOptions, mavenBuildOptions.buildActions, 'commandLine', 'Build Actions')
				]));
		}

		return settings;
	}

}