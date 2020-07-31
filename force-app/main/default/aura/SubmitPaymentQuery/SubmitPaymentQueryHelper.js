({
    doInit : function(component, event) {
       
        // Get Case ID
        var sPageURL = decodeURIComponent(window.location.search.substring(1)),
            sURLVariables = sPageURL.split('&'),
            sParameterName, i,
            appIdProvided = false;
        
        for(i = 0; i < sURLVariables.length; i++) {
            
            sParameterName = sURLVariables[i].split('=');
            console.log(sParameterName);
            
            //identify existing application id from URL as appId=existing app Id
            if(sParameterName[0] === "appId" 
               && sParameterName[1] != "") {
                
                component.set("v.caseId", sParameterName[1]);
                appIdProvided = true;
            }
        }
        
        if(appIdProvided == false) {
            component.set("v.caseId", "");
        } 
        
        //if(component.get("v.submitPaymentWrpObj"))
            //return;
        
        console.log(component.get("v.caseId"));
        console.log(component.get("v.paymentRecordID"));
        
        var _action = component.get("c.initCaseRecord");
        _action.setParams({
            "paymentID":component.get("v.paymentRecordID"),
            "caseID": component.get("v.caseId"),
        });
        
        _action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS"){
                
                var _retVal = response.getReturnValue();
               
                if(_retVal.isSuccess) {
                    component.set("v.submitPaymentWrpObj", _retVal);
                    
                    console.log('Case Status ' + component.get("v.submitPaymentWrpObj.csObj.Status"));
                    if(component.get("v.submitPaymentWrpObj.csObj.Status") == 'Lodged') {
                        component.set("v.readOnly", true);
                    }
                } else {
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Error occurred "+_retVal.message,
                        "duration":10000,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error occurred "+_retVal,
                    "duration":10000,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(_action);
    },
    
    createCaseRecord : function(component, event) {
        
        var _action =  component.get("c.upsertCaseRecord");
        _action.setParams({"jsonStr":JSON.stringify(component.get("v.submitPaymentWrpObj"))});
        
        this.showSpinner(component, event);
        
        _action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var _retVal = response.getReturnValue();
                
                if(_retVal.isSuccess) {    
                    
                    component.set("v.submitPaymentWrpObj", _retVal); 
                    
                    var _nextSectionEvent = component.getEvent("loadSection");
                    _nextSectionEvent.setParams({
                        "sectionNameToRender": "Attachment",
                        "submitPaymentWrpObj": component.get("v.submitPaymentWrpObj"),
                        "readOnly": component.get("v.readOnly")
                    });
                    _nextSectionEvent.fire();  
                    
                } else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Error occurred "+_retVal.message,
                        "duration":10000,
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            } else {
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
    
	toggleSectionContent : function(component, event){
        console.log("toggle content");
        var toggleText = component.find("sectiontitle");
        var isSecExpanded = component.get("v.isSectionExpanded");
        console.log(isSecExpanded);
        if(!isSecExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    
    performBlankInputCheck : function(component, event) {
        component.find("case-Decision").set("v.errors", null);       
        var submitPaymentWrpObj = component.get("v.submitPaymentWrpObj");
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "case-Decision", submitPaymentWrpObj.csObj.Description))
            hasRequiredInputsMissing = true;    

        return hasRequiredInputsMissing;    
    },
    
    validateBlankInputs : function(component, event, inputId, inputValue) {
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
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