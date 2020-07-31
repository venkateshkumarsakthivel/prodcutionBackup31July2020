({

    initialize : function (component, event, helper) {
        var _typeOptionsCategorywise = {};
        _typeOptionsCategorywise["POI"] = [
            {class: "optionClass", label: "Passport", value: "PASSPORT", selected: "true"}
        ];
        _typeOptionsCategorywise["CCI"] = [
            {class: "optionClass", label: "Driving License", value: "DRIVING_LICENSE", selected: "true"}
        ];
        component.set("v.typeOptionsCategorywise", _typeOptionsCategorywise);
        /* populate Category list */
        var _input = helper.findPrefix(component, "NAME_PREFIX_CATEGORY", component.get("v.index"));
        var cOptions = [
            {class: "optionClass", label: "POI", value: "POI", selected: "true"}, {class: "optionClass", label: "CCI", value: "CCI"}
        ];
        _input.set("v.options", cOptions);
        
        /* populate type list */
        _input = helper.findPrefix(component, "NAME_PREFIX_TYPE", component.get("v.index"));
        _input.set("v.options", _typeOptionsCategorywise["POI"]);
        
        helper.attachMessageListener(component, event, helper);
        
        if(component.get("v.bypassUserTypeCheck") == false)
         helper.getUserTypeDetails(component, event);
        
        helper.checkIfMaxAttachmentLimitReached(component, event);
    },
    
    populateTypeOptions: function(component, event, helper)  {
        var _typeOptionsCategorywise = component.get("v.typeOptionsCategorywise");
        var _input = helper.findPrefix(component, "NAME_PREFIX_CATEGORY", component.get("v.index"));
        var _category = _input.get("v.value");
        /* populate type list */
        _input = helper.findPrefix(component, "NAME_PREFIX_TYPE", component.get("v.index"));
        _input.set("v.options", _typeOptionsCategorywise[_category]);
        
    },
    attach : function(component, event, helper) {
        var _files = event.target.files;
        var _file = _files[0];
        console.log("P2POTAttachment.controller.attach method ::");

        /* validate if selected file validates against file size restrictions. */
        if(helper.MAX_FILE_SIZE < _file.size)  {
        		console.log("validate success, file size is greater than allowed file size");
        		return;
        }

        /* if file pass through file size restrictions proceed to upload as attachment. */
        var _fileReader = new FileReader();
        var _self = this;

        _fileReader.onload = function() {
        		var _contents = _fileReader.result;
        		var _input = undefined;
            	console.log('_fileReader.onload before helper.attach');
            	
            	_input = helper.findPrefix(component, "NAME_PREFIX_SECTION", component.get("v.index"));
            	var _section = _input.get("v.value");

        		_input = helper.findPrefix(component, "NAME_PREFIX_CATEGORY", component.get("v.index"));
            	var _category = _input.get("v.value");
            	
        		_input = helper.findPrefix(component, "NAME_PREFIX_TYPE", component.get("v.index"));
            	var _type = _input.get("v.value");
            	
        		var _action = helper.attach(component, event, _file, _contents, _section, _category, _type, component.get("v.index"));
        };
        
    		_fileReader.readAsBinaryString(_file);
    },
    displayUploadCheckError : function(component, event, helper) {
        
        document.getElementById(component.get("v.FileCheckLabel")+component.get("v.UniqueClass")+'Error').innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
        document.getElementById(component.get("v.FileCheckLabel")+component.get("v.UniqueClass")+'Error').style.display = 'block';    
    },
    resetUploadCheckError : function(component, event, helper) {
        
        document.getElementById(component.get("v.FileCheckLabel")+component.get("v.UniqueClass")+'Error').innerHTML = '';
        document.getElementById(component.get("v.FileCheckLabel")+component.get("v.UniqueClass")+'Error').style.display = 'none';
    },
})