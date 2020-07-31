({
    loadSectionData : function(component, event) {
        
        console.log("In Entity Type" + component.get("v.accountId"));
        console.log("In Entity Type A" + component.get("v.entityType"));
        console.log(component.get("v.accountId"));
        
        this.showSpinner(component, event);
        
        var caseid = component.get("v.caseId");
        
        console.log('Case Id: '+caseid);
        
        var entityAction;
        
        if((component.get("v.accountId") == undefined || component.get("v.accountId") == "")
           && component.get("v.entityType") == null) {
            entityAction = component.get("c.getEntityType");
            entityAction.setParams({
                "caseId": caseid
            });
        }
        else {
            entityAction = component.get("c.getAccountEntityType");
            entityAction.setParams({
                "applicantAccountId": component.get("v.accountId")
            });  
        }
        
        if(component.get("v.entityType") == null) {
            
            
            entityAction.setStorable();
            entityAction.setCallback(this,function(response) {
                console.log("In Entity Type");
                var state = response.getState();
                
                if(state === "SUCCESS") {
                    
                    console.log('Entity Type: '+response.getReturnValue());
                    
                    var entityType = response.getReturnValue();
                    component.set("v.entityType", entityType);
                    console.log('Entity Type: '+response.getReturnValue());
                }
            });
            
            $A.enqueueAction(entityAction);
        }
        
        var action;
        if(caseid != undefined && caseid != "") {
            
            action = component.get("c.getSectionData");
            action.setParams({
                "caseId": caseid
            });
        }
        else {
            
            action = component.get("c.getAccountSectionData");
            action.setParams({
                "accountId": component.get("v.accountId")
            });  
        }
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var sectionData = JSON.parse(response.getReturnValue());
                console.log(sectionData);
                console.log(sectionData["Id"]);
                
                component.set('v.aspCase', sectionData);
                
                //load data
                component.set('v.businessStreet', sectionData["Business_Address_Street__c"]);
                component.set('v.businessCity', sectionData["Business_Address_City__c"]);
                component.set('v.businessState', sectionData["Business_Address_State__c"]);
                component.set('v.businessPostalCode', sectionData["Business_Address_Postal_Code__c"]);
                component.set('v.businessInternational', sectionData["Business_International_Address__c"]);
                component.set('v.businessIsAustralian', true);
                
                if(component.get('v.businessInternational') == undefined 
                   || component.get('v.businessInternational') == "") {
                    
                    component.set('v.businessIsInternational', false);
                    component.set('v.businessIsAustralian', true);
                }
                else {
                    
                    component.set('v.businessIsInternational', true);
                    component.set('v.businessIsAustralian', false);
                }
                
                component.set('v.noticeEmail', sectionData["Notice_Email__c"]);
                
                component.set('v.noticeStreet', sectionData["Notice_Address_Street__c"]);
                component.set('v.noticeCity', sectionData["Notice_Address_City__c"]);
                
                component.set('v.noticePostalCode', sectionData["Notice_Address_Postal_Code__c"]);
                
                // latitude/longitude values
                component.set('v.latitude', sectionData["Notice__Latitude__s"]);
                component.set('v.longitude', sectionData["Notice__Longitude__s"]);
                
                component.set('v.recordKeepingStreet', sectionData["Record_Keeping_Street__c"]);
                component.set('v.recordKeepingCity', sectionData["Record_Keeping_City__c"]);
                
                if(sectionData["Notice_Address_State__c"] != "" 
                   && sectionData["Notice_Address_State__c"] != undefined)
                    component.set('v.noticeState', sectionData["Notice_Address_State__c"]);
                
                if(sectionData["Record_Keeping_State__c"] != "" 
                   && sectionData["Record_Keeping_State__c"] != undefined)
                    component.set('v.recordKeepingState', sectionData["Record_Keeping_State__c"]);
                
                component.set('v.recordKeepingPostalCode', sectionData["Record_Keeping_Postal_Code__c"]);
                
                component.set('v.licenceType', sectionData["Service_Type__c"]);
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Email")
                    component.set("v.noticeType", "Email");  
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Notice Address")
                    component.set("v.noticeType", "Postal");  
                
                console.log('Got Service Type: '+sectionData["Service_Type__c"]);
                
                if(sectionData["Service_Type__c"] != undefined)
                    document.getElementById(sectionData["Service_Type__c"]).checked = true;
                
                if(component.get("v.businessIsInternational")) {
                    
                    component.find("noticeSameAsBusiness").set("v.disabled", true);
                    component.find("recordKeepingSameAsBusiness").set("v.disabled", true);
                }
                
                component.set('v.businessName', sectionData["Business_Name_For_Customer_Contact__c"]);
                component.set('v.businessEmail', sectionData["Email_For_Customer_Contact__c"]);
                component.set('v.businessPhoneNumber', sectionData["Daytime_Phone_No_For_Customer_Contact__c"]);
                component.set('v.businessWebsite', sectionData["Website_For_Customer_Contact__c"]);
                component.set('v.businessSocialMedia', sectionData["Social_Media_For_Customer_Contact__c"]);
                component.set('v.businessOther', sectionData["Other_Details_For_Customer_Contact__c"]);
                
                if(component.get('v.businessEmail') != undefined)
                 component.set("v.businessEmailInput", true);
                
                if(component.get('v.businessWebsite') != undefined)
                 component.set("v.businessWebsiteInput", true);
                
                if(component.get('v.businessPhoneNumber') != undefined)
                 component.set("v.businessPhoneNumberInput", true);
                
                if(component.get('v.businessSocialMedia') != undefined)
                 component.set("v.businessSocialMediaInput", true);
                
                if(component.get('v.businessOther') != undefined)
                 component.set("v.businessOtherInput", true);
                
                component.set('v.partnershipName', sectionData["Partnership_Name__c"]);
                component.set('v.partnershipHoldABN', sectionData["Partnership_Hold_An_ABN__c"]);
                component.set('v.individualBusinessName', sectionData["Registered_business_name__c"]);
                component.set('v.individualBusinessNumber', sectionData["ABN__c"]);
            }
        });
        
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
    saveSectionData : function(component, event, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        if(component.find("Business-Address").get("v.isInternationalAddress") == false) { 
            
            sectionData["Business_Address_Street__c"] = component.get('v.businessStreet');
            sectionData["Business_Address_City__c"] = component.get('v.businessCity').toUpperCase();
            sectionData["Business_Address_State__c"] = component.get('v.businessState');
            sectionData["Business_Address_Postal_Code__c"] = component.get('v.businessPostalCode');
            sectionData["Business_International_Address__c"] = "";
        }
        else {            
            sectionData["Business_Address_Street__c"] = "";
            sectionData["Business_Address_City__c"] = "";
            sectionData["Business_Address_State__c"] = "";
            sectionData["Business_Address_Postal_Code__c"] = "";
            sectionData["Business_International_Address__c"] = component.get('v.businessInternational');
        }
        
        if(component.get('v.noticeStreet') != undefined) {
            
         sectionData["Notice_Address_Street__c"] = component.get('v.recordKeepingStreet');
         sectionData["Notice_Address_City__c"] = component.get('v.noticeCity').toUpperCase();
         sectionData["Notice_Address_State__c"] = component.get('v.noticeState');
         sectionData["Notice_Address_Postal_Code__c"] = component.get('v.noticePostalCode');
         sectionData["Notice__Latitude__s"] = component.get('v.latitude');
         sectionData["Notice__Longitude__s"] = component.get('v.longitude');
        }
        
        sectionData["Notice_Email__c"] = component.get('v.noticeEmail'); 
        
        if(component.get("v.noticeType") == "Email")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Email";  
        
        if(component.get("v.noticeType") == "Postal")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Notice Address";
        
        sectionData["Record_Keeping_Street__c"] = component.get('v.recordKeepingUnitType')+' '+component.get('v.recordKeepingStreet');
        
        if(component.get('v.recordKeepingCity') != "" && component.get('v.recordKeepingCity') != undefined)
            sectionData["Record_Keeping_City__c"] = component.get('v.recordKeepingCity').toUpperCase();
        
        if(component.get('v.recordKeepingCity') != "" || component.get('v.recordKeepingPostalCode') != "" 
           || component.get('v.recordKeepingStreet') != "")
            sectionData["Record_Keeping_State__c"] = component.get('v.recordKeepingState');
        
        sectionData["Record_Keeping_Unit_Type__c"] = component.get('v.recordKeepingUnitType');
        sectionData["Record_Keeping_Postal_Code__c"] = component.get('v.recordKeepingPostalCode');
        
        sectionData["Service_Type__c"] = component.get('v.licenceType');
        
        sectionData["Business_Name_For_Customer_Contact__c"] = component.get('v.businessName');
        sectionData["Email_For_Customer_Contact__c"] = component.get('v.businessEmail');
        sectionData["Daytime_Phone_No_For_Customer_Contact__c"] = component.get('v.businessPhoneNumber');
        sectionData["Website_For_Customer_Contact__c"] = component.get('v.businessWebsite');
        sectionData["Social_Media_For_Customer_Contact__c"] = component.get('v.businessSocialMedia');
        sectionData["Other_Details_For_Customer_Contact__c"] = component.get('v.businessOther');
        
        sectionData["Partnership_Name__c"] = component.get('v.partnershipName');
        sectionData["Partnership_Hold_An_ABN__c"] = component.get('v.partnershipHoldABN');
        
        if(component.get('v.individualBusinessName') != "" && component.get('v.individualBusinessName') != undefined)
            sectionData["Registered_business_name__c"] = this.toSentenceCase(component.get('v.individualBusinessName'));
        sectionData["ABN__c"] = component.get('v.individualBusinessNumber');
        
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
                
                if(result[0] == "Company Partner" && reviewSave == false) {
                    
                    component.set("v.entityType", "Company Partner");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionC-P", "caseId" : savedCaseId, "entityType" : "Company Partner"});
                    nextSectionEvent.fire();
                }
                
                if(result[0] == "Individual Partner" && reviewSave == false) {
                    
                    component.set("v.entityType", "Individual Partner");
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionB-P", "caseId" : savedCaseId, "entityType" : "Individual Partner"});
                    nextSectionEvent.fire();
                }
                
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
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        console.log('Got Input Value: '+inputValue);
        if(inputValue == undefined || inputValue == "") {
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true || inputValue == false || inputValue == 'Taxi' || inputValue == 'Booking' || inputValue == 'Taxi and Booking'){
            
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
        
        if(this.validateBlankRadioInputs(component, event, "servicetypeError", "licenceType"))
            hasRequiredInputsMissing = true;
        
        component.find("Business-Address").validateAddress();
        if(!component.find("Business-Address").get("v.isValidAddress"))
            hasRequiredInputsMissing = true;
        
        component.find("Record-Keeping-Address").validateAddress();
        if(!component.find("Record-Keeping-Address").get("v.isValidAddress"))
            hasRequiredInputsMissing = true;
        
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
        
        if(this.validateBlankInputs(component, event, "Business-Name-Input", "businessName"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.businessEmailInput")) {
            
           component.find("Business-Email-Input").verifyEmail(); 
           if(component.find("Business-Email-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.businessWebsiteInput")) {
            
           if(this.validateBlankInputs(component, event, "Business-Website", "businessWebsite"))
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.businessPhoneNumberInput")) {
            
           component.find("Business-Daytime-Phone-Input").verifyPhone();      
           if(component.find("Business-Daytime-Phone-Input").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.businessSocialMediaInput")) {
           
           if(this.validateBlankInputs(component, event, "Business-SocialMedia", "businessSocialMedia"))
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.businessOtherInput")) {
           
           if(this.validateBlankInputs(component, event, "Business-Other", "businessOther"))
            hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.businessEmailInput") == false 
            && component.get("v.businessWebsiteInput") == false
            && component.get("v.businessPhoneNumberInput") == false
            && component.get("v.businessSocialMediaInput") == false
            && component.get("v.businessOtherInput") == false) {
           
           document.getElementById("publicContactDetailsError").innerHTML = "At least one of the above needs to be completed.";
           document.getElementById("publicContactDetailsError").style.display = 'block';
           hasRequiredInputsMissing = true;
        }
        
        if(component.get("v.individualBusinessNumber") != undefined 
            && component.get("v.individualBusinessNumber") != ""
            && component.find("ABN-Input") != undefined) {
        
            component.find("ABN-Input").verifyAbn();
            if(component.find("ABN-Input").get("v.isValid") == false)
             hasRequiredInputsMissing = true;
        }
        
        console.log('hasRequiredInputsMissing' + hasRequiredInputsMissing);
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        console.log(component.get("v.noticeType"));
        
        if(component.find("Notice-Address").get("v.renderAddressInput")) {
            
            component.find("Notice-Address").find("postalcode").set("v.errors", null);
            component.find("Notice-Address").find("state").set("v.errors", null);
            component.find("Notice-Address").find("city").set("v.errors", null);
            component.find("Notice-Address").find("street").set("v.errors", null);
            console.log(component.get("v.noticeType"));
        }
        else
            component.find("Notice-Address").find("autoInput").set("v.errors", null);
        
        if(component.find("Business-Address").get("v.isInternationalAddress") == false) {
            
            if(component.find("Business-Address").get("v.renderAddressInput")) {
                
                component.find("Business-Address").find("postalcode").set("v.errors", null);
                component.find("Business-Address").find("state").set("v.errors", null);
                component.find("Business-Address").find("city").set("v.errors", null);
                component.find("Business-Address").find("street").set("v.errors", null);
            }
            else
                component.find("Business-Address").find("autoInput").set("v.errors", null);
        }
        else
            component.find("Business-Address").find("internationalAddress").set("v.errors", null);
        
        
        if(component.find("Record-Keeping-Address").get("v.isInternationalAddress") == false) {
            
            if(component.find("Record-Keeping-Address").get("v.renderAddressInput")) {
                
                component.find("Record-Keeping-Address").find("postalcode").set("v.errors", null);
                component.find("Record-Keeping-Address").find("state").set("v.errors", null);
                component.find("Record-Keeping-Address").find("city").set("v.errors", null);
                component.find("Record-Keeping-Address").find("street").set("v.errors", null);
            }
            else
                component.find("Record-Keeping-Address").find("autoInput").set("v.errors", null);
        }
        else
            component.find("Record-Keeping-Address").find("internationalAddress").set("v.errors", null);
        
        
        component.find("Business-Name-Input").set("v.errors", null);
        if(component.get("v.businessWebsiteInput")) {
            
           component.find("Business-Website").set("v.errors", null);
        }
        else if(component.get("v.businessSocialMediaInput")) {
           
           component.find("Business-SocialMedia").set("v.errors", null);
        }
        else if(component.get("v.businessOtherInput")) {
           
           component.find("Business-Other").set("v.errors", null);
        }
        
        document.getElementById("servicetypeError").innerHTML = '';
        document.getElementById("servicetypeError").style.display = 'none';
        
        document.getElementById("publicContactDetailsError").innerHTML = '';
        document.getElementById("publicContactDetailsError").style.display = 'none';
        
        console.log("Done Resetting");
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
    toSentenceCase : function(inputStr) {
        
        console.log("To Sentence Case: "+inputStr);
        var tempStr = inputStr.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
        console.log("To Sentence Case: "+tempStr);
        return tempStr;
    },
})