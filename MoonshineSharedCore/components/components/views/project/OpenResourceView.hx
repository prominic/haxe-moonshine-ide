/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.views.project
 *  Class:      OpenResourceView
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/views/project/OpenResourceView.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:49 MSK
 */

package components.views.project;

import mx.collections.ArrayCollection;
import mx.events.ListEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.OpenFileEvent;
import actionScripts.factory.FileLocation;
import actionScripts.plugin.project.ProjectPlugin;
import actionScripts.valueObjects.FileWrapper;

import haxe.Constraints.Function;
import actionScripts.ui.IPanelWindow;
import actionScripts.ui.project.ProjectViewHeader;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.KeyboardEvent;
import flash.external.*;
import flash.filters.*;
import flash.geom.*;
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
import mx.containers.VBox;
import mx.controls.HRule;
import mx.controls.List;
import mx.core.ClassFactory;
import mx.core.DeferredInstanceFromClass;
import mx.core.DeferredInstanceFromFunction;
import mx.core.IDeferredInstance;
import mx.core.IFactory;
import mx.core.IFlexModuleFactory;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponentDescriptor;
import mx.core.Mx_internal;
import mx.events.FlexEvent;

import mx.styles.*;
import spark.components.TextInput;
import spark.events.TextOperationEvent;
import spark.filters.DropShadowFilter;

//  begin class def
class OpenResourceView extends mx.containers.VBox implements actionScripts.ui.IPanelWindow implements mx.binding.IBindingClient {

	//  instance variables
	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var header:actionScripts.ui.project.ProjectViewHeader;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var list:mx.controls.List;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var textInput:spark.components.TextInput;

	//  type-import dummies

	//  Container document descriptor
	private var _documentDescriptor_:mx.core.UIComponentDescriptor;

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		this._documentDescriptor_ =
				new mx.core.UIComponentDescriptor({
					'type': mx.containers.VBox,
					'propertiesFactory': function():Dynamic {
						return {
							'childDescriptors': [
							new mx.core.UIComponentDescriptor({
								'type': actionScripts.ui.project.ProjectViewHeader,
								'id': 'header',
								'propertiesFactory': function():Dynamic {
									return {
										'label': 'Open resource',
										'percentWidth': 100.0
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': mx.containers.VBox,
								'stylesFactory': function():Void {
									this.backgroundColor = 3487029;
									this.verticalAlign = 'middle';
									this.horizontalAlign = 'center';
								},
								'propertiesFactory': function():Dynamic {
									return {
										'percentWidth': 100.0,
										'height': 35,
										'childDescriptors': [
										new mx.core.UIComponentDescriptor({
											'type': spark.components.TextInput,
											'id': 'textInput',
											'events': {
												'creationComplete': '__textInput_creationComplete',
												'change': '__textInput_change',
												'keyDown': '__textInput_keyDown'
											},
											'stylesFactory': function():Void {
												this.paddingLeft = 8;
												this.paddingBottom = 0;
												this.focusThickness = 0;
												this.borderVisible = false;
												this.contentBackgroundAlpha = 0;
												this.fontFamily = 'DejaVuSans';
												this.fontSize = 12;
												this.color = 11974326;
											},
											'propertiesFactory': function():Dynamic {
												return {
													'percentWidth': 100.0,
													'filters': [this._OpenResourceView_DropShadowFilter1_c()]
												};
											}
										})
					]
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': mx.controls.HRule,
								'stylesFactory': function():Void {
									this.strokeColor = 2960685;
								},
								'propertiesFactory': function():Dynamic {
									return {
										'percentWidth': 100.0,
										'height': 1
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': mx.controls.HRule,
								'stylesFactory': function():Void {
									this.strokeColor = 5921370;
								},
								'propertiesFactory': function():Dynamic {
									return {
										'percentWidth': 100.0,
										'height': 1
									};
								}
							}),
							new mx.core.UIComponentDescriptor({
								'type': mx.controls.List,
								'id': 'list',
								'events': {
									'itemDoubleClick': '__list_itemDoubleClick'
								},
								'stylesFactory': function():Void {
									this.borderVisible = false;
									this.color = 15658734;
									this.contentBackgroundColor = 0;
									this.rollOverColor = 3750201;
									this.selectionColor = 3750201;
									this.alternatingItemColors = [4473924, 5065804];
								},
								'propertiesFactory': function():Dynamic {
									return {
										'percentWidth': 100.0,
										'percentHeight': 100.0,
										'doubleClickEnabled': true,
										'rowHeight': 18,
										'selectedIndex': 0
									};
								}
							})
				]
						};
					}
				});
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _OpenResourceView_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_views_project_OpenResourceViewWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(OpenResourceView, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.percentWidth = 100.0;
		this.percentHeight = 100.0;

		// events

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
		//  initialize component styles
		if (!AS3.as(this.styleDeclaration, Bool)) {
			this.styleDeclaration = new CSSStyleDeclaration(null, styleManager);
		}

		this.styleDeclaration.defaultFactory = function():Void {
					this.backgroundColor = 4473924;
					this.verticalGap = 0;
				};
		return factory;
	}

	//  initialize()
	/**
	 * @private
	 **/
	override public function initialize():Void {
		// mx_internal::setDocumentDescriptor(_documentDescriptor_);

		super.initialize();
	}

	//  scripts
	//  <Script>, line 29 - 138

	private var filterString:String = '';

	@:meta(Bindable())
	private var files:ArrayCollection;

	override public function setFocus():Void {
		super.setFocus();

		textInput.setFocus();
		textInput.selectRange(textInput.text.length, textInput.text.length);
		updateFilter();
	}

	public function setFileList(wrappers:ArrayCollection):Void {
		files = new ArrayCollection();
		for (fw in wrappers) {
			iterateTree(fw);
		}

		files.filterFunction = filterFunction;
	}

	private function iterateTree(fw:FileWrapper):Void {
		if (fw.children != null) {
			for (i in 0...fw.children.length) {
				iterateTree(fw.children[i]);
			}
		} else {
			files.addItem(fw);
		}
	}

	private function updateFilter():Void {
		filterString = Std.string(textInput.text.toLowerCase());
		files.refresh();

		list.selectedIndex = 0;
	}

	private function filterFunction(obj:Dynamic):Bool {
		return Reflect.field(obj, 'name').toLowerCase().indexOf(filterString) == 0;
	}

	private function handleItemDoubleClick(event:ListEvent):Void {
		var fw:FileWrapper = AS3.as(event.itemRenderer.data, FileWrapper);
		if (AS3.as(fw.file.fileBridge.isDirectory, Bool)) {
			return;
		}

		launch(fw.file);
	}

	// Give the list certain keyboard navigation commands
	private function handleTextKeydown(event:KeyboardEvent):Void {
		if (event.keyCode == AS3.int(Keyboard.DOWN) || event.keyCode == AS3.int(Keyboard.UP)) {
			list.dispatchEvent(event);
		} else if (event.keyCode == AS3.int(Keyboard.ENTER)) {
			// List seem to have an old selectedItem value sometimes, so we guard against that
			if (files.length == 0) {
				return;
			}

			var item:FileWrapper = AS3.as(list.selectedItem, FileWrapper);
			if (item != null) {
				launch(item.file);
			}
		}
	}

	// Open the selected item
	private function launch(file:FileLocation):Void {
		GlobalEventDispatcher.getInstance().dispatchEvent(
				new Event(ProjectPlugin.EVENT_SHOW_OPEN_RESOURCE, false, false)
		);

		GlobalEventDispatcher.getInstance().dispatchEvent(
				new OpenFileEvent(OpenFileEvent.OPEN_FILE, cast [file])
		);
	}

	private function getIconForFile(object:Dynamic):Class<Dynamic> {
		return null;
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _OpenResourceView_DropShadowFilter1_c():spark.filters.DropShadowFilter {
		var temp:spark.filters.DropShadowFilter = new spark.filters.DropShadowFilter();
		temp.alpha = 0.3;
		temp.blurX = 1;
		temp.blurY = 1;
		temp.distance = 1;
		temp.angle = 90;
		return temp;
	}

	/**
	 * @private
	 **/
	public function __textInput_creationComplete(event:mx.events.FlexEvent):Void {
		textInput.setFocus();
	}

	/**
	 * @private
	 **/
	public function __textInput_change(event:spark.events.TextOperationEvent):Void {
		updateFilter();
	}

	/**
	 * @private
	 **/
	public function __textInput_keyDown(event:flash.events.KeyboardEvent):Void {
		handleTextKeydown(event);
	}

	/**
	 * @private
	 **/
	public function __list_itemDoubleClick(event:mx.events.ListEvent):Void {
		handleItemDoubleClick(event);
	}

	//  binding mgmt
	private function _OpenResourceView_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Dynamic {
					return (files);
				},
				null,
				'list.dataProvider');

		result[1] = new mx.binding.Binding(this,
				function():mx.core.IFactory {
					return (new ClassFactory(ListItemRenderer));
				},
				null,
				'list.itemRenderer');

		result[2] = new mx.binding.Binding(this,
				function():Function {
					return (getIconForFile);
				},
				null,
				'list.iconFunction');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(OpenResourceView)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	//  end embed carrier vars

	//  binding management vars
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

//  end package def