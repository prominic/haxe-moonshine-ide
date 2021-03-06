/**
 *  Generated by mxmlc 4.0
 *
 *  Package:    components.popup.newFile
 *  Class:      NewFilePopup
 *  Source:     /Users/axgord/dev/Moonshine-IDE/ide/MoonshineSharedCore/src/components/popup/newFile/NewFilePopup.mxml
 *  Template:   flex2/compiler/mxml/gen/ClassDef.vm
 *  Time:       2019.04.22 23:25:47 MSK
 */

package components.popup.newFile;

import actionScripts.factory.FileLocation;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.managers.PopUpManager;
import spark.events.TextOperationEvent;
import actionScripts.events.DuplicateEvent;
import actionScripts.events.GlobalEventDispatcher;
import actionScripts.events.NewFileEvent;
import actionScripts.extResources.com.validator.ValidatorType;

import actionScripts.ui.menu.MenuPlugin;
import actionScripts.utils.SimpleValidator;
import actionScripts.utils.UtilsCore;
import actionScripts.valueObjects.ConstantsCoreVO;
import actionScripts.valueObjects.FileWrapper;

import actionScripts.plugin.findreplace.view.PromptTextInput;
import actionScripts.ui.renderers.FTETreeItemRenderer;
import actionScripts.utils.CustomTreeFolders;
import components.popup.newFile.NewFileBase;
import flash.accessibility.*;
import flash.debugger.*;
import flash.display.*;
import flash.errors.*;
import flash.events.*;
import flash.events.MouseEvent;
import flash.external.*;
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
import spark.components.Button;
import spark.components.Group;
import spark.components.HGroup;
import spark.components.Image;
import spark.components.Label;
import spark.components.VGroup;

@:meta(Event(name = 'EVENT_NEW_FILE', type = 'actionScripts.events.NewFileEvent'))
//  begin class def
class NewFilePopup extends components.popup.newFile.NewFileBase implements mx.binding.IBindingClient {

	//  instance variables
	/**
	 * @private
	 **/
	public var _NewFilePopup_Label4:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var btnCreate:spark.components.Button;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var hgExistingWarning:spark.components.HGroup;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lblExtension:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var lblName:spark.components.Label;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var tree:actionScripts.utils.CustomTreeFolders;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtDestination:actionScripts.plugin.findreplace.view.PromptTextInput;

	@:meta(Bindable())
	/**
	 * @private
	 **/
	public var txtFileName:actionScripts.plugin.findreplace.view.PromptTextInput;

	//  type-import dummies

	//  constructor (Flex display object)
	/**
	 * @private
	 **/
	public function new() {
		super();

		// mx_internal::_document = this;

		var bindings:Array<Dynamic> = _NewFilePopup_bindingsSetup();
		var watchers:Array<Dynamic> = [];

		var target:Dynamic = this;

		if (_watcherSetupUtil == null) {
			var watcherSetupUtilClass:Dynamic = Type.resolveClass('_components_popup_newFile_NewFilePopupWatcherSetupUtil');
			Reflect.field(watcherSetupUtilClass, 'init')(null);
		}

		_watcherSetupUtil.setup(this,
				function(propertyName:String):Dynamic {
					return Reflect.field(target, propertyName);
				},
				function(propertyName:String):Dynamic {
					return Reflect.getProperty(NewFilePopup, propertyName);
				},
				bindings,
				watchers
		);

		// mx_internal::_bindings =  //  mx_internal::_bindings.concat(bindings);
		// mx_internal::_watchers =  //  mx_internal::_watchers.concat(watchers);

		// layer initializers

		// properties
		this.controlBarContent = [_NewFilePopup_Button1_i()];
		this.mxmlContentFactory = new mx.core.DeferredInstanceFromFunction(_NewFilePopup_Array2_c);

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

		return factory;
	}

	//  initialize()
	/**
	 * @private
	 **/
	override public function initialize():Void {
		super.initialize();
	}

	//  scripts
	//  <Script>, line 31 - 235

	public static var AS_PLAIN_TEXT:String = 'AS_PLAIN_TEXT';
	public static var AS_XML:String = 'AS_XML';
	public static var AS_CUSTOM:String = 'AS_CUSTOM';
	public static var AS_DUPLICATE_FILE:String = 'AS_DUPLICATE_FILE';

	public var openType:String;
	public var fileTemplate:FileLocation;
	public var folderFileLocation:FileLocation;

	override private function onBrowseButton(event:MouseEvent):Void {
		super.onBrowseButton(event);

		if (projectSelectionWindow == null) {
			projectSelectionWindow.wrapperProject = UtilsCore.getProjectFromProjectFolder(AS3.as(tree.selectedItem, FileWrapper));
			PopUpManager.centerPopUp(projectSelectionWindow);
		}
	}

	override private function onProjectSelectionChanged(event:NewFileEvent):Void {
		super.onProjectSelectionChanged(event);

		txtDestination.text = wrapperBelongToProject.projectName;

		var timeoutValue:Int = as3hx.Compat.setTimeout(function():Void {
					parseFolders();
					as3hx.Compat.clearTimeout(timeoutValue);
				}, 100);
	}

	private function onCreateButton(event:MouseEvent):Void {
		// validation check for Enter key
		if (!AS3.as(btnCreate.enabled, Bool)) {
			return;
		}

		// validation 2
		var validateArr:Array<Dynamic> = new Array<Dynamic>();
		if (SimpleValidator.validate(validateArr)) {
			if (openType == AS_XML) {
				fileTemplate = ConstantsCoreVO.TEMPLATE_XML;
			} else if (openType == AS_PLAIN_TEXT) {
				fileTemplate = ConstantsCoreVO.TEMPLATE_TEXT;
			}

			if (openType == AS_DUPLICATE_FILE) {
				var tmpDuplicateEvent:DuplicateEvent = new DuplicateEvent(DuplicateEvent.EVENT_APPLY_DUPLICATE, wrapperOfFolderLocation, folderFileLocation);
				tmpDuplicateEvent.fileName = txtFileName.text;
				dispatchEvent(tmpDuplicateEvent);
			} else {
				var tmpEvent:NewFileEvent = new NewFileEvent(NewFileEvent.EVENT_NEW_FILE, null, fileTemplate, wrapperOfFolderLocation);
				tmpEvent.fileName = txtFileName.text;
				dispatchEvent(tmpEvent);
			}

			doBeforeExit();
			super.closeThis();
		}
	}

	private function parseFolders():Void {
		tree.expandItem(wrapperBelongToProject.projectFolder, true);

		// 1. expand all items to our fileWrapper object
		// 2. select the fileWrapper object
		// 3. scroll to the fileWrapper object
		UtilsCore.wrappersFoundThroughFindingAWrapper = cast new Array<FileWrapper>();
		UtilsCore.findFileWrapperInDepth(wrapperOfFolderLocation, wrapperOfFolderLocation.nativePath, wrapperBelongToProject);
		tree.callLater(function():Void {
					var wrappers:Array<FileWrapper> = cast UtilsCore.wrappersFoundThroughFindingAWrapper;
					for (j in 0...(wrappers.length - 1)) {
						tree.expandItem(wrappers[j], true);
					}

					// selection
					tree.selectedItem = wrapperOfFolderLocation;
					// scroll-to
					tree.callLater(function():Void {
								tree.scrollToIndex(tree.getItemIndex(wrapperOfFolderLocation));
							});
				});
	}

	private function onNameChanged(event:TextOperationEvent):Void {
		// @note
		// for some reason PromptTextInput.text is not binding properly
		// to other Flex UI component, i.e. Label
		// it shows only the origianl set text to PromptTextInput.text if
		// binded to a label component, thus:
		modifiedName = txtFileName.text;

		if (txtFileName.text == '') {
			btnCreate.enabled = false;
		} else {
			var targetFile:FileLocation = wrapperOfFolderLocation.file.fileBridge.resolvePath(txtFileName.text + lblExtension.text);
			targetFile.fileBridge.canonicalize();

			btnCreate.enabled = !targetFile.fileBridge.exists;
			if (!AS3.as(btnCreate.enabled, Bool)) {
				warningMessage = modifiedName + lblExtension.text + ' is already exists.';
			}
		}
	}

	private function onTreeItemClicked(event:ListEvent):Void {
		txtDestination.text = UtilsCore.getPackageReferenceByProjectPath(
						[new FileLocation(Std.string(tree.selectedItem.projectReference.path))],
						Std.string(tree.selectedItem.nativePath)
			);

		// re-validate upon folder location change
		wrapperOfFolderLocation = AS3.as(tree.selectedItem, FileWrapper);
		isDestinationValid = UtilsCore.validatePathAgainstSourceFolder(wrapperBelongToProject, wrapperOfFolderLocation);
		onNameChanged(new TextOperationEvent(TextOperationEvent.CHANGE));
	}

	override private function onNewFileCreationComplete(event:FlexEvent):Void {
		super.onNewFileCreationComplete(event);

		minHeight = height;
		if (openType == AS_DUPLICATE_FILE) {
			var extension:String = Std.string(folderFileLocation.fileBridge.extension.toLowerCase());
			title = 'Duplicate File';
			lblExtension.text = '.' + extension;
			lblName.text = 'New File Name:';

			if (extension == 'as' || extension == 'mxml') {
				txtFileName.restrict = '0-9A-Za-z_.';
			}

			var nameOnly:Array<Dynamic> = folderFileLocation.fileBridge.name.split('.');
			nameOnly.pop();
			txtFileName.prompt = nameOnly.join('.');
		} else if (openType == AS_XML) {
			title = 'New XML File';
			lblExtension.text = '.xml';
		} else {
			title = 'New File';
			if (fileTemplate == null) {
				lblExtension.text = '.txt';
			} else {
				var tmpArr:Array<Dynamic> = fileTemplate.fileBridge.name.split('.');
				if (tmpArr.length >= 3) {
					lblExtension.text = '.' + tmpArr[tmpArr.length - 2];
				}
			}
		}

		if (wrapperBelongToProject != null) {
			txtDestination.text = UtilsCore.getPackageReferenceByProjectPath(
							[new FileLocation(wrapperBelongToProject.folderPath)],
							wrapperOfFolderLocation.nativePath
				);
			txtFileName.setFocus();
		}

		tree.callLater(parseFolders);
		GlobalEventDispatcher.getInstance().dispatchEvent(new Event(MenuPlugin.CHANGE_MENU_MAC_DISABLE_STATE));
	}

	//  end scripts

	//  supporting function definitions for properties, events, styles, effects
	private function _NewFilePopup_Button1_i():spark.components.Button {
		var temp:spark.components.Button = new spark.components.Button();
		temp.label = 'Create';
		temp.styleName = 'darkButton';
		temp.enabled = false;
		temp.addEventListener('click', __btnCreate_click);
		temp.id = 'btnCreate';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		btnCreate = temp;
		mx.binding.BindingManager.executeBindings(this, 'btnCreate', btnCreate);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __btnCreate_click(event:flash.events.MouseEvent):Void {
		onCreateButton(event);
	}

	private function _NewFilePopup_Array2_c():Array<Dynamic> {
		var temp:Array<VGroup> = [_NewFilePopup_VGroup1_c(), _NewFilePopup_VGroup2_c()];
		return cast temp;
	}

	private function _NewFilePopup_VGroup1_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_NewFilePopup_Label1_c(), _NewFilePopup_PromptTextInput1_i(), _NewFilePopup_CustomTreeFolders1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewFilePopup_Label1_c():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Source Folder:';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewFilePopup_PromptTextInput1_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.prompt = 'Select Destination';
		temp.editable = false;
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.id = 'txtDestination';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtDestination = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtDestination', txtDestination);
		return temp;
	}

	private function _NewFilePopup_CustomTreeFolders1_i():actionScripts.utils.CustomTreeFolders {
		var temp:actionScripts.utils.CustomTreeFolders = new actionScripts.utils.CustomTreeFolders();
		temp.percentWidth = 100.0;
		temp.percentHeight = 100.0;
		temp.rowHeight = 18;
		temp.doubleClickEnabled = true;
		temp.labelField = 'name';
		temp.itemRenderer = _NewFilePopup_ClassFactory1_c();
		temp.setStyle('color', 15658734);
		temp.setStyle('contentBackgroundColor', 0);
		temp.setStyle('rollOverColor', 3750201);
		temp.setStyle('selectionColor', 12674488);
		temp.setStyle('alternatingItemColors', [4473924, 5065804]);
		temp.setStyle('verticalScrollBarStyleName', 'black');
		temp.setStyle('borderVisible', false);
		temp.setStyle('useRollOver', true);
		temp.addEventListener('itemClick', __tree_itemClick);
		temp.id = 'tree';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		tree = temp;
		mx.binding.BindingManager.executeBindings(this, 'tree', tree);
		return temp;
	}

	private function _NewFilePopup_ClassFactory1_c():mx.core.ClassFactory {
		var temp:mx.core.ClassFactory = new mx.core.ClassFactory();
		temp.generator = actionScripts.ui.renderers.FTETreeItemRenderer;
		return temp;
	}

	/**
	 * @private
	 **/
	public function __tree_itemClick(event:mx.events.ListEvent):Void {
		onTreeItemClicked(event);
	}

	private function _NewFilePopup_VGroup2_c():spark.components.VGroup {
		var temp:spark.components.VGroup = new spark.components.VGroup();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_NewFilePopup_Label2_i(), _NewFilePopup_Group1_c(), _NewFilePopup_HGroup1_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewFilePopup_Label2_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.text = 'Name:';
		temp.id = 'lblName';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lblName = temp;
		mx.binding.BindingManager.executeBindings(this, 'lblName', lblName);
		return temp;
	}

	private function _NewFilePopup_Group1_c():spark.components.Group {
		var temp:spark.components.Group = new spark.components.Group();
		temp.percentWidth = 100.0;
		temp.mxmlContent = [_NewFilePopup_PromptTextInput2_i(), _NewFilePopup_Label3_i()];
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewFilePopup_PromptTextInput2_i():actionScripts.plugin.findreplace.view.PromptTextInput {
		var temp:actionScripts.plugin.findreplace.view.PromptTextInput = new actionScripts.plugin.findreplace.view.PromptTextInput();
		temp.prompt = 'Name';
		temp.percentWidth = 100.0;
		temp.styleName = 'textInput';
		temp.restrict = '0-9A-Za-z._\\-';
		temp.marginRight = 50;
		temp.addEventListener('change', __txtFileName_change);
		temp.addEventListener('enter', __txtFileName_enter);
		temp.id = 'txtFileName';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		txtFileName = temp;
		mx.binding.BindingManager.executeBindings(this, 'txtFileName', txtFileName);
		return temp;
	}

	/**
	 * @private
	 **/
	public function __txtFileName_change(event:spark.events.TextOperationEvent):Void {
		onNameChanged(event);
	}

	/**
	 * @private
	 **/
	public function __txtFileName_enter(event:mx.events.FlexEvent):Void {
		onCreateButton(null);
	}

	private function _NewFilePopup_Label3_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.styleName = 'textInputLabel';
		temp.right = 6;
		temp.verticalCenter = 0;
		temp.setStyle('textAlign', 'right');
		temp.id = 'lblExtension';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		lblExtension = temp;
		mx.binding.BindingManager.executeBindings(this, 'lblExtension', lblExtension);
		return temp;
	}

	private function _NewFilePopup_HGroup1_i():spark.components.HGroup {
		var temp:spark.components.HGroup = new spark.components.HGroup();
		temp.percentWidth = 100.0;
		temp.verticalAlign = 'middle';
		temp.mxmlContent = [_NewFilePopup_Image1_c(), _NewFilePopup_Label4_i()];
		temp.id = 'hgExistingWarning';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		hgExistingWarning = temp;
		mx.binding.BindingManager.executeBindings(this, 'hgExistingWarning', hgExistingWarning);
		return temp;
	}

	private function _NewFilePopup_Image1_c():spark.components.Image {
		var temp:spark.components.Image = new spark.components.Image();
		temp.source = _embed_mxml__elements_images_iconExclamationRed_png_1685577265;
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		return temp;
	}

	private function _NewFilePopup_Label4_i():spark.components.Label {
		var temp:spark.components.Label = new spark.components.Label();
		temp.percentWidth = 100.0;
		temp.id = '_NewFilePopup_Label4';
		if (!AS3.as(temp.document, Bool)) {
			temp.document = this;
		}
		_NewFilePopup_Label4 = temp;
		mx.binding.BindingManager.executeBindings(this, '_NewFilePopup_Label4', _NewFilePopup_Label4);
		return temp;
	}

	//  binding mgmt
	private function _NewFilePopup_bindingsSetup():Array<Dynamic> {
		var result:Array<Dynamic> = [];

		result[0] = new mx.binding.Binding(this,
				function():Dynamic {
					return (model.selectedprojectFolders);
				},
				null,
				'tree.dataProvider');

		result[1] = new mx.binding.Binding(this,
				function():Bool {
					return (!AS3.as(btnCreate.enabled, Bool) && modifiedName != '');
				},
				null,
				'hgExistingWarning.visible');

		result[2] = new mx.binding.Binding(this,
				function():String {
					var result:Dynamic = (warningMessage);
					return Std.string((result == null) ? null : Std.string(result));
				},
				null,
				'_NewFilePopup_Label4.text');

		return result;
	}

	/**
	 * @private
	 **/
	public static var watcherSetupUtil(never, set):IWatcherSetupUtil2;
	private static function set_watcherSetupUtil(watcherSetupUtil:IWatcherSetupUtil2):IWatcherSetupUtil2 {
		(NewFilePopup)._watcherSetupUtil = watcherSetupUtil;
		return watcherSetupUtil;
	}

	private static var _watcherSetupUtil:IWatcherSetupUtil2;

	//  embed carrier vars
	@:meta(Embed(source = '/elements/images/iconExclamationRed.png'))
	private var _embed_mxml__elements_images_iconExclamationRed_png_1685577265:Class<Dynamic>;

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