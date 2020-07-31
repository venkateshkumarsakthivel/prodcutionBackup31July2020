({
    loadSectionData : function(component, event) {
        
        this.showSpinner(component, event);        
        var caseid = component.get("v.caseId");
        var accountId = component.get("v.accountId");
        
        console.log('Case Id: '+caseid);
        
        var entityAction = component.get("c.getEntityType");
        entityAction.setStorable();
        entityAction.setParams({            
            "caseId": caseid
        });
        entityAction.setCallback(this,function(response) {            
            var state = response.getState();            
            if(state === "SUCCESS") {                
                console.log('Entity Type: ' + response.getReturnValue());                
                var entityType = response.getReturnValue();
                component.set("v.entityType", entityType);
                console.log('Entity Type: ' + response.getReturnValue());
            }
        });        
        $A.enqueueAction(entityAction);
        
        var action = component.get("c.retrieveApplicationDetails");
        action.setParams({
            "caseId": caseid
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = response.getReturnValue();
                console.log(sectionData);
                console.log(sectionData["Id"]);
                
                component.set('v.aspCase', sectionData);
                
                component.set('v.noticeEmail', sectionData["Notice_Email__c"]);
                component.set('v.noticeStreet', sectionData["Notice_Address_Street__c"]);
                component.set('v.noticeCity', sectionData["Notice_Address_City__c"]);
                component.set('v.noticePostcode', sectionData["Notice_Address_Postal_Code__c"]);
                component.set('v.noticeState', sectionData["Notice_Address_State__c"]); 
				component.set('v.accountId', sectionData.AccountId); 
				component.set('v.authorisationId', sectionData.Authorisation__c); 
				component.set('v.licenceNumber', sectionData.Authorisation__r.Name); 
				component.set('v.expiryDate', sectionData.Authorisation__r.End_Date__c); 
				component.set('v.operationArea', sectionData.Authorisation__r.Operation_Area__c); 
				component.set('v.licenceTerm', sectionData.Authorisation__r.Term__c); 	
				component.set('v.transferLevyFeeDue', sectionData.Levy_Due__c); 
				component.set('v.transferSaleAmt', sectionData.Licence_Fee_Due__c); 
								
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Email")
                    component.set("v.noticeType", "Email");  
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Notice Address")
                    component.set("v.noticeType", "Postal");  
                
                if(sectionData["Status"] == 'Lodged') {
                    
                    component.set('v.readOnly', true);
                    component.set('v.reviewEdit', true);
                }
                
  				if (caseRecord["Proof_Of_Identity_Documents__c"] == true) {
                    component.set("v.buyerPOIUploadStatus", true);
                    component.set("v.poiDocCheck", true);
                } else {
                    component.set("v.poiDocCheck", false);
                }
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
        
    },
    saveSectionData : function(component, event, reviewSave) {
        
        this.showSpinner(component, event);         
        var sectionData = component.get('v.aspCase');        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        if(component.get('v.noticeStreet') != undefined) {
            sectionData["Notice_Address_Street__c"] = component.get('v.noticeStreet');
            sectionData["Notice_Address_City__c"] = component.get('v.noticeCity');
            sectionData["Notice_Address_State__c"] = component.get('v.noticeState');
            sectionData["Notice_Address_Postal_Code__c"] = component.get('v.noticePostcode');
            sectionData["Notice_Email__c"] = component.get('v.noticeEmail'); 
        }
        
        if(component.get("v.noticeType") == "Email")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Email";  
        
        if(component.get("v.noticeType") == "Postal")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Notice Address";
        
        if (component.get("v.buyerPOIUploadStatus") == true)
            sectionData["Proof_Of_Identity_Documents__c"] = true;

        console.log(sectionData);

        var action = component.get("c.saveApplicationDetails");
        action.setParams({
            "application": sectionData
        });
        
        action.setCallback(this,function(response) {            
            var state = response.getState();
            
            if(state === "SUCCESS") {                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                
                var updatedCase = response.getReturnValue();
                console.log(updatedCase);
                console.log(updatedCase["Id"]);

                component.set('v.aspCase', updatedCase);
                console.log('Buyer Case Id: ' + updatedCase["Id"]);
                console.log('Review Save: ' + reviewSave);

                if(reviewSave) {                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                } else {
					var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "privacy", "caseId" : component.get('v.caseId'), "entityType" : component.get('v.entityType')});
                    nextSectionEvent.fire();
				}				
            }
            else {
                console.log('Section Data Save Failed');
                this.hideSpinner(component, event); 
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error while saving your application",
                    "type": "error",
                    "duration":10000 
                });
                toastEvent.fire();
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
        this.resetErrorMessages(component, event);        
        var hasRequiredInputsMissing = false;
        
		if(component.get('v.noticeType') == 'Email' && (component.get("v.noticeEmail") == undefined || component.get("v.noticeEmail") == "")) {
            
            component.find("Notice-Email").set("v.isRequired", true);
            component.find("Notice-Email").verifyEmail();
            if(!component.find("Notice-Email").get("v.isValid"))
                hasRequiredInputsMissing = true;
            
            if(component.find("Notice-Address").find("renderAddressInput")) {
                component.find("Notice-Address").find("street").set("v.errors", null);  
                component.find("Notice-Address").find("city").set("v.errors", null);  
                component.find("Notice-Address").find("state").set("v.errors", null);  
                component.find("Notice-Address").find("postalcode").set("v.errors", null);  
            } else {
                component.find("Notice-Address").find("autoInput").set("v.errors", null);
            }
        } 
        else if(component.get('v.noticeType') == 'Postal') {
            
            component.find("Notice-Email").set("v.isRequired", false);
            component.find("Notice-Email").verifyEmail();
            
            component.find("Notice-Address").validateAddress();
            if(!component.find("Notice-Address").get("v.isValidAddress"))
                hasRequiredInputsMissing = true;
        } 

        if (component.find("buyer-poi-Upload").get("v.FileUploadChecked") == false) {
            component.find("buyer-poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if (component.get("v.buyerPOIUploadStatus") == false) {
            console.log('Buyer poi document not uploaded');
            component.find("buyer-poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }

        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {        
        console.log('Reset Started');        
        component.find("Notice-Email").resetError();		
		console.log('Reset Done');
    }
})