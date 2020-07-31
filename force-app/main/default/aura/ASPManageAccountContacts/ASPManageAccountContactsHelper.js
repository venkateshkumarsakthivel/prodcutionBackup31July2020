({
    editContact : function(component, event) {
        
        console.log("In editContact");
        
        var recId = event.currentTarget.getAttribute("data-recordId");    
        
        $A.createComponent(
            "c:EditExistingContact",
            {
                "recordId" : recId,
                "loggedInUserContactId" : component.get("v.loggedInUserContactId")
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                if (status === "SUCCESS") {
                    component.set("v.body", newComponent);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },
    deactivateContact : function(component, event, recordId) {
        
        console.log("In deactivateContact : " + recordId);
        
        var contactIdsToDeactivate = [];
        contactIdsToDeactivate.push(recordId);
        
        var action = component.get("c.deactivateContact");
        action.setParams({
            "idsToDeactivate" : contactIdsToDeactivate
        });
        
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            console.log(state);
            
            var retString = response.getReturnValue();
            console.log(retString);
            
            if(state == 'SUCCESS') {
                
                if(retString == '') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Contact removed successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    toastEvent.fire();
                } else if(retString == 'Only Primary Contact on Account') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Account needs to have at least one primary contact.",
                        "duration":10000,
                        "type":"error"
                    });
                    toastEvent.fire();
                    
                } else {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Contact remove request " + response.getReturnValue() + " submitted successfully.",
                        "duration":10000,
                        "type":"success"
                    });
                    toastEvent.fire();
                }
                console.log('refreshing view');
                //var refreshContactsEvent = component.getEvent('refreshContactEvent');  
                //refreshContactsEvent.fire();               
                //$A.get('e.force:refreshView').fire();
                var retrieveContactsAction = component.get('c.doInit'); 
                retrieveContactsAction.setParams({});
                $A.enqueueAction(retrieveContactsAction);
            }
            else if (state === "ERROR"){
                var errors = response.getError();
                console.log(errors);    
            }  
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    showSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event){
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
})