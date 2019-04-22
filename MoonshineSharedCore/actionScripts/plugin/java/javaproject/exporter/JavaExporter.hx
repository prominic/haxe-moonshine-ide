package actionScripts.plugin.java.javaproject.exporter;

import actionScripts.factory.FileLocation;
import actionScripts.plugin.java.javaproject.vo.JavaProjectVO;
import actionScripts.utils.MavenPomUtil;
import actionScripts.utils.SerializeUtil;

class JavaExporter {

	public static function export(project:JavaProjectVO):Void {
		FastXML.node.ignoreWhitespace = true;
		FastXML.node.ignoreComments = false;

		var projectXML:FastXML = new FastXML('<project></project>');

		projectXML.node.appendChild(project.mavenBuildOptions.toXML());

		var buildXML:FastXML = new FastXML(FastXML.parse('<build></build>'));
		var build:Dynamic = {
			'mainclass': project.mainClassName
		};
		buildXML.node.appendChild(SerializeUtil.serializePairs(build, FastXML.parse('<option/>')));

		projectXML.node.appendChild(buildXML);

		var projectSettings:FileLocation = project.folderLocation.resolvePath(project.projectName + '.javaproj');
		if (!AS3.as(projectSettings.fileBridge.exists, Bool)) {
			projectSettings.fileBridge.createFile();
		}

		projectSettings.fileBridge.save(projectXML.node.toXMLString());

		if (!project.hasPom()) {
			return;
		}

		var separator:String = Std.string(project.projectFolder.file.fileBridge.separator);
		var pomFile:FileLocation = new FileLocation(Std.string(project.mavenBuildOptions.mavenBuildPath.concat(separator, 'pom.xml')));
		var fileContent:Dynamic = pomFile.fileBridge.read();
		var pomXML:FastXML = new FastXML(fileContent);

		var sourceFolder:String = Std.string(project.projectFolder.file.fileBridge.getRelativePath(project.sourceFolder));
		pomXML = MavenPomUtil.getPomWithProjectSourceDirectory(pomXML, sourceFolder);
		pomXML = MavenPomUtil.getPomWithMainClass(pomXML, project.mainClassName);

		pomFile.fileBridge.save(pomXML.node.toXMLString());
	}

}