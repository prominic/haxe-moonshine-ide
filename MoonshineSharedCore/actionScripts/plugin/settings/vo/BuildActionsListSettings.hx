package actionScripts.plugin.settings.vo;

import actionScripts.plugin.settings.renderers.BuildActionsSettingRenderer;
import mx.core.IVisualElement;

class BuildActionsListSettings extends StringSetting {

	private var rdr:BuildActionsSettingRenderer;

	private var _buildActions:Array<Dynamic>;

	public function new(provider:Dynamic, buildActions:Array<Dynamic>, name:String, label:String) {
		super(provider, name, label, null);

		_buildActions = buildActions;
	}

	public var buildActions(get, never):Array<Dynamic>;
	private function get_buildActions():Array<Dynamic> {
		return _buildActions;
	}

	override private function get_renderer():IVisualElement {
		rdr = new BuildActionsSettingRenderer();
		rdr.setting = this;
		rdr.enabled = isEditable;
		rdr.setMessage(message, messageType);
		return rdr;
	}

}