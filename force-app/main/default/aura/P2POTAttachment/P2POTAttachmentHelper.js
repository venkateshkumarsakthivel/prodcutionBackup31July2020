({
    
    MAX_FILE_SIZE: 750000,

    attach: function(component, event, file, contents, _section, _category, _type, _index) {
        var _action = component.get("c.upload");
        this.findPrefix(component, "DOCUMENT_ATTACHMENT_COMPONENT", _index).set("v.disabled", true);
        _action.setParams({
            parent: component.get("v.ParentRecordId"),
            /* append if required  + _index + "_"  */
            name: _section + "_" + _category + "_" + _type + "_" + file.name,
            contents: btoa(contents),
            ctype: file.type
        });
        
        _action.setCallback(this, function(_response) {
            var _success = _response.getReturnValue();
            component.set("v.upload", "unable to upload file : " + _section + "_" + _category + "_" + _type + "_" + file.name);
            component.set("v.severity", "error");
            if(_success == true)  {
                component.set("v.upload", _section + "_" + _category + "_" + _type + "_" + file.name + " : file uploaded successfully");
				component.set("v.severity", "success");
            }
            console.log("Response from OT receieved");
            this.findPrefix(component, "DOCUMENT_ATTACHMENT_COMPONENT", _index).set("v.disabled", false);
			$A.get("e.force:showToast").setParams({
			                       "title": "Attachment status",
			                       "message": component.get("v.upload"),
			                       "type": component.get("v.severity"),
			                       "mode": "pester"
			                   }).fire();
        });
        
	    $A.enqueueAction(_action);    
    },
    
    findPrefix: function(component, id, index) {
    		var prefixes = component.find(id);
    		var prefix = undefined
    		if(Array.isArray(prefixes))  {
    			prefix = prefixes[index];
    		} else {
    			prefix = prefixes;
    		}
    		
    		return prefix;
    },
    attachMessageListener : function(component, event, helper){
        console.log('attaching listener');
        var vfOrigin = $A.get("$Label.c.Attachment_VF_Url");
        window.addEventListener("message", function(event) {
            console.log('Msg listener invoked');
            if(event.origin !== vfOrigin){
                return;
            }
            console.log(event.data);
            var identifier = component.get("v.uniqueIdentifier");
            if(event.data.uniqueIdentifier == identifier){
                console.log(event.data.status + ' for ' + identifier);
                console.log(event.data.attachmentId + ' for ' + identifier);
                if(event.data.status == "success"){
                    component.set("v.uploadStatus", true);
                    component.set("v.attachId", event.data.attachmentId);
                    component.set("v.allowMoreAttachments", false);		
                    //check for max number of attachments.		
                    helper.checkIfMaxAttachmentLimitReached(component, event);
                } else {
                    //component.set("v.uploadStatus", false);
                }
                console.log("upload status " + component.get("v.uploadStatus"));
            }
        }, false);
    },
    getUserTypeDetails: function(component, event){
        // Get User Type
        var userTypeAction = component.get("c.getUserType");
        userTypeAction.setStorable();
        userTypeAction.setCallback(this,function(response) {    
            var state = response.getState();            
            if(state === "SUCCESS") {                
                var userType = response.getReturnValue();
                console.log('User Type: ' + userType);
                
                if(userType === "Standard")
                    component.set("v.isInternalUser", true);
            }
        });
        
        $A.enqueueAction(userTypeAction);
        
    },
    checkIfMaxAttachmentLimitReached : function(component, event){
        var maxAllowedAttachmentCount = component.get('v.maxNumberOfAttachments');
        console.log('maxAllowedAttachmentCount: ' + maxAllowedAttachmentCount);
        if(maxAllowedAttachmentCount <= 0){
            component.set("v.allowMoreAttachments", true);
            return;
        }
        var action = component.get("c.getMaxAttachmentCount");
        action.setParams({
            parentId: component.get("v.ParentRecordId")            
        });
        
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('current count of attachments: ' + result);
            if(result == maxAllowedAttachmentCount)  {
				component.set("v.allowMoreAttachments", false);
				$A.get("e.force:showToast").setParams({
			                       "title": "Max Allowed Attachment Limit",
			                       "message": "You have reached max allowed file attachments",
			                       "type": "warn",
			                       "mode": "pester"
			                   }).fire();
            }			
        });
        
	    $A.enqueueAction(action);
    }
})