({
     submitRegistrationForm : function(component, event) {
        
        this.showSpinner(component, event);
        
        var registrationRecord = component.get('v.registrationRecord');
        
        console.log('In Submit Registration');
        console.log(registrationRecord);
        
        var action = component.get("c.submitRegistrationRecord");
        action.setParams({
            "registrationData": JSON.stringify(registrationRecord)
        });
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                
                registrationRecord = JSON.parse(response.getReturnValue());
                console.log('Registeration Record Returned: ' + registrationRecord);
                
                var toastEvent = $A.get("e.force:showToast");           	
                
                var confirmationMessage = '';
                if(component.get("v.isUpdateRegistration") == false)
                   confirmationMessage = "Application #"+registrationRecord["Name"]+" submitted successfully.";
                else
                   confirmationMessage = "Application #"+registrationRecord["Name"]+" updated successfully.";
                
                toastEvent.setParams({
                    "title": "Success",
                    "message": confirmationMessage,
                    "type": "success",
                    "duration": "10000"
                });
                toastEvent.fire();
                
                if(component.get("v.accountId") != "" && component.get("v.accountId") != undefined) {
                    
                    component.getEvent("closeApplication").fire();
                    $A.get('e.force:refreshView').fire();
                    /*
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": registrationRecord["Id"]
                    });
                    navEvt.fire();
                    */
                }
                else {
                    
                 var urlEvent = $A.get("e.force:navigateToURL");
                 urlEvent.setParams({
                    "url": "/levy-management?src=levyMenu"
                 });
                 urlEvent.fire();
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    showPopupModal : function(component, event) {
        
         var confirmationMessage = '';
                if(component.get("v.isConsoleUser") == true)
                   confirmationMessage = "please click on confirm to submit.";
                else
                   confirmationMessage = "You will not be able to edit the form once submitted. Click confirm to continue.";
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": confirmationMessage,
                "confirmType": "ASP Form Submission",
                "title":"Registration Submission"
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
    }
})