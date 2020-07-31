({
	loadSectionData : function(component, event){
		
      this.showSpinner(component, event);
        
        console.log('TaxiTransferFormPartB loadSectionData');
		var caseid = component.get("v.caseId");
		
        var action = component.get("c.retrieveApplicationDetails");
		action.setParams({
			"caseId": caseid
		});
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
				var sectionData = response.getReturnValue();
				component.set('v.aspCase', sectionData);
                	console.log('sectionData'+sectionData);
                console.log('Is_Privacy_Statement_Declared__c'+sectionData["Is_Privacy_Statement_Declared__c"]);
                console.log('Information_Declaration__c'+sectionData["Information_Declaration__c"]);
				
				if(sectionData["Is_Privacy_Statement_Declared__c"] == true)
					component.set('v.isPrivecyStatementAccepted', true);
				else 
					component.set('v.isPrivecyStatementAccepted', false);
                
                if(sectionData["Information_Declaration__c"] == true)
					component.set('v.isInformationDeclared', true);
				else
					component.set('v.isInformationDeclared', false);
                
			} else{
				var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error while retrieving your application details",
                    "type": "error",
                    "duration":10000 
                });
                toastEvent.fire();
			}
			this.hideSpinner(component, event); 
            
                
		});
		$A.enqueueAction(action);
 
	},

	savePrivacyStatement : function(component, event, finishLater, reviewSave){
		
        this.showSpinner(component, event);
        
        var sectionData = component.get('v.aspCase');
		sectionData["Id"] = component.get('v.caseId');
		sectionData["Is_Privacy_Statement_Declared__c"] = component.get('v.isPrivecyStatementAccepted');
        sectionData["Information_Declaration__c"] = component.get('v.isInformationDeclared');
        var action = component.get("c.saveApplicationDetails");
		action.setParams({
			"application": sectionData
		});

		action.setCallback(this,function(response){

			var state = response.getState();
			if(state === "SUCCESS"){
				this.hideSpinner(component, event); 

                if(finishLater == false && reviewSave == false) {
                    var nextSectionEvent = component.getEvent("loadSection");
			        nextSectionEvent.setParams({"sectionName": "review", "caseId" : component.get('v.caseId'), "entityType" : component.get('v.entityType')});
				    nextSectionEvent.fire();
					
                } else if(reviewSave) {
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                
				} else if(finishLater) {
					var toastEvent = $A.get("e.force:showToast");           	
					toastEvent.setParams({
						"title": "Success",
						"message": "Application saved successfully.",
						"type": "success",
                        "duration":10000 
					});
					toastEvent.fire();

					if(component.get("v.accountId") != undefined && component.get("v.accountId") != "") {
                        
                        component.getEvent("closeApplication").fire();
                    }else {    
                        window.setTimeout(function() { 
                            
                            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
                        }, 3000);
                    }

				}
			}
			else {
				this.hideSpinner(component, event); 
			}
		});

		$A.enqueueAction(action);
	},
	
	performBlankInputCheck : function(component, event){
		
        var hasRequiredInputsMissing = false;        
        this.resetErrorMessages(component, event);
        
        if(this.validateBlankInputs(component, event, "privacyDeclaredError", "isInformationDeclared", $A.get("$Label.c.Privacy_Declaration_Error_Message")))
			hasRequiredInputsMissing = true;
        
		if(this.validateBlankInputs(component, event, "privacyAcceptedError", "isPrivecyStatementAccepted", $A.get("$Label.c.Privacy_Statement_Error_Message")))
			hasRequiredInputsMissing = true;

		return hasRequiredInputsMissing;
	},
	
	validateBlankInputs : function(component, event, inputId, attributeName, msg){

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