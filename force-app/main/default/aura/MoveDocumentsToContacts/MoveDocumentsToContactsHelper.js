({
    
    checkCaseStatusHelper : function(component, event, helper) {
        
        var caseId = component.get("v.recordId");
        console.log("CaseData caseId :>>>> " + caseId);
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        var getContentDataAction = component.get("c.checkCaseStatus");
        getContentDataAction.setParams({
            "caseId": caseId
        });
        getContentDataAction.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            console.log("response: "+response.getReturnValue());
            if (state === "SUCCESS") {
                var retVal = JSON.parse(response.getReturnValue());
                console.log('Return Val');
                console.log(retVal);
                if(retVal.isCaseLodged == true && retVal.isAdditionalInfoAvailable == true) {
               		 this.initialise(component, event, helper);
                } else if(retVal.isAdditionalInfoAvailable == false){
                    console.log('Additional information details not available');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Additional Information details not available.",
                        "type": "error"
                    });
                    toastEvent.fire();
                    //hack to change z-index of global header bar
                    component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                    $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                    $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                }else if(retVal.isCaseLodged == false){
                    console.log('Case is not yet lodged');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Application is not yet Lodged.",
                        "type": "error"
                    });
                    toastEvent.fire();
                    
                    //hack to change z-index of global header bar
                    component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                    $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                    $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                 }
            }
        });
        $A.enqueueAction(getContentDataAction);
    },
    
	initialise : function(component, event, helper) {
       
        var caseId = component.get("v.recordId");
        console.log("CaseData caseId :>>>> " + caseId);
        
        var getContentDataAction = component.get("c.getAttachmentsWrapper");
        getContentDataAction.setParams({
            "caseId": caseId
        });
      	getContentDataAction.setCallback(this, function(response) {
        //store state of response
            var state = response.getState();
            console.log("response: "+response.getReturnValue());
			if (state === "SUCCESS") {
            	//set response value in wrapperList attribute on component.
            	component.set('v.files', response.getReturnValue());
                this.checkAttachmentStatus(component, event, helper);
            }
      	});
      	$A.enqueueAction(getContentDataAction);
		
	},
    
    checkAttachmentStatus : function(component, event, helper) {
        
        var fcwList = component.get("v.files"); 
       
        if(fcwList.length == 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "No documents exist on Application to copy.",
                "type": "error"
            });
            toastEvent.fire();
            //hack to change z-index of global header bar
            component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
            
            $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
            $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
        } else {
        
            var isAttachmentExistOnAllContacts = true;
            for(var ctr=0; ctr<fcwList.length; ctr++) {
                var fcw = fcwList[ctr];
                if(fcw.isAlreadyExistOnContacts == false) {
                    isAttachmentExistOnAllContacts = false;
                }
            }
            
            if(isAttachmentExistOnAllContacts == true) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " All Documents are already present on the Related Contacts.",
                    "type": "success"
                });
                toastEvent.fire();
                //hack to change z-index of global header bar
                component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                
                $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
             }
        }
    }
})