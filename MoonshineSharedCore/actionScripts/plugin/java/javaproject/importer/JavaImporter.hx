package actionScripts.plugin.java.javaproject.importer;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.utils.MavenPomUtil;

class JavaImporter extends FlashDevelopImporterBase {

	private static inline var FILE_EXTENSION_JAVAPROJ:String = '.javaproj';
	private static inline var FILE_NAME_POM_XML:String = 'pom.xml';
	private static inline var FILE_NAME_BUILD_GRADLE:String = 'build.gradle';

	public static function test(file:Dynamic):FileLocation {
		if (!AS3.as(Reflect.field(file, 'exists'), Bool)) {
			return null;
		}

		var listing:Array<Dynamic> = file.getDirectoryListing();
		var projectFile:FileLocation = null;
		var pomFile:FileLocation = null;
		var gradleFile:FileLocation = null;
		for (i in listing) {
			var fileName:String = AS3.string(Reflect.field(i, 'name'));
			if (fileName == FILE_NAME_POM_XML) {
				pomFile = new FileLocation(AS3.string(Reflect.field(i, 'nativePath')));
			} else if (fileName == FILE_NAME_BUILD_GRADLE) {
				gradleFile = new FileLocation(AS3.string(Reflect.field(i, 'nativePath')));
			} else {
				var extensionIndex:Int = fileName.lastIndexOf(FILE_EXTENSION_JAVAPROJ);
				if (extensionIndex != -1 && extensionIndex == (fileName.length - FILE_EXTENSION_JAVAPROJ.length)) {
					projectFile = new FileLocation(AS3.string(Reflect.field(i, 'nativePath')));
				}
			}
		}

		if (projectFile != null) {
			if (pomFile != null) {
				return pomFile;
			} else if (gradleFile != null) {
				return gradleFile;
			}
		}

		return null;
	}

	public static function parse(projectFolder:FileLocation, projectName:String = null, settingsFileLocation:FileLocation = null):JavaProjectVO {
		if (projectName == null) {
			var airFile:Dynamic = projectFolder.fileBridge.getFile;
			projectName = AS3.string(Reflect.field(airFile, 'name'));
		}

		if (settingsFileLocation == null) {
			settingsFileLocation = projectFolder.fileBridge.resolvePath(projectName + FILE_EXTENSION_JAVAPROJ);
		}

		var javaProject:JavaProjectVO = new JavaProjectVO(projectFolder, projectName);

		var sourceDirectory:String = null;
		var settingsData:FastXML = null;
		if (AS3.as(settingsFileLocation.fileBridge.exists, Bool)) {
			settingsData = new FastXML(settingsFileLocation.fileBridge.read());
		}

		var separator:String = Std.string(javaProject.projectFolder.file.fileBridge.separator);

		var defaultSourceFolderPath:String = Std.string('src'.concat(separator, 'main', separator, 'java'));

		if (javaProject.hasPom()) {
			if (settingsData != null) {
				javaProject.mavenBuildOptions.parse(settingsData.node.mavenBuild);
			}

			var pomFile:FileLocation = new FileLocation(
			Std.string(javaProject.mavenBuildOptions.mavenBuildPath.concat(separator, FILE_NAME_POM_XML)));

			sourceDirectory = MavenPomUtil.getProjectSourceDirectory(pomFile);
			if (sourceDirectory == null) {
				sourceDirectory = defaultSourceFolderPath;
			}

			javaProject.mainClassName = MavenPomUtil.getMainClassName(pomFile);
			addSourceDirectoryToProject(javaProject, sourceDirectory);

			javaProject.classpaths.push(javaProject.sourceFolder);
		} else {
			parsePaths(settingsData.nodes.classpaths.get('class'), cast javaProject.classpaths, javaProject, 'path');
			javaProject.mainClassName = Std.string(settingsData.nodes.build.descendants('option').att.mainclass);

			if (javaProject.classpaths.length > 0) {
				sourceDirectory = Std.string(javaProject.classpaths[0].fileBridge.nativePath);
			}

			addSourceDirectoryToProject(javaProject, sourceDirectory);
		}

		if (javaProject.mainClassName == null) {
			javaProject.mainClassName = projectName;
		}

		return javaProject;
	}

	private static function addSourceDirectoryToProject(javaProject:JavaProjectVO, sourceDirectory:String):Void {
		if (sourceDirectory != null) {
			javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath(sourceDirectory);
		}

		if (sourceDirectory == null || !AS3.as(javaProject.sourceFolder.fileBridge.exists, Bool)) {
			javaProject.sourceFolder = javaProject.projectFolder.file.fileBridge.resolvePath('src');
		}
	}

}