({
    loadSectionData : function(component, event) {
        
        console.log('in helper');
        
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
                console.log(sectionData["Id"]);
                
                component.set('v.aspCase', sectionData);
                
                //load data
                component.set('v.tenderNumber', sectionData["Tender_Number__c"]); 
                console.log('tender number: ' + component.get('v.tenderNumber'));
                component.set('v.licenceFeeDue',sectionData["Licence_Fee_Due__c"]);
                
                component.set('v.noticeEmail', sectionData["Notice_Email__c"]);
                component.set('v.noticeStreet', sectionData["Notice_Address_Street__c"]);
                component.set('v.noticeCity', sectionData["Notice_Address_City__c"]);
                component.set('v.noticePostcode', sectionData["Notice_Address_Postal_Code__c"]);
                component.set('v.noticeState', sectionData["Notice_Address_State__c"]);
                
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Email")
                    component.set("v.noticeType", "Email");  
                
                if(sectionData["Preferred_method_of_comm_for_notice__c"] == "Notice Address")
                    component.set("v.noticeType", "Postal");  
                
                component.set('v.tenderBidNumber', sectionData["Tender_Bid_Number__c"]); 
                var contact = sectionData["Contact"];
                if (contact != undefined) {
                    component.set('v.selectedContact', contact);
                    if (component.find("Contact-Name")) {
                        component.find("Contact-Name").set("v.selectedRecord", contact);
                        component.find("Contact-Name").reInit();
                    }
                }

                this.hideSpinner(component, event); 
            }
        });
        
        $A.enqueueAction(action);
        
        var licenceAction = component.get("c.getLicenceDetails");
        licenceAction.setParams({
            "caseId": caseid
        });
        
        licenceAction.setCallback(this, function(response) {            
            var state = response.getState();
            
            if(state === "SUCCESS") {                
                var licenceData = JSON.parse(response.getReturnValue());
                console.log('licence details');
                console.log(licenceData);
                
                if(licenceData != null) {
                    
                    component.set('v.licenceTerm', licenceData["Licence_Type__c"]);
                    component.set('v.licenceClass', licenceData["Licence_Class__c"]);
                    component.set('v.operationArea', licenceData["Operation_Area__c"]);
                    component.set('v.operatingLocation', licenceData["Operating_Locations__c"]);
                    component.set('v.platePickupLocation', licenceData["SNSW_Plate_Pickup_Location__c"]);
                    
                    console.log('Calling Filter Plates');
                    
                    this.filterPlatePickupLocations(component, event);
                }
                
                this.hideSpinner(component, event); 
            }
        });
        if(caseid != undefined && caseid != null && caseid != ''){
        	$A.enqueueAction(licenceAction);    
        }
        
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
                    component.set("v.licenceConditions", response.getReturnValue());   
                    
                    var conditions = component.get("v.licenceConditions");
                    if(component.get("v.readOnly")) {
                      
                        conditions.pop();
                        component.set("v.licenceConditions", conditions);   
                    }
                } 
                
            }else{
                
                console.log(state);
            }
            
            this.hideSpinner(component, event); 
        });
        
        $A.enqueueAction(conditonAction);
    },
    saveSectionData : function(component, event, reviewSave) {
        
        this.showSpinner(component, event); 
        
        var sectionData = component.get('v.aspCase');
        
        console.log(sectionData);
        console.log(sectionData["Id"]);
        
        sectionData["Tender_Number__c"] = component.get('v.tenderNumber');
        sectionData["Licence_Type__c"] = component.get('v.licenceTerm');
        sectionData["Licence_Class__c"] = component.get('v.licenceClass');
        sectionData["Operation_Area__c"] = component.get('v.operationArea');
        sectionData["Operating_Locations__c"] = component.get('v.operatingLocation');
        sectionData["SNSW_Plate_Pickup_Location__c"] = component.get('v.platePickupLocation');
        sectionData["Application_Fee_Due__c"] = component.get('v.applicationFeeDue');
        sectionData["Licence_Fee_Due__c"] = component.get('v.licenceFeeDue');
        
        sectionData["Notice_Address_Street__c"] = component.get('v.noticeStreet');
        sectionData["Notice_Address_City__c"] = component.get('v.noticeCity');
        sectionData["Notice_Address_State__c"] = component.get('v.noticeState');
        sectionData["Notice_Address_Postal_Code__c"] = component.get('v.noticePostcode');
        
        sectionData["Notice_Email__c"] = component.get('v.noticeEmail'); 
        
        if(component.get("v.noticeType") == "Email")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Email";  
        
        if(component.get("v.noticeType") == "Postal")
            sectionData["Preferred_method_of_comm_for_notice__c"] = "Notice Address";
        
        sectionData["Tender_Bid_Number__c"] = component.get('v.tenderBidNumber');

        var selectedCont = component.get('v.selectedContact');
        sectionData["ContactId"] = selectedCont.Id;    
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
                console.log("Auth Id: "+component.get("v.authorisationId"));
                
                if(component.get("v.authorisationId") == '' || component.get("v.authorisationId") == undefined) {
                    
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
                            this.saveConditions(component, event);
                            
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
                                
                                component.set("v.entityType", "Individual"); 
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
                }
                else {
                    
                    this.hideSpinner(component, event);
                    this.saveConditions(component, event);
                    
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
                        
                        component.set("v.entityType", "Individual"); 
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
    saveConditions : function(component, event) {
        
        this.showSpinner(component, event);
        var licenceConditions = component.get('v.licenceConditions');
        
        console.log(licenceConditions);
        var selectedLicenceConditions = [];
        var unSelectedLicenceConditions = [];
        
        for(var index = 0; index < licenceConditions.length; index++) {
            
            console.log(licenceConditions[index]);
            var element = document.getElementById(index);
            console.log('element: ' + element);
            
            licenceConditions[index]["Authority__c"] = component.get("v.authorisationId");
            
            if(element) {
                
                console.log('Checked: ' + element.checked);
                console.log('Elem: ' + licenceConditions[index]["Condition_Details__c"]);
                console.log('Master: ' + licenceConditions[index]["Master_Condition__c"]);
                
                if(element.checked && licenceConditions[index]["Master_Condition__c"] == null) {
                    
                    if(licenceConditions[index]["Condition_Details__c"] != '') {                        
                        selectedLicenceConditions.push(licenceConditions[index]);
                    }
                }
                else if(element.checked && licenceConditions[index]["Master_Condition__c"] != null) {
                    
                    selectedLicenceConditions.push(licenceConditions[index]);
                }
                    else if(licenceConditions[index]["Id"] != undefined){
                        
                        unSelectedLicenceConditions.push(licenceConditions[index]);
                    }                
            }            
        }
        
        
        console.log(selectedLicenceConditions);
        console.log(unSelectedLicenceConditions);
        console.log(licenceConditions);
        var action = component.get('c.attachConditions');
        action.setParams({
            "unSelectedConditions" : JSON.stringify(unSelectedLicenceConditions), "selectedConditions" : JSON.stringify(selectedLicenceConditions)
        });
        
        action.setCallback(this, function(response){
            
            var state =  response.getState();
            
            if(state == 'SUCCESS') {
                
                console.log(state);  
                
            } else if (state === "ERROR"){
                
                var errors = response.getError();
                if (errors){
                    
                    if (errors[0] && errors[0].message){  
                        console.log("Error message: " +errors[0].message);
                        console.log(errors);
                    }
                } else{
                    
                    console.log("Unknown error");
                }
            }  
            
            this.hideSpinner(component, event);
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

        if (this.validateBlankInputs(component, event, "Tender-Number", "tenderNumber"))
            hasRequiredInputsMissing = true;

        if (this.validateBlankInputs(component, event, "Licence-Fee-Due", "licenceFeeDue"))
            hasRequiredInputsMissing = true;

        if(this.validateBlankInputs(component, event, "Licence-Term-Input", "licenceTerm"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "Licence-Class-Input", "licenceClass"))
            hasRequiredInputsMissing = true;
        
        component.find("Notice-Email").verifyEmail(); 
        if(component.find("Notice-Email").get("v.isValid") == false)
            hasRequiredInputsMissing = true;
        
        component.find("Notice-Address").validateAddress();
        if(!component.find("Notice-Address").get("v.isValidAddress"))
            hasRequiredInputsMissing = true;
        
        if (this.validateBlankInputs(component, event, "Tender-Bid-Number", "tenderBidNumber"))
            hasRequiredInputsMissing = true;

        var contactRec = component.get('v.selectedContact');
        var contactRecId = contactRec.Id;
        
        if(!contactRecId){
            hasRequiredInputsMissing = true;
            console.log(hasRequiredInputsMissing);
            $A.util.addClass(component.find('Contact-Name'), 'slds-has-error');
            component.set("v.contactLookupValidationError", true);
        }

        var licenceConditions = component.get('v.licenceConditions');
        console.log(licenceConditions);
        
        for(var index = 0; index < licenceConditions.length; index++) {
            
            console.log(licenceConditions[index]);
            var element = document.getElementById(index);
            console.log('element: ' + element);
            
            licenceConditions[index]["Authority__c"] = component.get("v.authorisationId");
            
            if(element) {
                
                console.log('Checked: ' + element.checked);
                console.log('Elem: ' + licenceConditions[index]["Condition_Details__c"]);
                console.log('Master: ' + licenceConditions[index]["Master_Condition__c"]);
                if(licenceConditions[index]["Master_Condition__c"] == undefined
                   || licenceConditions[index]["Master_Condition__c"] == null) {
                    
                    console.log('Index is: '+index);
                    document.getElementsByClassName("required_input_"+index)[0].innerHTML = "";
                    //document.getElementsByClassName("condition_detail_error_"+index)[0].className = document.getElementsByClassName("condition_detail_error_"+index)[0].className.replace(new RegExp('(?:^|\\s)'+'has-error'+'(?:\\s|$)'), ' ');
                }
                
                if(element.checked && 
                   (licenceConditions[index]["Master_Condition__c"] == null 
                    || licenceConditions[index]["Master_Condition__c"] == undefined)) {
                    
                    if(licenceConditions[index]["Condition_Details__c"] == '') {                        
                        
                        hasRequiredInputsMissing = true;
                        document.getElementsByClassName("required_input_"+index)[0].innerHTML = "Required input";
                        //document.getElementsByClassName("condition_detail_error_"+index)[0].className = document.getElementsByClassName("condition_detail_error_"+index)[0].className + ' has-error';
                    }
                }
            }
        }
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        console.log('Reset Started');
        
        component.find("Tender-Number").set("v.errors", null);
        component.find("Licence-Fee-Due").set("v.errors", null);
        component.find("Licence-Term-Input").set("v.errors", null);
        component.find("Licence-Class-Input").set("v.errors", null);
        $A.util.removeClass(component.find('Contact-Name'), 'slds-has-error');
        component.set("v.contactLookupValidationError", false);
        console.log('Reset Started');
        
        console.log('Reset Done');
    },
    filterPlatePickupLocations : function(component, event){
        
        console.log('In Helper @@@@@@@@@@@@ : '+component.get('v.platePickupLocation'));
        
        var specifiedPickupLocation = component.get('v.platePickupLocation');
        
        this.showSpinner(component, event);
        
        if(component.get("v.operationArea") == 'Metropolitan Transport District (Sydney)') {
            
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
              
               if(masterPlatePickupList[i] != 'Silverwater Driver Test Centre'){
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