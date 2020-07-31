({
    loadSectionData : function(component, event) {
        
        var caseId = component.get("v.caseId");
        
        var action = component.get("c.getASPAuthRenewalCaseData");
        action.setParams({
            "caseId": caseId
        });
        
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var caseData = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log(caseData);
                
                component.set("v.isPrivacyStatementAccepted", caseData["Is_Privacy_Statement_Declared__c"]);
            	
                var status = caseData["Status"];
                if(status == 'Lodged') {
                    component.set("v.readOnly", true);
                    component.set("v.withdrawnCase", true);
                }
            }
            else{
                console.log('Error !');
            }
        });
        
        if(caseId != "")
            $A.enqueueAction(action);
        
        this.showSpinner(component, event); 
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        var caseId = component.get("v.caseId");
        var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
        var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
        var isPrivacyStatementAccepted = component.get("v.isPrivacyStatementAccepted");
		
        var serviceType = '';
        if(isTSPAuthSelected && isBSPAuthSelected) {
            serviceType = 'Taxi and Booking';
        } else if (isTSPAuthSelected && !isBSPAuthSelected) {
            serviceType = 'Taxi';
        } else if (!isTSPAuthSelected && isBSPAuthSelected) {
            serviceType = 'Booking';
        }
        
        var caseData = {};
        caseData["Id"] = caseId;
        caseData["Is_TSP_Auth_Renewal_Request__c"] = isTSPAuthSelected;
        caseData["Is_BSP_Auth_Renewal_Request__c"] = isBSPAuthSelected;
        caseData["Service_Type__c"] = serviceType;
        caseData["Is_Privacy_Statement_Declared__c"] = isPrivacyStatementAccepted;
        
        var updateStatusToLodged = true;
        if(finishLater) {
            updateStatusToLodged = false;
        }
        var action = component.get("c.updateASPAuthRenewalCase");
        action.setParams({
            "caseData": JSON.stringify(caseData),
            "updateStatusToLodged": updateStatusToLodged
        });
        
        action.setCallback(this,function(response){
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                if(finishLater == false && reviewSave == false) {
                    
                    var caseId = component.get("v.caseId");
                    var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
                    var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
                    
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionD", "caseId" : caseId, "isTSPAuthSelected" : isTSPAuthSelected, "isBSPAuthSelected" : isBSPAuthSelected});
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                }
                
                if(finishLater) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Application saved successfully.",
                        "type": "success",
                        "duration":10000,
                        "mode": "sticky" 
                    });
                    toastEvent.fire();
                    
                    /*if(component.get("v.accountId") != undefined && component.get("v.accountId") != "") {
                    
                    component.getEvent("closeApplication").fire();
                	} else {*/
                    
                        window.setTimeout(function() { 
                            
                            window.location = "/industryportal/s/manage-profile?src=accountMenu";
                        }, 3000);
                    //}
                }
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(component, event); 
    },
    performBlankInputCheck : function(component, event){
        
        var hasRequiredInputsMissing = false;
        
        this.resetErrorMessages(component, event);
        
        if(this.validateBlankRadioInputs(component, event, "privacyDeclaredError", "isPrivacyStatementAccepted", $A.get("$Label.c.Privacy_Declaration_Error_Message")))
            hasRequiredInputsMissing = true;
        
        //$Label.c.Privacy_Statement_Error_Message
        
        return hasRequiredInputsMissing;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
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
        
        document.getElementById("privacyDeclaredError").innerHTML = '';
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