({
    confirmPrevSection : function(component, event, helper){ 
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "ASP Form Previous"
            },
            function(newComponent, status, errorMessage) {
                console.log(status);
                //Add the new button to the body array
                if (status === "SUCCESS") {                        
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    
    renderPrevSection : function(component, event, helper) {
        var _nextSectionEvent = component.getEvent("loadSection");
        _nextSectionEvent.setParams({
            "sectionNameToRender": "Attachment", 
            "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"),
            "modalHeightInPercent":"height:90%"
        });
        _nextSectionEvent.fire();
    },
    
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    
    cancelReviewEdit : function(component, event, helper) {
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';        
        helper.resetErrorMessages(component, event);        
    },
    
    saveReviewChanges : function(component, event, helper) {
            
        if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, false, true);
        } 
    },
    
    saveFormState : function(component, event, helper){
        if(helper.performBlankInputCheck(component, event)) {
			console.log('123');            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
			console.log('456');            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, true, false);
        } 
    },
    
    renderNextSection : function(component, event, helper) {
        if(helper.performBlankInputCheck(component, event)) {            
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
            return;
        }else {           
            document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'none';
            helper.renderNextSection(component, event, false, false);
        }       
    }
})