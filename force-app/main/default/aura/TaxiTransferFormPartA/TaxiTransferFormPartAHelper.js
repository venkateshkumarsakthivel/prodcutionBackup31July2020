({
    checkExistingTransferApplicationOpen : function(component, event, recordId) {
        
        var action = component.get("c.isExistingTransferApplicationOpen");
        action.setParams({
            "authorisationId": recordId
        });
        action.setCallback(this,function(response) {
            
            var isPreviousTransferApplicationOpen = response.getReturnValue();
            
            console.log('IsExistingTransferApplicationOpen : ' + isPreviousTransferApplicationOpen); 
            
            if(isPreviousTransferApplicationOpen) {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": "A transfer application already exists for this licence. You cannot submit a new application until the existing one is closed. You can review this application under the My Applications tab.",
                    "duration":10000,
                    "type": "error"
                });
                toastEvent.fire();
                
                component.getEvent("closeApplication").fire();
            } 
        });
        
        $A.enqueueAction(action);
    },
    getAuthorisationDetails : function(component, event) {
        
        var authorisationId = component.get('v.existingLicence');
        
        var action = component.get("c.getAuthorisationRecord");
        action.setParams({
            "authorisationId" : authorisationId
        });
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                var authorisation = response.getReturnValue();
                component.set('v.authName', authorisation.Name);  
                component.set('v.authAccountId', authorisation.Service_Provider__c);  
                component.set('v.endDate', authorisation.End_Date__c);
                component.set('v.operationArea', authorisation.Operation_Area__c);
                component.set('v.licenceTerm', authorisation.Term__c);
                component.set('v.licenceClass', authorisation.Licence_Class__c); 
                
                // All checks is User is not internal are performed in TaxiManageAccountLicences for Application from Portal
                if(component.get("v.isInternalUser") && authorisation.Status__c != "Granted") {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": 'Cannot initiate transfer of Taxi Licence with current status other than "Granted"',
                        "duration":10000,
                        "type": "error"
                    });
                    toastEvent.fire();
                    
                    component.getEvent("closeApplication").fire();
                }
                
                if(component.get("v.isInternalUser")) {
                    this.checkExistingTransferApplicationOpen(component, event, authorisation.Id);
                }
                
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
    },
    loadSectionData : function(component, event) {
        
        var authorisationId = component.get('v.existingLicence');
        var caseId = component.get("v.sellerCaseId");
        
        console.log(authorisationId);
        console.log(caseId);
        
        var getExistingTaxiTransferApplicationDetails = component.get("c.getTaxiTransferApplicationDetails");
        getExistingTaxiTransferApplicationDetails.setParams({
            "caseId": caseId
        });
        getExistingTaxiTransferApplicationDetails.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                this.hideSpinner(component, event);
                
                var caseRecord = JSON.parse(response.getReturnValue());
                
                console.log('TaxiTransferFormPartA getTaxiTransferApplicationDetails callback');
                console.log(caseRecord);
                
                // Set attribute values
                component.set("v.Authorisation__c", caseRecord["Authorisation__c"]);
                component.set("v.transferReason", caseRecord["Transfer_Reason__c"]);
                component.set("v.transferPrice", caseRecord["Licence_Fee_Due__c"]);
                component.set("v.buyerType", caseRecord["Beneficiary_Type__c"]);
                if(caseRecord["Proof_of_Sale_or_Will_or_Death__c"] == true){
                    component.set("v.contractUploadStatus", true);
                    component.set("v.saleDocCheck", true);
                } else {
                    component.set("v.saleDocCheck", false);
                }
                if(caseRecord["Proof_Of_Identity_Documents__c"] == true){
                    component.set("v.sellerPOIUploadStatus", true);
                    component.set("v.poiDocCheck", true);
                } else {
                    component.set("v.poiDocCheck", false);
                }
                component.set('v.caseStatus', caseRecord["Status"]);
                
                if(caseRecord["Status"] == 'Lodged') {
                    
                    component.set('v.readOnly', true);
                    component.set('v.canEdit', false);
                    
                    // Get Licence Market Value and Levy Due values
                    var getBuyerCaseDataAction = component.get("c.getLicenceMarketValueAndLevyDueTaxiTransfer");
                    getBuyerCaseDataAction.setParams({
                        "sellerCaseId" : caseId
                    });
                    getBuyerCaseDataAction.setCallback(this, function(response) {
                        
                        console.log('TaxiTransferFormPartA getLicenceMarketValueAndLevyDueTaxiTransfer callback');
                        this.hideSpinner(component, event);
                        var state = response.getState();
                        if (component.isValid() && state === "SUCCESS") {
                            
                            var buyerCaseRecord = JSON.parse(response.getReturnValue());
                            console.log(buyerCaseRecord);
                            
                            component.set('v.licenceMarketValue', buyerCaseRecord.Licence_Market_Value__c);  
                            component.set('v.levyDueAmount', buyerCaseRecord.Levy_Due__c);  
                        }
                    });
                    
                    $A.enqueueAction(getBuyerCaseDataAction);
                    this.showSpinner(component, event);
                }
                
                // Get related contacts
                if(caseRecord["Beneficiary_Type__c"] != undefined || caseRecord["Beneficiary_Type__c"]!= '') {
                    this.getRelatedContacts(component, event, caseRecord["Beneficiary_Type__c"]);
                }
                
                // Get existing Authorsation details
                component.set("v.existingLicence", caseRecord["Authorisation__c"]);
                this.getAuthorisationDetails(component, event);
            }
        });
        
        if(caseId != null) {
            
            $A.enqueueAction(getExistingTaxiTransferApplicationDetails);
            this.showSpinner(component, event);
        }
    },
    getRelatedContacts : function (component, event, buyerType) {
        
        var caseId = component.get("v.sellerCaseId");
        var action = component.get("c.getRelatedContactsData");
        action.setParams({
            "caseId": caseId,
            "buyerType": buyerType
        });
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            
            if(state === "SUCCESS"){
                var contact = JSON.parse(response.getReturnValue());
                console.log('Related Contact');
                console.log(contact);
                component.set('v.daytimePhone', contact.Daytime_Phone__c);
                component.set('v.email', contact.Email__c);
                if(buyerType == 'Individual')
                    component.set("v.individualPartner", contact);
                else if(buyerType == 'Corporation')
                    component.set("v.corporatePartner", contact); 
                
                    else if(buyerType == 'Joint-Holders') {
                        var contactList = contact;
                        var individualBuyers = component.get("v.jointHoldersIndividualPartners");
                        var corporateBuyers = component.get("v.jointHoldersCorporatePartners");
                        for(var i = 0; i < contactList.length; i++) {
                            if(contactList[i].Contact_Type__c == 'Individual Beneficiary'){
                                individualBuyers.push(contactList[i]);
                            }
                            else if(contactList[i].Contact_Type__c == 'Corporate Beneficiary'){
                                corporateBuyers.push(contactList[i]);
                            }
                        }  
                        component.set("v.jointHoldersIndividualPartners", individualBuyers);
                        component.set("v.jointHoldersCorporatePartners", corporateBuyers);
                    }
                
            }
            else{
                console.log('TaxiTransferFormPartA getRelatedContacts error');
            }
        });
        
        $A.enqueueAction(action);
        this.showSpinner(component, event);
        
    },
    saveForm : function(component,event,reviewSave) {
        
        console.log('TaxiTransferFormPartA saveForm');
        
        var sellerCaseRecord = {};
        sellerCaseRecord.sobjectType = 'Case';
        
        var buyerCaseRecord = {};
        buyerCaseRecord.sobjectType = 'Case';
        
        var sellerCaseId = component.get("v.sellerCaseId");
        console.log(sellerCaseId);
        
        if(sellerCaseId === undefined || sellerCaseId === null || sellerCaseId === '') {
            
            sellerCaseRecord.Status = "Draft";
            sellerCaseRecord.Sub_Status__c = "Draft";
            sellerCaseRecord.Authorisation__c = component.get('v.existingLicence');
            sellerCaseRecord.AccountId = component.get('v.authAccountId');
            
            buyerCaseRecord.Status = "New";
            buyerCaseRecord.Sub_Status__c = "Draft";
            buyerCaseRecord.Authorisation__c = component.get('v.existingLicence');
        } 
        
        sellerCaseRecord.Id = sellerCaseId;
        
        sellerCaseRecord.Transfer_Reason__c = component.get('v.transferReason');
        sellerCaseRecord.Licence_Fee_Due__c = component.get('v.transferPrice');
        sellerCaseRecord.Beneficiary_Type__c = component.get("v.buyerType");
        
        buyerCaseRecord.Transfer_Reason__c = component.get('v.transferReason');
        
        var individualPartner = {};
        var corporatePartner = {};
        var individualPartners;
        var corporatePartners;
        
        if(component.get("v.buyerType") == "Individual") {
            
            individualPartner = component.get('v.individualPartner');
            individualPartner.Daytime_Phone__c = component.get('v.daytimePhone');
            individualPartner.Email__c = component.get('v.email');
            
        } else if(component.get("v.buyerType" ) == "Corporation") {
            
            corporatePartner = component.get('v.corporatePartner');
            corporatePartner.Family_Name__c = corporatePartner.Corporation_Name__c;
            corporatePartner.Daytime_Phone__c = component.get('v.daytimePhone');
            corporatePartner.Email__c = component.get('v.email');
        } else if(component.get("v.buyerType" ) == "Joint-Holders") {
            
            var individualPartners = component.get('v.jointHoldersIndividualPartners');
            var corporatePartners = component.get('v.jointHoldersCorporatePartners');
            
            for(var index = 0; index < corporatePartners.length; index++) {
                corporatePartners[index]["Family_Name__c"] = corporatePartners[index]["Corporation_Name__c"];
                corporatePartners[index].Daytime_Phone__c = component.get('v.daytimePhone');
                corporatePartners[index].Email__c = component.get('v.email');
            }
            for(var index = 0; index < individualPartners.length; index++) {
                individualPartners[index].Daytime_Phone__c = component.get('v.daytimePhone');
                individualPartners[index].Email__c = component.get('v.email');
            }
        }
        
        console.log(JSON.stringify(sellerCaseRecord));
        console.log(JSON.stringify(buyerCaseRecord));
        console.log(component.get('v.buyerType'));
        console.log(JSON.stringify(individualPartner));
        console.log(JSON.stringify(corporatePartner));
        console.log(JSON.stringify(individualPartners));
        console.log(JSON.stringify(corporatePartners));
        
        var saveAction = component.get("c.saveLicenceTransferData");
        saveAction.setParams({
            "sellerCaseRecord" : JSON.stringify(sellerCaseRecord),
            "buyerCaseRecord" : JSON.stringify(buyerCaseRecord),
            "buyerType" : component.get('v.buyerType'),
            "individualPartnerData" : JSON.stringify(individualPartner),
            "corporatePartnerData" : JSON.stringify(corporatePartner),
            "individualPartnersData" : JSON.stringify(individualPartners),
            "corporatePartnersData" : JSON.stringify(corporatePartners),
            "authId" : component.get('v.existingLicence'),
        });  
        saveAction.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (component.isValid() && state === "SUCCESS") {
                
                this.hideSpinner(component,event);
                
                var sellerCaseId = response.getReturnValue();
                console.log('SellerCaseId: ' + sellerCaseId);
                console.log('Review Save: ' + reviewSave);
                if(reviewSave == false) {
                    component.set("v.sellerCaseId", sellerCaseId);
                    this.createDocAttachments(component, event);                        
                }
                
            } else {
                
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("TaxiTransferFormPartA saveForm Error message: " + errors[0].message);
                    }
                } else {
                    console.log("TaxiTransferFormPartA saveForm Unknown error");
                }
            }
        });
        
        $A.enqueueAction(saveAction);
        this.showSpinner(component,event);
    },
    addIndividualPartner : function(component, event) {
        
        var relatedContact = {};
        relatedContact["Title__c"] = '';
        relatedContact["First_Given_Name__c"] = '';
        relatedContact["Family_Name__c"] = '';
        relatedContact["Other_Given_Name__c"] = '';
        relatedContact["Date_of_Birth__c"] = '';
        relatedContact["Australian_Driver_Licence_Number__c"] = '';
        relatedContact["Australian_Driver_Licence_State__c"] = '';
        relatedContact["Contact_Type__c"] = 'Individual Beneficiary';
        
        var jointHoldersIndividualPartners = component.get('v.jointHoldersIndividualPartners');
        
        if(jointHoldersIndividualPartners.length == 0) {
            jointHoldersIndividualPartners = [];
        }
        
        jointHoldersIndividualPartners.push(relatedContact);
        component.set("v.jointHoldersIndividualPartners", jointHoldersIndividualPartners);
    },
    addCorporatePartner : function(component, event) {
        
        var relatedContact = {};
        relatedContact["Corporation_Name__c"] = '';
        relatedContact["ACN__c"] =  '';
        relatedContact["Contact_Type__c"] = 'Corporate Beneficiary';
        
        var jointHoldersCorporatePartners = component.get('v.jointHoldersCorporatePartners');
        
        if(jointHoldersCorporatePartners.length == 0) {
            jointHoldersCorporatePartners = [];
        }
        
        jointHoldersCorporatePartners.push(relatedContact);
        component.set("v.jointHoldersCorporatePartners", jointHoldersCorporatePartners);
    },
    removeIndividualPartner : function (component, event, index){     
        
        var individualPartners = component.get('v.jointHoldersIndividualPartners');
        
        var modifiedArray = [];
        for(var i = 0; i < individualPartners.length; i++) {
            
            if(i != index) {
                modifiedArray.push(individualPartners[i]);
            }
        }
        
        component.set("v.jointHoldersIndividualPartners", modifiedArray);
    },
    removeCorporatePartner : function (component, event, index){     
        
        var corporatePartners = component.get('v.jointHoldersCorporatePartners');
        
        var modifiedArray = [];
        for(var i = 0; i < corporatePartners.length; i++) {
            
            if(i != index) {
                modifiedArray.push(corporatePartners[i]);
            }
        }
        
        component.set("v.jointHoldersCorporatePartners", modifiedArray);
    },
    performBlankInputCheck: function(component,event) {
        
        this.resetErrorMessages(component,event);
        
        var hasRequiredInputsMissing = false;
        
        if(this.validateBlankInputs(component, event, "Transfer-Reason-Input", "transferReason"))
            hasRequiredInputsMissing = true;
         
        if(this.validateBlankInputs(component, event, "Transfer-Price-Input", "transferPrice")){
            hasRequiredInputsMissing = true;
        }
        else if(this.validateNumberInputs(component, event, "Transfer-Price-Input", "transferPrice")){
            hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankRadioInputs(component, event, "buyerTypeError", "buyerType"))
            hasRequiredInputsMissing = true;
        
        if(component.get("v.buyerType") == "Individual") {
            
            component.find("individualPartnerForm").validateFormData();
            if(component.find("individualPartnerForm").get("v.isValidFormData") == false)
                hasRequiredInputsMissing = true;
        }
        else if(component.get("v.buyerType" ) == "Corporation") {
            
            component.find("corporatePartnerForm").validateFormData();
            if(component.find("corporatePartnerForm").get("v.isValidFormData") == false)
                hasRequiredInputsMissing = true;
        } 
            else if(component.get("v.buyerType" ) == "Joint-Holders") {
                
                var individualPartners = component.get('v.jointHoldersIndividualPartners');
                var corporatePartners = component.get('v.jointHoldersCorporatePartners');
                
                if (individualPartners.length == 0 && corporatePartners.length == 0) {
                    
                    hasRequiredInputsMissing = true;
                    
                    document.getElementById("buyerTypeJointHoldersError").innerHTML = "Please enter details of at least one Joint Holder.";
                    document.getElementById("buyerTypeJointHoldersError").style.display = 'block';
                    document.querySelector("buyerTypeJointHoldersError").scrollIntoView();
                }
                else {
                    for(var index = 0; index < individualPartners.length; index++) {
                        
                        var individualPartnerForm = this.findInputField(component, "jointHoldersIndividualPartnerForm", index);
                        individualPartnerForm.validateFormData();
                        if(individualPartnerForm.get("v.isValidFormData") == false)
                            hasRequiredInputsMissing = true;
                    }
                    
                    for(var index = 0; index < corporatePartners.length; index++) {
                        
                        var corporatePartnerForm = this.findInputField(component, "jointHoldersCorporatePartnerForm", index);
                        corporatePartnerForm.validateFormData();
                        if(corporatePartnerForm.get("v.isValidFormData") == false)
                            hasRequiredInputsMissing = true;
                    }
                }
                
            }
        
        component.find("Transferee-Email-Input").verifyEmail();
        component.find("Transferee-daytimePhoneNumber").verifyPhone(); 
        console.log('Email is valid: ' + component.find("Transferee-Email-Input").get("v.isValid"));
        console.log('daytimePhoneNumber is valid: ' + component.find("Transferee-daytimePhoneNumber").get("v.isValid"));
        if(component.find("Transferee-Email-Input").get("v.isValid") == false || component.find("Transferee-daytimePhoneNumber").get("v.isValid") == false) {	
            hasRequiredInputsMissing = true;
        }
        console.log(component.get("v.email"));
        console.log(component.get("v.daytimePhone"));
        if((component.get("v.email") == undefined || component.get("v.email") == "") ) {
            console.log('email is not provided');
            hasRequiredInputsMissing = true;
            component.find("Transferee-Email-Input").displayError('Please provide email address of transferee');
            
        } else {
            component.find("Transferee-Email-Input").resetError();
        }
        if((component.get("v.daytimePhone") == undefined || component.get("v.daytimePhone") == "")) {
            console.log('daytime phone is not provided');
            hasRequiredInputsMissing = true;
            component.find("Transferee-daytimePhoneNumber").displayError('Please provide daytime phone number of transferee');
            
        } else {
            component.find("Transferee-daytimePhoneNumber").resetError();
        }
        if(component.find("seller-poi-Upload").get("v.FileUploadChecked") == false) {
            component.find("seller-poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.sellerPOIUploadStatus") == false){
            console.log('seller poi document not uploaded');
            component.find("seller-poi-Upload").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        if(component.find("transfer-sale-contract").get("v.FileUploadChecked") == false) {
            component.find("transfer-sale-contract").setValidationError();
            hasRequiredInputsMissing = true;
        }
        if(component.get("v.contractUploadStatus") == false){
            console.log('transfer sale document not uploaded');
            component.find("transfer-sale-contract").setValidationError();
            hasRequiredInputsMissing = true;
        }
        
        
        
        return hasRequiredInputsMissing;
        
    },
    resetErrorMessages : function(component, event) {
        
        component.find("Transfer-Reason-Input").set("v.errors", null);
        component.find("Transfer-Price-Input").set("v.errors", null);
        
        document.getElementById("buyerTypeError").innerHTML = '';
        document.getElementById("buyerTypeError").style.display = 'none';
        document.getElementById("buyerTypeJointHoldersError").innerHTML = '';
        document.getElementById("buyerTypeJointHoldersError").style.display = 'none';
        
        if(component.get("v.buyerType") == "Individual") {
            
            component.find("individualPartnerForm").resetErrorMessages();
        }
        else if(component.get("v.buyerType" ) == "Corporation") {
            
            component.find("corporatePartnerForm").resetErrorMessages();
        } 
            else if(component.get("v.buyerType" ) == "Joint-Holders") {
                
                var individualPartners = component.get('v.jointHoldersIndividualPartners');
                var corporatePartners = component.get('v.jointHoldersCorporatePartners');
                
                for(var index = 0; index < individualPartners.length; index++) {
                    
                    var individualPartnerForm = this.findInputField(component, "jointHoldersIndividualPartnerForm", index);
                    individualPartnerForm.resetErrorMessages();
                }
                
                for(var index = 0; index < corporatePartners.length; index++) {
                    
                    var corporatePartnerForm = this.findInputField(component, "jointHoldersCorporatePartnerForm", index);
                    corporatePartnerForm.resetErrorMessages();
                }
            }
    },
    findInputField : function (component, inputId, index){
        
        var inputField;
        var inputFields = component.find(inputId);	
        
        if( Object.prototype.toString.call(inputFields) === '[object Array]') {
            inputField = inputFields[index];
        }
        else{
            inputField = inputFields;
        }
        
        return inputField;
    },
    validateBlankInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            
            component.find(""+inputId).set("v.errors", null);
        }
        
        return false;
    },
    validateBlankRadioInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        
        if(inputValue == undefined) {
            
            document.getElementById(inputId).innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == 'Corporation' || inputValue == 'Individual' || inputValue == 'Joint-Holders'){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        
        return false;
    },
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    toggleSectionContent : function(component, event) {
        
        var toggleText = component.find("sectiontitle");
        var isSectionExpanded = component.get("v.isSectionExpanded");
        
        if(!isSectionExpanded){
            $A.util.addClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",true);
        }else{
            $A.util.removeClass(toggleText, 'slds-is-open');
            component.set("v.isSectionExpanded",false);
        }
    },
    
    createDocAttachments : function(component, event){
        console.log('creating attachments');
        this.showSpinner(component,event);
        var action = component.get("c.createAttachments");
        var attachIds = [];
        attachIds.push(component.get("v.saleDocId"));
        attachIds.push(component.get("v.poiDocId"));
        console.log('attachment ids');
        console.log(attachIds);
        action.setParams({"attachIds" : attachIds, "applicationId" : component.get("v.sellerCaseId")});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {                
                this.hideSpinner(component,event);                
                var nextSectionEvent = component.getEvent("loadSection");
                nextSectionEvent.setParams({"sectionName": "sectionB", "existingLicence" : component.get("v.existingLicence"), "sellerCaseId" : component.get("v.sellerCaseId"), "isInternalUser" : component.get("v.isInternalUser")});
                nextSectionEvent.fire();                
            } else {
                var errors = response.getError();
                console.log(errors);
            }
        });
        
        $A.enqueueAction(action);
        
    },
    validateNumberInputs : function(component, event, inputId, attributeName) {
        
        var inputValue = component.get('v.'+attributeName);
        var numberExpression = /[^0-9.]/g; 
        console.log('In validateNumberInputs:');
        console.log(inputValue);
        console.log(inputValue.match(numberExpression));
        if(inputValue && inputValue.match(numberExpression)){
        	console.log('Invalid Price entered');    
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.ERRMSG_INVALID_PRICE")}]);
            return true;
        }
        else {
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    }
})