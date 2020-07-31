({
	list : function(component, event, _parent) {
		var attachments;
		var _action = component.get("c.browse");
        _action.setParams({
            parent: _parent
        });
        
        /* capture list of attachments from apex call. */
        _action.setCallback(this, function(_response) {
        		if(component.isValid() && _response.getState() === "SUCCESS")  {
        			attachments = JSON.parse(_response.getReturnValue());
                    console.log('Attachments retrieved');
                    console.log(attachments);
        			component.set("v.attachments", attachments);
                } else {
                    console.log('Failed to retrieve attachments');
                }
        });
        
        /* execute rest call to P2POTAttachmentController.browse */
        $A.enqueueAction(_action);
	},  
    
    checkCaseStatus : function(component, event, parentId){
		var action = component.get("c.isCaseLodged");
        action.setParams({
            caseId: parentId
        });
        
        /* capture list of attachments from apex call. */
        action.setCallback(this, function(_response) {
            console.log('Case Status Response');
            console.log(_response.getReturnValue());
            if(_response.getState() === "SUCCESS")  {
                component.set("v.caseLodged", _response.getReturnValue());
            } else {
                console.log('Failed to verify case status');
            }
        });
        
        /* execute rest call to P2POTAttachmentController.browse */
        $A.enqueueAction(action);
    },
    
    deleteAttachmentHelper : function(component, event, attachmentId) {
		console.log('Attachment Id >>>>' + attachmentId);
        var action = component.get("c.deleteAttachments");
        console.log('Attachment Id >>>>' + attachmentId);
        action.setParams({
            "attachmentId": attachmentId
        });
        
        /* Delete attchment from apex call. */
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if(state === "SUCCESS") {
                console.log('successss....');
                this.list(component, event, component.get("v.parent"));
            } else{
                console.log('Failed to delete attachment');
            }
        });
        
        /* execute rest call to P2POTAttachmentController.browse */
        $A.enqueueAction(action);
	},
})