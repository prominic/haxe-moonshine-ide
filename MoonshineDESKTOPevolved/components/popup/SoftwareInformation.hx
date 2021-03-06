/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup
 *  Class:      SoftwareInformation
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineDESKTOPevolved/src/components/popup/SoftwareInformation.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:13:57 MSK
 */

package components.popup;

import mx.collections.ArrayCollection;
import mx.events.FlexEvent;
import mx.utils.ObjectUtil;
import actionScripts.locator.HelperModel;
import actionScripts.locator.IDEModel;
import actionScripts.utils.FileUtils;
import actionScripts.utils.SDKUtils;
import actionScripts.utils.SoftwareVersionChecker;
import actionScripts.valueObjects.ComponentTypes;
import actionScripts.valueObjects.ComponentVO;
import actionScripts.valueObjects.SDKReferenceVO;

import components.popup.SoftwareInformationInnerClass0;
import flash.accessibility.*;
import flash.data.*;
import flash.debugger.*;
import flash.desktop.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.external.*;
import flash.filesystem.*;
import flash.geom.*;
import flash.html.*;
import flash.html.script.*;
import flash.media.*;
import flash.net.*;
import flash.printing.*;
import flash.profiler.*;
import flash.system.*;
import flash.text.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;
import mx.binding.*;
import mx.binding.IBindingClient;
import mx.collections.ArrayList;
import mx.collections.IList;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.Mx_internal;

import mx.filters.*;
import mx.styles.*;
import spark.components.DataGrid;
import spark.components.Label;
import spark.components.VGroup;
import spark.components.gridClasses.GridColumn;

@:meta(Event(name = 'complete', type = 'flash.events.Event'))
class SoftwareInformation extends spark.components.VGroup implements mx.binding.IBindingClient {

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var dgComponents:spark.components.DataGrid;

	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _SoftwareInformation_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_SoftwareInformationWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(SoftwareInformation, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.autoLayout = true;
		this.mxmlContent = [_SoftwareInformation_Label1_c(), _SoftwareInformation_DataGrid1_i()];

		// events
		this.addEventListener('creationComplete', ___SoftwareInformation_VGroup1_creationComplete);

		for (i in 0...bindings.length) {
			AS3.as(bindings[i], Binding).execute();
		}

	}

	/**
	 * @private
	 **/
	private var __moduleFactoryInitialized:Bool = false;

	/**
	 * @private
	 * Override the module factory so we can defer setting style declarations
	 * until a module factory is set. Without the correct module factory set
	 * the style declaration will end up in the wrong style manager.
	 **/
	override private function set_moduleFactory(factory:IFlexModuleFactory):IFlexModuleFactory {
		super.moduleFactory = factory;

		if (__moduleFactoryInitialized) {
			return factory;
		}

		__moduleFactoryInitialized = true;

		// our style settings

		return factory;
	}

	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	@:meta(Bindable())
	private var flexSDKPath:String = '- Not Installed -';
	@:meta(Bindable())
	private var AntPath:String = '- Not Installed -';
	@:meta(Bindable())
	private var model:IDEModel = IDEModel.getInstance();
	@:meta(Bindable())
	private var components:ArrayCollection;

	private var versionChecker:SoftwareVersionChecker = new SoftwareVersionChecker();

	/**
	 * On creation completes
	 */
	public function onSoftwareInfoCreationComplete(event:FlexEvent):Void {
		RegisterClassAlias.registerClassAlias('actionScripts.valueObjects.ComponentVO', ComponentVO);
		components = AS3.as(ObjectUtil.copy(HelperModel.getInstance().components), ArrayCollection);
		updateWithMoonshinePaths();

		var tmpAddition:ComponentVO = new ComponentVO();
		tmpAddition.title = 'Default SDK';
		if (AS3.as(model.defaultSDK, Bool) && AS3.as(model.defaultSDK.fileBridge.exists, Bool)) {
			var sdkReference:SDKReferenceVO = SDKUtils.getSDKFromSavedList(model.defaultSDK.fileBridge.nativePath);
			tmpAddition.type = sdkReference.type;
			tmpAddition.installToPath = sdkReference.path;
		}
		components.addItemAt(tmpAddition, 0);

		versionChecker.addEventListener(Event.COMPLETE, onRetrievalComplete, false, 0, true);
		versionChecker.retrieveAboutInformation(components);
	}

	private function updateWithMoonshinePaths():Void {
		var sdkReference:SDKReferenceVO;
		for (component in components) {
			sdkReference = null;
			Reflect.setField(component, 'installToPath', null);
			switch (Reflect.field(component, 'type')) {
				case ComponentTypes.TYPE_FLEX, ComponentTypes.TYPE_FEATHERS, ComponentTypes.TYPE_ROYALE, ComponentTypes.TYPE_FLEXJS:
					sdkReference = SDKUtils.checkSDKTypeInSDKList(Reflect.field(component, 'type'));
					Reflect.setField(component, 'installToPath', (sdkReference != null) ? sdkReference.path : null);
				case ComponentTypes.TYPE_OPENJAVA:
					if (AS3.as(model.javaPathForTypeAhead, Bool) && AS3.as(model.javaPathForTypeAhead.fileBridge.exists, Bool)) {
						Reflect.setField(component, 'installToPath', model.javaPathForTypeAhead.fileBridge.nativePath);
					}
				case ComponentTypes.TYPE_GIT:
					if (AS3.as(model.gitPath, Bool) && AS3.as(FileUtils.isPathExists(model.gitPath), Bool)) {
						Reflect.setField(component, 'installToPath', model.gitPath);
					}
				case ComponentTypes.TYPE_MAVEN:
					if (AS3.as(model.mavenPath, Bool) && AS3.as(FileUtils.isPathExists(model.mavenPath), Bool)) {
						Reflect.setField(component, 'installToPath', model.mavenPath);
					}
				case ComponentTypes.TYPE_SVN:
					if (AS3.as(model.svnPath, Bool) && AS3.as(FileUtils.isPathExists(model.svnPath), Bool)) {
						Reflect.setField(component, 'installToPath', model.svnPath);
					}
				case ComponentTypes.TYPE_ANT:
					if (AS3.as(model.antHomePath, Bool) && AS3.as(model.antHomePath.fileBridge.exists, Bool)) {
						Reflect.setField(component, 'installToPath', model.antHomePath.fileBridge.nativePath);
					}
			}

			Reflect.setField(component, 'version', null);
		}
	}

	private function onRetrievalComplete(event:Event):Void {
		versionChecker.removeEventListener(Event.COMPLETE, onRetrievalComplete);
		dispatchEvent(event);
	}

	//  supporting function definitions for properties, events, styles, effects
	private function _SoftwareInformation_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Configured SDKs in Moonshine:';
		temp.setStyle('color', 3355443);
		temp.setStyle('paddingLeft', 8);
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _SoftwareInformation_DataGrid1_i():spark.components.DataGrid {
		var temp:spark.components.DataGrid = new spark.components.DataGrid();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.sortableColumns = false;
		temp.variableRowHeight = true;
		temp.columns = _SoftwareInformation_ArrayList1_c();
		temp.addEventListener('initialize', __dgComponents_initialize);
		temp.id = 'dgComponents';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		dgComponents = temp;
		mx.binding.BindingManager.executeBindings(this, 'dgComponents', dgComponents);
		return temp;
	}

	private function _SoftwareInformation_ArrayList1_c():mx.collections.ArrayList {
		var temp:mx.collections.ArrayList = new mx.collections.ArrayList();
		temp.source = [_SoftwareInformation_GridColumn1_c(), _SoftwareInformation_GridColumn2_c()];
		return temp;
	}

	private function _SoftwareInformation_GridColumn1_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.dataField = 'title';
		return temp;
	}

	private function _SoftwareInformation_GridColumn2_c():spark.components.gridClasses.GridColumn {
		var temp:spark.components.gridClasses.GridColumn = new spark.components.gridClasses.GridColumn();
		temp.width = 300;
		temp.itemRenderer = _SoftwareInformation_ClassFactory1_c();
		return temp;
	}

	private function _SoftwareInformation_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = components.popup.SoftwareInformationInnerClass0;
		temp.properties = {
					'outerDocument': this
				};
		return temp;
	}

	/**
	 * @private
	 **/
	public function __dgComponents_initialize(event:mx.events.FlexEvent):Void {
		dgComponents.columnHeaderGroup.visible = dgComponents.columnHeaderGroup.includeInLayout = false;
	}

	/**
	 * @private
	 **/
	public function ___SoftwareInformation_VGroup1_creationComplete(event:mx.events.FlexEvent):Void {
		onSoftwareInfoCreationComplete(event);
	}

	//  binding mgmt
	private function _SoftwareInformation_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():mx.collections.IList {
					return (components);
				},
				null,
				'dgComponents.dataProvider');

		result[1] = new mx.binding.Binding(this,
				function():Int {
					return AS3.int(components.length);
				},
				null,
				'dgComponents.requestedMaxRowCount');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(SoftwareInformation)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindings:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _watchers:Array<Dynamic> = [];
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsByDestination:Dynamic = {};
	/**
	 * @private
	 **/
	@:ns('mx_internal') private var _bindingsBeginWithWord:Dynamic = {};

}