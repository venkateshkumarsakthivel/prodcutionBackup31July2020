({
	renderNextSection : function(component, event, closeForm, reviewSave){       
        this.showSpinner(component, event);                
        var _action = component.get("c.saveSectionData"); 
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
              
        _action.setParams({"jsonStr":JSON.stringify(internalDetailsWrp)});
        _action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedValue = response.getReturnValue();
                if(returnedValue.isSuccess && returnedValue.csObj.Id && returnedValue.csObj.Id.startsWith("500")){                   
                    component.set("v.reviewFormWrpObj", returnedValue); 
                    // show toast only when finish later is clicked
                    if(closeForm == true) {
                        var toastEvent = $A.get("e.force:showToast");           	
	                    toastEvent.setParams({
	                        "title": "Success",
	                        "message": "Application saved successfully.",
	                        "type": "success",
	                        "duration":10000,
	                        "mode": "dismissible" 
	                    });
	                    toastEvent.fire(); 
	                    var disableModal = component.getEvent("closeInternalReviewModal");
                        disableModal.fire();
                    }if(reviewSave) {
                    
	                    component.set("v.readOnly", true);
	                    component.set("v.reviewEdit", false);
	                }else{
	                     var _nextSectionEvent = component.getEvent("loadSection");
	                    _nextSectionEvent.setParams({
	                                                 "sectionNameToRender": "Review Details", 
	                                                 "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"), 
	                                                 "modalHeightInPercent":"height:90%"
	                                                });
	                    _nextSectionEvent.fire();
	                }                   
                }else{
                    // will be replaced with proper error handling
                    alert(returnedValue.message);
                }
            }else if(state ==="ERROR"){
                // will be replaced with proper error handling
                alert(response.getReturnValue());
            }
             
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(_action);
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
    	
	performBlankInputCheck : function(component, event) {
 
        this.resetErrorMessages(component, event);  
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");      
        var hasRequiredInputsMissing = false;
                
        //if(this.validateBlankRadioInputs(component, event, "privacyDeclaredError", internalDetailsWrp.csObj.Information_Declaration__c, $A.get("$Label.c.Privacy_Declaration_Error_Message")))
            //hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "privacyAcceptedError", internalDetailsWrp.csObj.Is_Privacy_Statement_Declared__c, $A.get("$Label.c.Privacy_Statement_Error_Message")))
            hasRequiredInputsMissing = true; 
                
        console.log(hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;    
    },
    
    validateBlankRadioInputs : function(component, event, inputId, inputValue, msg){

        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = msg;
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
    
    resetErrorMessages : function(component, event) {  
        //document.getElementById("privacyDeclaredError").innerHTML = '';
        document.getElementById("privacyAcceptedError").innerHTML = '';     
    }
})