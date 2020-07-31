({
    loadSectionData : function(component, event) { 
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        var accountId = component.get("v.accountId");
        
        console.log('Case Id: '+caseid);
        console.log('Account Id: '+accountId);
        
        var entityAction = component.get("c.getEntityType");
        entityAction.setStorable();
        entityAction.setParams({
            "applicantAccountId": accountId,
            "caseId": caseid
        });
        entityAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Entity Type: '+response.getReturnValue());
                
                var entityType = response.getReturnValue();
                component.set("v.entityType", entityType);
                console.log('Entity Type: '+response.getReturnValue());
            }
        });
        
        $A.enqueueAction(entityAction);
        
        var action = component.get("c.getSectionData");
        action.setParams({
            "caseId": caseid,
            "applicantAccId": accountId
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                
                console.log(sectionData);
                
                component.set('v.aspCase', sectionData);
                
                console.log(component.get('v.aspCase'));
                
                //load data
                component.set('v.operationArea', sectionData["Operation_Area__c"]);
                component.set('v.platePickupLocation', sectionData["SNSW_Plate_Pickup_Location__c"]);
                
                component.set('v.existingExpiringLicence', sectionData["Existing_Expiring_Licence__c"]);
                component.set('v.existingExpiringPlates', sectionData["Existing_Plate_Number__c"]);
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Email")
                    component.set("v.noticeType", "Email");  
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Notice Address")
                    component.set("v.noticeType", "Postal");
                
                component.set('v.noticeEmail', sectionData["Notice_Email__c"]);
                
                component.set('v.noticeStreet', sectionData["Notice_Address_Street__c"]);
                component.set('v.noticeCity', sectionData["Notice_Address_City__c"]);
                
                component.set('v.noticePostalCode', sectionData["Notice_Address_Postal_Code__c"]);
                
                if(sectionData["Notice_Address_State__c"] != "" 
                   && sectionData["Notice_Address_State__c"] != undefined)
                    component.set('v.noticeState', sectionData["Notice_Address_State__c"]);
                
                this.filterPlatePickupLocations(component, event);
                
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
        
        var conditonAction = component.get('c.getConditions');
        conditonAction.setParams({
            applicationId : caseid
        });
        
        conditonAction.setCallback(this, function(response){
            
            var state =  response.getState();
            if(state == 'SUCCESS') {
                
                console.log(state);
                console.log(response.getReturnValue());
                var licenceConditions = response.getReturnValue();
                if(licenceConditions != null && licenceConditions.length > 0) {
                    
                    component.set("v.authorisationId", licenceConditions[0]["Authority__c"]);
                } 
                
            }else{
                
                console.log(state);
            }
            
            this.hideSpinner(component, event); 
        });
        
        $A.enqueueAction(conditonAction);
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
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log(inputValue);
        console.log('Got Radio Input Value: '+inputValue);
        if(inputValue === undefined || inputValue === "") {
            
            console.log('In If');
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true || inputValue == false || inputValue == 'Taxi' || inputValue == 'Booking' || inputValue == 'Taxi and Booking'
                 || inputValue == 'Yes' || inputValue == 'No'){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        
        return false;
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        if(this.validateBlankInputs(component, event, "Operation-Area-Input", "operationArea"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Plate-Pickup-Location-Input", "platePickupLocation"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "ExistingExpiringLicenceError", "existingExpiringLicence"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.existingExpiringLicence") == 'Yes') {
            
           if(this.validateBlankInputs(component, event, "Existing-Expiring-Plates-Input", "existingExpiringPlates"))
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.noticeType") == "Email") {
           
           component.find("Notice-Email").set("v.isRequired", true); 
           component.find("Notice-Email").verifyEmail(); 
           if(component.find("Notice-Email").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        }
        else if(component.get("v.noticeType") == "Postal") {
           
           component.find("Notice-Email").set("v.isRequired", false); 
           
           component.find("Notice-Email").verifyEmail(); 
           if(component.find("Notice-Email").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
            
           component.find("Notice-Address").validateAddress();
           if(!component.find("Notice-Address").get("v.isValidAddress"))
            hasRequiredInputsMissing = true;
        }
        else {
           
           component.find("r0").set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
           hasRequiredInputsMissing = true;
        }
        
        console.log("Validation Return: "+hasRequiredInputsMissing);
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Operation-Area-Input").set("v.errors", null);
        component.find("Plate-Pickup-Location-Input").set("v.errors", null);
        
        document.getElementById("ExistingExpiringLicenceError").innerHTML = '';
        
        if(component.get("v.existingExpiringLicence") == 'Yes')
            component.find("Existing-Expiring-Plates-Input").set("v.errors", null);
        
        if(component.find("Notice-Address").get("v.renderAddressInput")) {
            
            component.find("Notice-Address").find("postalcode").set("v.errors", null);
            component.find("Notice-Address").find("state").set("v.errors", null);
            component.find("Notice-Address").find("city").set("v.errors", null);
            component.find("Notice-Address").find("street").set("v.errors", null);
            console.log(component.get("v.noticeType"));
        }
        else
            component.find("Notice-Address").find("autoInput").set("v.errors", null);
        
        console.log('Reset Done');
    },
    saveSectionData : function(component, event, reviewSave) {
        
        console.log("In Save");
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        console.log('Check this:'+component.get('v.platePickupLocation'));
        
        sectionData["Operation_Area__c"] = component.get('v.operationArea');
        sectionData["SNSW_Plate_Pickup_Location__c"] = component.get('v.platePickupLocation');
        sectionData["Existing_Plate_Number__c"] = component.get('v.existingExpiringPlates');
        sectionData["Existing_Expiring_Licence__c"] = component.get('v.existingExpiringLicence');
        
        sectionData["Is_WAT_Application__c"] = "true";
        
        if(component.get('v.noticeStreet') != undefined) {
            
            sectionData["Notice_Address_Street__c"] = component.get('v.noticeStreet');
            sectionData["Notice_Address_City__c"] = component.get('v.noticeCity').toUpperCase();
            sectionData["Notice_Address_State__c"] = component.get('v.noticeState');
            sectionData["Notice_Address_Postal_Code__c"] = component.get('v.noticePostalCode');
        }
        
        sectionData["Notice_Email__c"] = component.get('v.noticeEmail'); 
        
        if(component.get("v.noticeType") == "Email")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Email";  
        
        if(component.get("v.noticeType") == "Postal")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Notice Address";
        
        console.log(JSON.stringify(sectionData));
        
        var action = component.get("c.saveSectionData");
        action.setParams({
            "caseData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                
                var returnedEntityType = response.getReturnValue();
                
                console.log('Entity Type Returned: '+returnedEntityType);
                
                var result = returnedEntityType.split("-");
                var savedCaseId = result[1];
                
                component.set("v.caseId", savedCaseId);
                console.log("Case Id: "+savedCaseId);
                console.log("Authorisation Id: "+component.get("v.authorisationId"));
                                    
				var authorisationCreationAction = component.get('c.createAuthorisation');
				authorisationCreationAction.setParams({
					"applicationId" : savedCaseId
				});
				
				authorisationCreationAction.setCallback(this, function(response){
					
					var state =  response.getState();
					
					if(state == 'SUCCESS'){
						
						this.hideSpinner(component, event);
						console.log('New Auth Id: '+response.getReturnValue());
						component.set("v.authorisationId", response.getReturnValue());
						
						if(result[0] == "Company" && reviewSave == false) {
							
							component.set("v.entityType", "Company");
							var nextSectionEvent = component.getEvent("loadSection");
							nextSectionEvent.setParams({"sectionName": "sectionC", "caseId" : savedCaseId, "entityType" : "Company"});
							nextSectionEvent.fire();
						}
						
						if(result[0] == "Individual" && reviewSave == false) {
							
							component.set("v.entityType", "Individual"); 
							var nextSectionEvent = component.getEvent("loadSection");
							nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : savedCaseId, "entityType" : "Individual"});
							nextSectionEvent.fire();
						}
						
						if(result[0] == "Individual Partner" && reviewSave == false) {
							
							component.set("v.entityType", "Individual Partner"); 
							var nextSectionEvent = component.getEvent("loadSection");
							nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
							nextSectionEvent.fire();
						}
						if(result[0] == "Company Partner" && reviewSave == false) {
							
							component.set("v.entityType", "Company Partner"); 
							var nextSectionEvent = component.getEvent("loadSection");
							nextSectionEvent.setParams({"sectionName": "sectionC-P", "caseId" : savedCaseId, "entityType" : "Company Partner"});
							nextSectionEvent.fire();
						}
					}
				});
				
				$A.enqueueAction(authorisationCreationAction);
                
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                }
            }
            else {
                
                console.log('Section Data Save Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
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
    filterPlatePickupLocations : function(component, event){
        
        console.log('In Helper @@@@@@@@@@@@ : '+component.get('v.platePickupLocation'));
        
        var specifiedPickupLocation = component.get('v.platePickupLocation');
        
        this.showSpinner(component, event);
        
        if(component.get("v.existingExpiringLicence") == 'Yes') {
            
            var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
            var platePickupOpts = [];
            
            platePickupOpts.push({"class": "optionClass", label: "N/A", value: "Not Applicable"});
            
            platePickUpInputsel.set("v.options", platePickupOpts);
        }
        else if(component.get("v.operationArea") == 'Metropolitan Transport District (Sydney)') {
            
            var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
            var platePickupOpts = [];
            
            platePickupOpts.push({"class": "optionClass", label: "Please Select", value: ""});
            platePickupOpts.push({"class": "optionClass", label: "Botany Service Centre", value: "Botany Service Centre"});
            platePickupOpts.push({"class": "optionClass", label: "Auburn Business Dealer Centre", value: "Auburn Business Dealer Centre"});
            
            platePickUpInputsel.set("v.options", platePickupOpts);
        }
        else {
            
            var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
            var masterPlatePickupList = component.get("v.masterPlatePickupLocationList");
            var platePickupOpts = [];
            
            platePickupOpts.push({"class": "optionClass", label: "Please Select", value: ""});
            
            for(var i=0;i< masterPlatePickupList.length;i++) {
              if(masterPlatePickupList[i] != 'Silverwater Driver Test Centre'
                  && masterPlatePickupList[i] != 'Not Applicable'){
                platePickupOpts.push({"class": "optionClass", label: masterPlatePickupList[i], value: masterPlatePickupList[i]});
              }
            }
            
            platePickUpInputsel.set("v.options", platePickupOpts);
        }
        
        console.log('In Helper @@@@@@@@@@@@ : '+specifiedPickupLocation);
        
        component.set('v.platePickupLocation', specifiedPickupLocation);
        
        this.hideSpinner(component, event);
    }
})