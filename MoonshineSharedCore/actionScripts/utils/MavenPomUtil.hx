package actionScripts.utils;

import actionScripts.factory.FileLocation;

class MavenPomUtil {

	@:access(FastXML) public static function getProjectId(pomLocation:FileLocation):String {
		var fileContent:Dynamic = pomLocation.fileBridge.read();
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var pomXML:FastXML = new FastXML(fileContent);

		return Std.string(pomXML.artifactId);
	}

	@:access(FastXML) public static function getProjectVersion(pomLocation:FileLocation):String {
		var fileContent:Dynamic = pomLocation.fileBridge.read();
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var pomXML:FastXML = new FastXML(fileContent);

		return Std.string(pomXML.version);
	}

	@:access(FastXML) public static function getProjectSourceDirectory(pomLocation:FileLocation):String {
		var fileContent:Dynamic = pomLocation.fileBridge.read();
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var pomXML:FastXML = new FastXML(fileContent);
		var buildName:QName = new QName(xsiNamespace, 'build');

		if (AS3.as(AS3.hasOwnProperty(pomXML, Std.string(buildName)), Bool)) {
			var build:FastXML = new FastXML(pomXML.build);
			var sourceDirectory:QName = new QName(xsiNamespace, 'sourceDirectory');
			if (AS3.as(AS3.hasOwnProperty(build, Std.string(sourceDirectory)), Bool)) {
				return Std.string(build.sourceDirectory);
			}
		}

		return '';
	}

	@:access(FastXML) @:access(FastXMLList) public static function getMainClassName(pomLocation:FileLocation):String {
		var fileContent:Dynamic = pomLocation.fileBridge.read();
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var pomXML:FastXML = new FastXML(fileContent);
		var buildName:QName = new QName(xsiNamespace, 'build');

		if (AS3.as(AS3.hasOwnProperty(pomXML, Std.string(buildName)), Bool)) {
			var build:FastXML = new FastXML(pomXML.build);
			if (build.nodes.xsiNamespace.descendants('plugins').length() == 0) {
				return '';
			}

			var plugins:FastXML = new FastXML(build.plugins);
			var plugin:FastXMLList = plugins.plugin;

			for (p in plugin) {
				var artifactId:String = Std.string(p.artifactId);
				if (artifactId == 'maven-jar-plugin') {
					var manifest:FastXMLList = p.configuration.archive.manifest;
					if (manifest.length() == 0) {
						break;
					}

					return Std.string(manifest.mainClass);
				}
			}
		}

		return '';
	}

	@:access(FastXML) public static function getPomWithProjectSourceDirectory(pomXML:FastXML, sourceDirectory:String):FastXML {
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var build:FastXML = null;
		var buildName:QName = new QName(xsiNamespace, 'build');

		if (!AS3.as(AS3.hasOwnProperty(pomXML, Std.string(buildName)), Bool)) {
			pomXML.build.sourceDirectory = new FastXML('<sourceDirectory>' + sourceDirectory + '</sourceDirectory>');
		} else {
			var sourceDirectoryQName:QName = new QName(xsiNamespace, 'sourceDirectory');
			build = FastXML.parse(pomXML.build);

			if (!AS3.as(AS3.hasOwnProperty(build, Std.string(sourceDirectoryQName)), Bool)) {
				pomXML.build.sourceDirectory = sourceDirectory;
			} else {
				var currentSourceFolder:String = Std.string(build.sourceDirectory);
				if (sourceDirectory != currentSourceFolder) {
					build.sourceDirectory = sourceDirectory;
				}
			}
		}

		return pomXML;
	}

	@:access(FastXML) @:access(FastXMLList) public static function getPomWithMainClass(pomXML:FastXML, mainClassName:String):FastXML {
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');

		var buildName:QName = new QName(xsiNamespace, 'build');
		var pluginsXML:FastXML = null;

		if (!AS3.as(AS3.hasOwnProperty(pomXML, Std.string(buildName)), Bool)) {
			pluginsXML = new FastXML('<plugins></plugins>');
			addPluginMainClassToPlugins(pluginsXML, mainClassName);
			pomXML.build.plugins = plugins;
		} else {
			var build:FastXML = FastXML.parse(pomXML.build);
			var plugins:FastXMLList = build.plugins;

			if (plugins.length() == 0) {
				pluginsXML = new FastXML('<plugins></plugins>');
				addPluginMainClassToPlugins(pluginsXML, mainClassName);
				pomXML.build.plugins = pluginsXML;
			} else {
				var xmlManifest:FastXML = null;
				pluginsXML = FastXML.parse(build.plugins);
				plugins = pluginsXML.plugin;
				for (p in plugins) {
					var artifactId:String = Std.string(p.artifactId);
					if (artifactId == 'maven-jar-plugin') {
						var manifest:FastXMLList = p.configuration.archive.manifest;
						if (manifest.length() > 0) {
							xmlManifest = FastXML.parse(p.configuration.archive.manifest);
							break;
						}
					}
				}

				if (xmlManifest == null) {
					addPluginMainClassToPlugins(pluginsXML, mainClassName);
				} else {
					var currentMainClass:String = Std.string(xmlManifest.mainClass);
					if (mainClassName != currentMainClass) {
						xmlManifest.mainClass = new FastXML('<mainClass>' + mainClassName + '</mainClass>');
					}
				}
			}
		}

		return pomXML;
	}

	private static function addPluginMainClassToPlugins(plugins:FastXML, mainClassName:String):Void {
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		plugins.node.addNamespace(xsiNamespace);
		plugins.node.setNamespace(xsiNamespace);

		var plugin:FastXML = addPluginJarToPlugins(plugins);

		var conf:FastXML = new FastXML('<configuration>\n' +
		'                    <archive>\n' +
		'                      <manifest>\n' +
		'                        <mainClass>' + mainClassName + '</mainClass>\n' +
		'                      </manifest>\n' +
		'                    </archive>\n' +
		'                  </configuration>');
		conf.node.addNamespace(xsiNamespace);
		conf.node.setNamespace(xsiNamespace);

		plugin.node.appendChild(conf);
		plugins.node.appendChild(plugin);
	}

	private static function addPluginJarToPlugins(plugins:FastXML):FastXML {
		var xsiNamespace:Namespace = new Namespace('', 'http://maven.apache.org/POM/4.0.0');
		var plugin:FastXML = new FastXML('<plugin>\n' +
		'                  <groupId>org.apache.maven.plugins</groupId>\n' +
		'                  <artifactId>maven-jar-plugin</artifactId>\n' +
		'            </plugin>');
		plugin.node.addNamespace(xsiNamespace);
		plugin.node.setNamespace(xsiNamespace);

		plugins.node.appendChild(plugin);

		return plugin;
	}

}