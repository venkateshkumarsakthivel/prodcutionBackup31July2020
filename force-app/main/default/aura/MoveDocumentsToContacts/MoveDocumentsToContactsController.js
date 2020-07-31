({
    doInit : function(component, event, helper) {
        //document.addEventListener('contextmenu', event => event.preventDefault());
        helper.checkCaseStatusHelper(component, event, helper);
    },
       
    confirmMoveDocuments : function(component, event, helper) {
    	
        var isContactSelected = false;
        var fcwList = component.get("v.files"); 
        for(var ctr=0; ctr<fcwList.length; ctr++) {
            var fcw = fcwList[ctr];
            console.log('status >>' + fcw.isAlreadyExistOnContacts);
            if(fcw.contactId != 'None') {
                isContactSelected = true;
            }
        }
        
         if(isContactSelected == true) {
             console.log('before calling modal');
             $A.createComponent(
                 "c:ModalMessageConfirmBox",
                 {
                     "message": "Are you sure you want to copy the documents?",
                     "confirmType": "CopyDocuments"
                 },
                 function(newComponent, status, errorMessage){
                     console.log(status);
                     if (status === "SUCCESS") {                    
                         component.set("v.body", newComponent);                    
                     }
                     else if (status === "INCOMPLETE") {
                         console.log("No response from server or client is offline.");
                         // Show offline error
                     } else if (status === "ERROR") {
                         console.log("Error: " + errorMessage);
                         // Show error message
                     }                
                 }
             );	
         } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": " Select atleast one Related Contact to copy attachment.",
                "type": "error"
                
            });
            toastEvent.fire();
        }
    },
    
    moveDocuments : function(component, event, helper) {
        
        //moving documents call needs to be moved
        var fcwList = component.get("v.files");
        console.log("fcwList: " + fcwList);
        
        var saveDocumentsAction = component.get("c.uploadDocumentsToContacts");
        saveDocumentsAction.setParams({
            "documentWrappersString": JSON.stringify(fcwList)
        });
        saveDocumentsAction.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            console.log("response: "+response.getReturnValue());
            
            if (state === "SUCCESS") {
                //set response value in wrapperList attribute on component.
                component.set('v.files', response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Documents have been copied successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
                $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                //helper.initialise(component, event, helper);
            }
        });
        $A.enqueueAction(saveDocumentsAction);
     },
    downloadDocument : function(component, event, helper) {
        
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        var fcwList = component.get("v.files");
        
        var locationURL = window.location;
        //created a base url
        var mainUrl = locationURL.protocol + '//' + locationURL.host;
        console.log('erl >> ' + mainUrl);
        for(var ctr=0; ctr<fcwList.length; ctr++) {
            var fcw = fcwList[ctr];
            if(fcw.fileId == id_str && fcw.isContentFile == true) {
               var urlI = "/sfc/servlet.shepherd/version/download/"+ id_str;
            }
            else if(fcw.fileId == id_str && fcw.isAttachment == true) {
                var urlI = "/servlet/servlet.FileDownload?file="+id_str;
            }
        }
       
        mainUrl += urlI;
        console.log('URL >>' + mainUrl);	
       window.open(mainUrl, '_blank');
    },
    closeMessageBox : function(component, event, helper) {
        
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 5 !important}");
        
        $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
		//helper.initialise(component, event, helper);
    },
    openMessageBox : function(component, event, helper) {
       
        //hack to change z-index of global header bar
        component.set("v.cssStyle", ".slds-global-header_container {z-index: 0 !important}");
        
        $A.util.addClass(component.find("messageBox"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"),  "slds-backdrop--open");
        helper.checkCaseStatusHelper(component, event, helper);
    }
	
})