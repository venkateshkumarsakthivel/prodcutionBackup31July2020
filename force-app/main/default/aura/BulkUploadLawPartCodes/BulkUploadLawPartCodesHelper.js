({
    showToast : function(component, event, message, title, msgType) {
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "duration":10000,
            "type": msgType
        });
        toastEvent.fire();
    }, 
    callServerSideAction : function(component, event, fileContent, headRow){
        
        event.getSource().set("v.disabled",true);
        var action = component.get("c.addLawPartCodesFromCSV");
        
        action.setParams({
            "fileContent" : fileContent,
            "headerRow" : headRow
        });
        
        action.setCallback(this, function(response){
            
            console.log('Inside setCallback');
            
            var status = response.getState();
            
            this.hideSpinner(component,event);
            
            console.log(status);
            
            if(status === 'SUCCESS'){
                
                console.log(response.getReturnValue());
                var uploadResult = response.getReturnValue();
                
                component.set("v.hideFileUploadInput", true);
                
                if(uploadResult != null) {
                    
                    //var message = uploadResult[0]+' records inserted successfully. '+uploadResult[1]+' records failed to upload as - Code was duplicate or Section data was missing.';
                    
                    /*this.showToast(component, 
                                   event, 
                                   message, 
                                   'Upload Completed', 
                                   $A.get("$Label.c.SUCCESS_MESSAGE_TOAST"));*/
                    
                    component.set("v.approveSuccessMessage", uploadResult);
                    document.querySelector("#generalSuccessMsgDiv").style.display = 'none';
                    document.querySelector("#generalSuccessMsgDiv").style.display = 'block';
                    document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#generalSuccessMsgDiv").scrollIntoView();
                }
                else {
                    
                    console.log('Invalid User Error from server');
                    /*var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You do not have permission to upload any Law Part Codes",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();*/
                    component.set("v.approveErrorMessage", 'You do not have permission to upload any Law Part Codes');
                    document.querySelector("#generalErrorMsgDiv").style.display = 'none';
                    document.querySelector("#generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#generalErrorMsgDiv").scrollIntoView();
                }
                
                //this.redirectToLPCHome(component, event);
            }
        });
        $A.enqueueAction(action);    
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
    redirectToLPCHome : function(component, event){
        
        $A.get("e.force:closeQuickAction").fire();
        var homeEvt = $A.get("e.force:navigateToObjectHome");
        homeEvt.setParams({
            "scope": "Law_Part_Code__c"
        });
        homeEvt.fire();

    }    
})