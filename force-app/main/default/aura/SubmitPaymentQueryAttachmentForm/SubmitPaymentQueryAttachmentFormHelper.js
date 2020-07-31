({
	submitQuery : function(component, event) {
		var _wrpObj = component.get("v.submitPaymentWrpObj");
		_wrpObj.csObj.Status = 'Lodged';
		this.showSpinner(component, event);
		var _action =  component.get("c.upsertCaseRecord");
        _action.setParams({"jsonStr":JSON.stringify(_wrpObj)});
        
        _action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var _retVal = response.getReturnValue();
                console.log(_retVal);
                component.getEvent("closeApplication").fire();
                if(_retVal.isSuccess){        
                    
                    var caseNumber = _retVal.caseNumber;
                    
                    var toastEvent = $A.get("e.force:showToast");           	
		            toastEvent.setParams({
		                "title": "Success",
		                "message": 'Payment query ' + caseNumber + ' successfully submitted.',
		                "duration":7000,
		                "type": "success"
		            });
		            toastEvent.fire();  
                    
                    window.setTimeout(function() { 
                        
                        window.location = "/industryportal/s/manage-profile?src=accountMenu";
                    }, 3000);
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");           	
		            toastEvent.setParams({
		                "title": "Error",
		                "message": "Error occurred "+_retVal.message,
		                "duration":10000,
		                "type": "error"
		            });
		            toastEvent.fire();
                }
            }else{
                 var toastEvent = $A.get("e.force:showToast");           	
	              toastEvent.setParams({
	                "title": "Error",
	                "message": "Error occurred "+_retVal,
	                "duration":10000,
	                "type": "error"
	              });
	              toastEvent.fire();
            }
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(_action);
	},
    
    confirmPrevSection : function(component, event){ 
        $A.createComponent(
            "c:ModalMessageConfirmBox",
            {
                "message": "Your changes on this page will be lost. Do you wish to proceed?",
                "confirmType": "Payment Query Previous"
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
    
    performBlankInputCheck : function(component, event){ 
        let that = this      
        var submitPaymentWrpObj = component.get("v.submitPaymentWrpObj");
        var hasRequiredInputsMissing = false;
        var documentUploadStatus = component.get("v.documentUploadStatus");
                
        if(submitPaymentWrpObj.csObj.Internal_Review_Supporting_Documents__c == true && submitPaymentWrpObj.caseAlreadyHasDocuments == false 
           && (documentUploadStatus == undefined || documentUploadStatus == false)){
            document.getElementById("documentsNotUploadedError").innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById("documentsNotUploadedError").style.display = 'block';
			hasRequiredInputsMissing = true;
        }
        return hasRequiredInputsMissing;    
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
    }
})