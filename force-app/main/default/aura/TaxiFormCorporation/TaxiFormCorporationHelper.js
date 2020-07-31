({
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        var accountId = component.get("v.accountId");
        
        var action = component.get("c.getCorporationDetailsSectionData");
        action.setParams({
            "caseId": caseid
        });
        
        action.setCallback(this,function(response) {            
            var state = response.getState();
            
            if(state === "SUCCESS") {                
                var sectionData = JSON.parse(response.getReturnValue());                
                console.log('sectionData: ');
                console.log(sectionData);
                component.set('v.CorporationName', sectionData["Corporation_Name__c"]);
                component.set('v.CorporationACN', sectionData["ACN__c"]);
                component.set('v.CorporationABN', sectionData["ABN__c"]);
                component.set('v.CorporationBusinessName', sectionData["Registered_Business_Name__c"]);
                component.set('v.CorporationPhone', sectionData["Daytime_Phone__c"]);
                component.set('v.corporationSectionData', sectionData);             
            }
            else {                
                console.log('Failed to load section data.');
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(action);
        
        /*
        var accountAction = component.get("c.getAccountDetails");
        accountAction.setParams({
            "caseId": caseid
        });
        
        accountAction.setCallback(this,function(response) {            
            var state = response.getState();            
            if(state === "SUCCESS") {                
                var sectionData = JSON.parse(response.getReturnValue());                
                console.log('Account details');
                console.log(sectionData);
                component.set('v.CorporationName', sectionData["Corporation_name__c"]);
                component.set('v.CorporationACN', sectionData["ACN__c"]);
                component.set('v.CorporationABN', sectionData["ABN__c"]);
                component.set('v.CorporationBusinessName', sectionData["Registered_Business_Name__c"]);
                component.set('v.CorporationPhone', sectionData["Daytime_phone_number__c"]);
            } else {                
                console.log('Failed to load account details.');
            }
        });
        
        if(caseid != "")
            $A.enqueueAction(accountAction);
        */
        
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
    saveSectionData : function(component, event, finishLater, reviewSave){
        
        this.showSpinner(component, event); 
        
        var caseId = component.get('v.caseId');
        var accountId = component.get('v.accountId');
        console.log(caseId);
        console.log(accountId);
        
        // Save corporation details as Related Contact associated with Case
        var corporationData = component.get('v.corporationSectionData');
        console.log(corporationData);
        
        corporationData["Contact_Type__c"] = "General Contact";
        corporationData["Related_Application__c"] = caseId;
        corporationData["Family_Name__c"] = this.toSentenceCase(component.get('v.CorporationName'));
        corporationData["Corporation_name__c"] = this.toSentenceCase(component.get('v.CorporationName'));
        corporationData["ACN__c"] = component.get('v.CorporationACN');
        corporationData["ABN__c"] = component.get('v.CorporationABN');
        corporationData["Registered_business_name__c"] = component.get('v.CorporationBusinessName');
        corporationData["Daytime_Phone__c"] = component.get('v.CorporationPhone');
        
        /*sectionData["Notice_Address_Street__c"] = component.get('v.noticeUnitType')+' '+component.get('v.noticeStreet');
        sectionData["Notice_Office_Address_City__c"] = component.get('v.noticeCity').toUpperCase();
        sectionData["Notice_Address_State__c"] = component.get('v.noticeState');
        sectionData["Notice_Address_Postal_Code__c"] = component.get('v.noticePostcode');
        sectionData["Notice_Address_Country__c"] = "AUSTRALIA";
        sectionData["Notice_Email__c"] = component.get('v.noticeEmail');*/
        
        console.log(JSON.stringify(corporationData));
        
       	var action = component.get("c.saveCorporationDetailsSectionData");
        action.setParams({
            "corporationData": JSON.stringify(corporationData)
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
                
                if(result[0] == "Company" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Company");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionD", "caseId" : savedCaseId, "entityType" : "Company"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual" && finishLater == false && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual"); 
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionD", "caseId" : savedCaseId, "entityType" : "Individual"});
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
                    
                    if(component.get("v.accountId") != undefined && component.get("v.accountId") != "") {
                        
                        component.getEvent("closeApplication").fire();
                    }
                    else {
                        window.setTimeout(function() { 
                            
                            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
                        }, 3000);
                    }
                    
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
        console.log('Got Input Value: '+inputValue);
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
        if(inputValue == undefined || inputValue == null || inputValue === '' || (typeof(inputValue) === 'string' && inputValue.trim() === '')) {
            
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
        
        if(this.validateBlankInputs(component, event, "Corporation-Name-Input", "CorporationName"))
            hasRequiredInputsMissing = true;
        
        
        component.find("ACN-Input").verifyAcn();
        if(component.find("ACN-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
         
        component.find("Daytime-Phone-Input").verifyPhone();      
        if(component.find("Daytime-Phone-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
      /*  component.find("Notice-Email").verifyEmail();
        if(component.find("Notice-Email").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        
        
        component.find("Notice-Address").validateAddress();
        if(!component.find("Notice-Address").get('v.isValidAddress'))
            hasRequiredInputsMissing = true;
        */
        console.log("Validation Result: "+hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
    },
    
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
    resetErrorMessages : function(component, event) {
        component.find("Corporation-Name-Input").set("v.errors", null);
        
    }
    
})