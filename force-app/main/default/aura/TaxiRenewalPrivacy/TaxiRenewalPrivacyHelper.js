({
	loadSectionData : function(component, event) {
		var action = component.get("c.retrieveApplicationDetails");
        var caseId = component.get("v.caseId");
        console.log('Retrieving application details for ' + caseId);
        action.setParams({"caseId": caseId});
        action.setCallback(this,function(response) {            
            var state = response.getState();
            console.log('Action State ' + state);
            if(state === "SUCCESS") {                
                var application = response.getReturnValue();                
                console.log(application);
                if(application.Status == 'Lodged'){
                    console.log('Form needs to be rendered in read only mode');
                    component.set("v.readOnly", true);
                }
                component.set("v.isInformationDeclared", application.Information_Declaration__c);
				component.set("v.isPrivacyStatementAccepted", application.Is_Privacy_Statement_Declared__c);                
            } else {                
                console.log('Failed to load section data.');
                component.set("v.displayNextSection", false);
            }
        });
        $A.enqueueAction(action);        
	},
    savePrivacyStatement : function(component, event) {
		this.showSpinner(component, event);
        
        var sectionData = {};
        sectionData.sobjectType = "Case";
		sectionData.Id = component.get('v.caseId');
		sectionData.Is_Privacy_Statement_Declared__c = component.get('v.isPrivacyStatementAccepted');
        sectionData.Information_Declaration__c = component.get('v.isInformationDeclared');
       
        var action = component.get("c.saveApplication");
		action.setParams({
			"application": sectionData
		});

		action.setCallback(this,function(response){
			var state = response.getState();
			this.hideSpinner(component, event); 
            if(state === "SUCCESS"){
                console.log('Application saved successfully.');
				var nextSectionEvent = component.getEvent("loadSection");
                nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get('v.caseId'), "entityType" : component.get("v.entityType")});
                nextSectionEvent.fire();
			} else {
                console.log('Failed to save application details');
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "The record has been updated successfully.",
                    "type":"error",
                    "duration": "10000"
                });
                toastEvent.fire();
			}
		});

		$A.enqueueAction(action);
	},
    performBlankInputCheck : function(component, event){
        var hasRequiredInputsMissing = false;
        this.resetErrorMessages(component, event);
        
        if(this.validatePrivacyChecks(component, event, "privacyDeclaredError", "isInformationDeclared", $A.get("$Label.c.Privacy_Declaration_Error_Message")))
			hasRequiredInputsMissing = true;        
		if(this.validatePrivacyChecks(component, event, "privacyAcceptedError", "isPrivacyStatementAccepted", $A.get("$Label.c.Privacy_Statement_Error_Message")))
			hasRequiredInputsMissing = true;
        
		return hasRequiredInputsMissing;
    },
    
    validatePrivacyChecks : function(component, event, inputId, attributeName, msg){
		var inputValue = component.get('v.'+attributeName);
		if(inputValue == undefined || inputValue == false){
			document.getElementById(inputId).innerHTML = msg;
			document.getElementById(inputId).style.display = 'block';
			return true;
		} else if(inputValue == true){
			document.getElementById(inputId).innerHTML = '';
			document.getElementById(inputId).style.display = 'none';
		}
		return false;
	},
    
    resetErrorMessages : function(component, event) {        
        document.getElementById("privacyDeclaredError").innerHTML = '';
        document.getElementById("privacyAcceptedError").innerHTML = '';
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