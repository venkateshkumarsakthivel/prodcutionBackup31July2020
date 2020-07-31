({
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        var action = component.get("c.getSectionData");
        action.setParams({
            "caseId": caseid
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                
                console.log(sectionData);
                
                component.set('v.aspCase', sectionData);
                
                component.set('v.individualTitle', sectionData["Title__c"]);
                component.set('v.individualSex', sectionData["Sex__c"]);
                component.set('v.individualFamilyName', sectionData["Family_name__c"]);
                component.set('v.individualFirstName', sectionData["First_given_name__c"]);
                component.set('v.individualOtherName', sectionData["Other_given_name__c"]);
                component.set('v.individualDOB', sectionData["Birthdate__c"]);
                component.set('v.individualDriverLicenceNumber', sectionData["Australian_Driver_Licence_Number__c"]);
                component.set('v.individualDriverLicenceState', sectionData["Australian_Driver_Licence_State__c"]);
                component.set('v.individualPhoneNumber', sectionData["Daytime_phone_number__c"]);
                component.set('v.individualMobileNumber', sectionData["Mobile__c"]);
                component.set('v.individualEmail', sectionData["Email__c"]);
                component.set('v.individualBusinessName', sectionData["Registered_business_name__c"]);
                component.set('v.individualRegistrationNumber', sectionData["Registered_Business_Number__c"]);
                component.set('v.individualBusinessNumber', sectionData["ABN__c"]);
                component.set('v.otherNameDetails', sectionData["Other_Name_Details__c"]);
                component.set('v.disqualifyingOffenceDetails', sectionData["Disqualifying_Offence_Details__c"]);
                component.set('v.currentASPDetails', sectionData["Current_ASP_Details__c"]);
                component.set('v.aspComplyDetails', sectionData["Application_Completion_Auth_Details__c"]);
                component.set('v.aspActionDetails', sectionData["Auth_Action_Details__c"]);
                component.set('v.aspRefusedDetails', sectionData["Auth_Refusal_Details__c"]);
                component.set('v.caDisqualifyingOffenceDetails', sectionData["Associate_Disqualifying_Offence_Details__c"]);
                component.set('v.caRefusalDetails', sectionData["Associate_Not_Good_Repute_Details__c"]);
                
                if(sectionData["Ever_been_known_by_another_name__c"] == "Yes")
                 component.set('v.otherNameInput', true);
                
                if(sectionData["Ever_been_known_by_another_name__c"] == "No")
                 component.set('v.otherNameInput', false);
                
                if(sectionData["Has_convicted_or_disqualifying_offence__c"] == "Yes")
                 component.set('v.disqualifyingOffenceInput', true);
                
                if(sectionData["Has_convicted_or_disqualifying_offence__c"] == "No")
                 component.set('v.disqualifyingOffenceInput', false);
                
                console.log(sectionData["Has_authorization_subject_to_action__c"]);
                
                if(sectionData["Is_current_authorized_service_provider__c"] == "Yes")
                 component.set('v.currentASPInput', true);
                
                if(sectionData["Is_current_authorized_service_provider__c"] == "No")
                 component.set('v.currentASPInput', false);
                
                if(sectionData["Does_ASP_have_additional_standards__c"] == "Yes")
                 component.set('v.aspComplyInput', true);
                
                if(sectionData["Does_ASP_have_additional_standards__c"] == "No")
                 component.set('v.aspComplyInput', false);
                
                if(sectionData["Has_authorization_subject_to_action__c"] == "Yes")
                 component.set('v.aspActionInput', true);
                
                if(sectionData["Has_authorization_subject_to_action__c"] == "No")
                 component.set('v.aspActionInput', false);
                
                if(sectionData["Has_had_authorization_refused__c"] == "Yes")
                 component.set('v.aspRefusedInput', true);
                
                if(sectionData["Has_had_authorization_refused__c"] == "No")
                 component.set('v.aspRefusedInput', false);
                
                if(sectionData["Has_associate_disqualifying_offence__c"] == "Yes")
                 component.set('v.caDisqualifyingOffenceInput', true);
                
                if(sectionData["Has_associate_disqualifying_offence__c"] == "No")
                 component.set('v.caDisqualifyingOffenceInput', false);
                
                if(sectionData["Has_associate_not_of_good_repute__c"] == "Yes")
                 component.set('v.caRefusalInput', true);
                
                if(sectionData["Has_associate_not_of_good_repute__c"] == "No")
                 component.set('v.caRefusalInput', false);
                
                component.set('v.residentialCity', sectionData["Residential_Address_City__c"]);
                component.set('v.residentialState', sectionData["Residential_Address_State__c"]);
                component.set('v.residentialPostcode', sectionData["Residential_Address_Postal_Code__c"]);
                component.set('v.residentialStreet', sectionData["Residential_Address_Street__c"]);
                component.set('v.residentialCountry', sectionData["Residential_Address_Country__c"]);
                
                component.set('v.mailingCity', sectionData["Mailing_Address_City__c"]);
                component.set('v.mailingState', sectionData["Mailing_Address_State__c"]);
                component.set('v.mailingPostcode', sectionData["Mailing_Address_Postal_Code__c"]);
                component.set('v.mailingStreet', sectionData["Mailing_Address_Street__c"]);
                component.set('v.mailingCountry', sectionData["Mailing_Address_Country__c"]);
                
                this.renderForm(component, event);
            }
            else {
                
                console.log('Failed to load section data.');
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(action);
        
        this.hideSpinner(component, event); 
        
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
    renderForm : function(component, event) {
        
        //console.log(component.get("v.otherNameInput"));
        if(component.get("v.otherNameInput")) {
            
            $A.util.removeClass(component.find("otherNameInputDetails"), "toggleDisplay");
            component.find("YesOtherName").set("v.value", true);
            component.find("otherNameInputDetails").set("v.value", component.get("v.otherNameDetails"));
        }
        else if(component.get("v.otherNameInput") == false){
            
            component.find("NoOtherName").set("v.value", true);
        }
        
        if(component.get("v.currentASPInput")) {
            
            $('.currentASPHandler').show();
            $A.util.removeClass(component.find("currentASPInputDetails"), "toggleDisplay");
            component.find("YesCurrentASP").set("v.value", true);
            component.find("currentASPInputDetails").set("v.value", component.get("v.currentASPDetails"));
        }
        else if(component.get("v.currentASPInput") == false) {
            
            component.find("NoCurrentASP").set("v.value", true);
        }
        
        if(component.get("v.disqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("disqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("disqualifyingOffenceLink"), "toggleDisplay");
            component.find("YesDisqualifyingOffence").set("v.value", true);
            component.find("disqualifyingOffenceInputDetails").set("v.value", component.get("v.disqualifyingOffenceDetails"));
        }
        else if(component.get("v.disqualifyingOffenceInput") == false) {
            
            component.find("NoDisqualifyingOffence").set("v.value", true); 
        }
        
        if(component.get("v.aspComplyInput")) {
            
            $A.util.removeClass(component.find("aspComplyInputDetails"), "toggleDisplay");
            component.find("YesASPComply").set("v.value", true); 
            component.find("aspComplyInputDetails").set("v.value", component.get("v.aspComplyDetails"));
        }
        else if(component.get("v.aspComplyInput") == false) {
            
            component.find("NoASPComply").set("v.value", true); 
        }
        
        console.log('ASP Action Input: '+component.get("v.aspActionInput"));
        if(component.get("v.aspActionInput")) {
            
            $A.util.removeClass(component.find("aspActionInputDetails"), "toggleDisplay");
            component.find("YesASPAction").set("v.value", true); 
            component.find("aspActionInputDetails").set("v.value", component.get("v.aspActionDetails"));
        }
        else if(component.get("v.aspActionInput") == false) {
            
            component.find("NoASPAction").set("v.value", true); 
        }
        
        if(component.get("v.aspRefusedInput")) {
            
            $A.util.removeClass(component.find("aspRefusedInputDetails"), "toggleDisplay");
            component.find("YesASPRefused").set("v.value", true); 
            component.find("aspRefusedInputDetails").set("v.value", component.get("v.aspRefusedDetails"));
        }
        else if(component.get("v.aspRefusedInput") == false) {
            
            component.find("NoASPRefused").set("v.value", true); 
        }
        
        if(component.get("v.caDisqualifyingOffenceInput")) {
            
            $A.util.removeClass(component.find("caDisqualifyingOffenceInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("caDisqualifyingOffenceLink"), "toggleDisplay");
            component.find("YesCADisqualifyingOffence").set("v.value", true);
            component.find("caDisqualifyingOffenceInputDetails").set("v.value", component.get("v.caDisqualifyingOffenceDetails"));
        }
        else if(component.get("v.caDisqualifyingOffenceInput") == false) {
            
            component.find("NoCADisqualifyingOffence").set("v.value", true);
        }
        
        if(component.get("v.caRefusalInput")) {
            
            $A.util.removeClass(component.find("caRefusalInputDetails"), "toggleDisplay");
            $A.util.removeClass(component.find("caRefusalLink"), "toggleDisplay");
            component.find("YesCARefused").set("v.value", true);
            component.find("caRefusalInputDetails").set("v.value", component.get("v.caRefusalDetails"));
        }
        else if(component.get("v.caRefusalInput") == false) {
            
            component.find("NoCARefused").set("v.value", true);
        }
    },
    saveSectionData : function(component, event, finishLater) {
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        sectionData["Id"] = component.get('v.caseId');
        sectionData["Title__c"] = component.get('v.individualTitle');
        
        sectionData["Sex__c"] = component.get('v.individualSex');
        sectionData["Family_name__c"] = component.get('v.individualFamilyName');
        sectionData["First_given_name__c"] = component.get('v.individualFirstName');
        sectionData["Other_given_name__c"] = component.get('v.individualOtherName');
        
        sectionData["Birthdate__c"] = component.get('v.individualDOB');
        sectionData["Australian_Driver_Licence_Number__c"] = component.get('v.individualDriverLicenceNumber');
        sectionData["Australian_Driver_Licence_State__c"] = component.get('v.individualDriverLicenceState');
        sectionData["Daytime_phone_number__c"] = component.get('v.individualPhoneNumber');
        sectionData["Mobile__c"] = component.get('v.individualMobileNumber');
        sectionData["Email__c"] = component.get('v.individualEmail');
        
        
        sectionData["Registered_business_name__c"] = component.get('v.individualBusinessName');
        sectionData["Registered_Business_Number__c"] = component.get('v.individualRegistrationNumber');
        sectionData["ABN__c"] = component.get('v.individualBusinessNumber');
        sectionData["Other_Name_Details__c"] = component.get('v.otherNameDetails');
        sectionData["Disqualifying_Offence_Details__c"] = component.get('v.disqualifyingOffenceDetails');
        sectionData["Current_ASP_Details__c"] = component.get('v.currentASPDetails');
        sectionData["Application_Completion_Auth_Details__c"] = component.get('v.aspComplyDetails');
        sectionData["Auth_Action_Details__c"] = component.get('v.aspActionDetails');
        sectionData["Auth_Refusal_Details__c"] = component.get('v.aspRefusedDetails');
        sectionData["Associate_Disqualifying_Offence_Details__c"] = component.get('v.caDisqualifyingOffenceDetails');
        sectionData["Associate_Not_Good_Repute_Details__c"] = component.get('v.caRefusalDetails');
        
        sectionData["Ever_been_known_by_another_name__c"] = component.get('v.otherNameInput') == undefined ? '' : component.get('v.otherNameInput') == false ? 'No' : 'Yes';
        sectionData["Has_convicted_or_disqualifying_offence__c"] = component.get('v.disqualifyingOffenceInput') == undefined ? '' : component.get('v.disqualifyingOffenceInput') == false ? 'No' : 'Yes';
        sectionData["Is_current_authorized_service_provider__c"] = component.get('v.currentASPInput') == undefined ? '' : component.get('v.currentASPInput') == false ? 'No' : 'Yes';
        sectionData["Does_ASP_have_additional_standards__c"] = component.get('v.aspComplyInput') == undefined ? '' : component.get('v.aspComplyInput') == false ? 'No' : 'Yes';
        sectionData["Has_authorization_subject_to_action__c"] = component.get('v.aspActionInput') == undefined ? '' : component.get('v.aspActionInput') == false ? 'No' : 'Yes';
        sectionData["Has_had_authorization_refused__c"] = component.get('v.aspRefusedInput') == undefined ? '' : component.get('v.aspRefusedInput') == false ? 'No' : 'Yes';
        sectionData["Has_associate_disqualifying_offence__c"] = component.get('v.caDisqualifyingOffenceInput') == undefined ? '' : component.get('v.caDisqualifyingOffenceInput') == false ? 'No' : 'Yes';
        sectionData["Has_associate_not_of_good_repute__c"] = component.get('v.caRefusalInput') == undefined ? '' : component.get('v.caRefusalInput') == false ? 'No' : 'Yes';
        
        
        sectionData["Residential_Address_City__c"] = component.get('v.residentialCity');
        sectionData["Residential_Address_State__c"] = "NSW";
        sectionData["Residential_Address_Postal_Code__c"] = component.get('v.residentialPostcode');
        sectionData["Residential_Address_Street__c"] = component.get('v.residentialStreet');
        sectionData["Residential_Address_Country__c"] = "AUSTRALIA";
        
        sectionData["Mailing_Address_City__c"] = component.get('v.mailingCity');
        sectionData["Mailing_Address_State__c"] = "NSW";
        sectionData["Mailing_Address_Postal_Code__c"] = component.get('v.mailingPostcode');
        sectionData["Mailing_Address_Street__c"] = component.get('v.mailingStreet');
        sectionData["Mailing_Address_Country__c"] = "AUSTRALIA";
        
        
        console.log(JSON.stringify(sectionData));
        
        var action = component.get("c.saveSectionData");
        action.setParams({
            "caseData": JSON.stringify(sectionData)
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('Section Data Save Success');  
                this.hideSpinner(component, event);
                var returnedEntityType = response.getReturnValue();
                
                console.log('Entity Type Returned: '+returnedEntityType);
                
                var result = returnedEntityType.split("-");
                
                var savedCaseId = result[1];
                
                component.set("v.caseId", savedCaseId);
                
                console.log("Case Id: "+savedCaseId);
                
                if(result[0] == "Company" && finishLater == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionE", "caseId" : savedCaseId, "entityType" : "Company"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionF", "caseId" : savedCaseId, "entityType" : "Individual"});
                    nextSectionEvent.fire();
                }
                
                if(finishLater) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Application saved successfully.",
                        "type": "success",
                        "mode": "sticky" 
                    });
                    toastEvent.fire();
                    
                    window.setTimeout(function() { 
                      
                       window.location = "/industryportal/s/secure-portal-home?src=homeMenuPSP";
                    }, 3000);
                    
                }
                
            }
            else {
                
                console.log('Section Data Save Failed');
                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Radio Value: '+inputValue+' for attribute: '+attributeName);
        if(inputValue == undefined) {
            
           document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
           document.getElementById(inputId).style.display = 'block';
           return true;
        }
        else if(inputValue == true || inputValue == false){
           
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
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "Sex-Input", "individualSex"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "First-Given-Name-Input", "individualFirstName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Family-Name-Input", "individualFamilyName"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "DOB-Input", "individualDOB"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Residential-Address-Input", "residentialStreet"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Residential-Address-Input", "residentialCity"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Residential-Address-Input", "residentialPostcode"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Mailing-Address-Input", "mailingStreet"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Mailing-Address-Input", "mailingCity"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Mailing-Address-Input", "mailingPostcode"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Daytime-Phone-Input", "individualPhoneNumber"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Mobile-Input", "individualMobileNumber"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Email-Input", "individualEmail"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "DisqualifyingOffenceError", "disqualifyingOffenceInput"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "CurrentASPError", "currentASPInput"))
           hasRequiredInputsMissing = true;
        
        if(component.get("v.currentASPInput") == true) {
         
          if(this.validateBlankRadioInputs(component, event, "ASPComplyError", "aspComplyInput"))
           hasRequiredInputsMissing = true;
        
          if(this.validateBlankRadioInputs(component, event, "ASPActionError", "aspActionInput"))
           hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "ASPRefusedError", "aspRefusedInput"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "CADisqualifyingOffenceError", "caDisqualifyingOffenceInput"))
           hasRequiredInputsMissing = true;
        
        if(this.validateBlankRadioInputs(component, event, "YesCARefusedError", "caRefusalInput"))
           hasRequiredInputsMissing = true;

        if(component.find("Mailing-Address-Input").validateAddress())
           hasRequiredInputsMissing = true;
        
        if(component.find("Residential-Address-Input").validateAddress())
           hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    }
       
})