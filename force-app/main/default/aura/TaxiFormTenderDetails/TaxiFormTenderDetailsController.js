({
    doInit : function(component, event, helper) {
        
        console.log('In Tender Doint 2'+component.get("v.isFromPortal"));
        
        helper.showSpinner(component, event);
        
        var plateValueAction = component.get("c.getPlateLocations");
        var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
        var platePickupOpts = [];
        var masterPlatePickupList = [];
        platePickupOpts.push({"class": "optionClass", label: "Please Select", value: ""});
        plateValueAction.setCallback(this, function(a) {
            
            console.log('PLate Pickup Length: '+a.getReturnValue());
            
            for(var i=0;i< a.getReturnValue().length;i++){
                platePickupOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                masterPlatePickupList.push(a.getReturnValue()[i]);
            }
            platePickUpInputsel.set("v.options", platePickupOpts);
            component.set("v.masterPlatePickupLocationList", masterPlatePickupList);
            helper.hideSpinner(component, event);
        });
        $A.enqueueAction(plateValueAction);
        
        var operatingLocationValueAction = component.get("c.getOperatingLocations");
        var operatingLocationInputsel = component.find("Operating-Location-Input");
        var operatingLocationOpts = [];
        operatingLocationOpts.push({"class": "optionClass", label: "Please Select", value: ""})
        operatingLocationValueAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                operatingLocationOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            operatingLocationInputsel.set("v.options", operatingLocationOpts);
            helper.hideSpinner(component, event);
        });
        $A.enqueueAction(operatingLocationValueAction);
        
        var operationAreaValueAction = component.get("c.getOperationAreas");
        var OperationAreaInputsel = component.find("Operation-Area-Input");
        var OperationAreaOpts = [];
        OperationAreaOpts.push({"class": "optionClass", label: "Please Select", value: ""})
        operationAreaValueAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                OperationAreaOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            OperationAreaInputsel.set("v.options", OperationAreaOpts);
            helper.hideSpinner(component, event);
        });
        $A.enqueueAction(operationAreaValueAction);
        
        var licenceClassValueAction = component.get("c.getLicenceClassValues");
        var LicenceClassInputsel = component.find("Licence-Class-Input");
        var LicenceClassOpts = [];
        LicenceClassOpts.push({"class": "optionClass", label: "Please Select", value: ""})
        licenceClassValueAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                LicenceClassOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            LicenceClassInputsel.set("v.options", LicenceClassOpts);
            helper.hideSpinner(component, event);
        });
        $A.enqueueAction(licenceClassValueAction);
        
        var licenceTypeValueAction = component.get("c.getLicenceTypes");
        var licenseTermInputsel = component.find("Licence-Term-Input");
        var licenceTermOpts = [];
        licenceTermOpts.push({"class": "optionClass", label: "Please Select", value: ""})
        licenceTypeValueAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                licenceTermOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
            }
            licenseTermInputsel.set("v.options", licenceTermOpts);
            
        });
        $A.enqueueAction(licenceTypeValueAction);
        
        helper.toggleSectionContent(component, event);
        
        if(component.get("v.accountId") != undefined)
            helper.loadSectionData(component, event, helper); 
        
        if(component.get("v.isFromPortal"))
            helper.loadSectionData(component, event, helper); 
        
    },
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('Account Id Con: '+component.get("v.accountId"));
        console.log('Is From Portal: '+component.get("v.isFromPortal"));
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
            helper.loadSectionData(component, event, helper); 
    },
    closeApplication : function(component, event, helper) {
        
        console.log('Close Called');
        if(component.get("v.isFromPortal"))
            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
        else    
            component.getEvent("closeApplication").fire();
    },
    renderNextSection : function(component, event, helper) {
        
        var inputzero = component.find("Licence-Fee-Due");
        var value = inputzero.get("v.value");
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            // is input 0?
            if (value == 0) {
                inputzero.set("v.errors", [{message: $A.get("$Label.c.Licence_Fee_Due_can_not_be_0")}]);
            }
            else {
            
                document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
                helper.saveSectionData(component, event, false);
            }
        }
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        //$("#formPartA .slds-has-error").removeClass("slds-has-error");
        //$("#formPartA .slds-form-element__help").hide();
        document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        helper.resetErrorMessages(component, event);
        helper.loadSectionData(component, event);
    },
    saveReviewChanges : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            component.set("v.readOnly", true);
            component.set("v.reviewEdit", false);
            helper.saveSectionData(component, event, true);
        }
    },
    setNoticeAddressType : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        console.log("Selected"+selected);
        if(selected == "r1"){
            
            component.set("v.noticeType", "Postal");
        }
        if(selected == "r0"){
            
            component.set("v.noticeType", "Email");	
        }
    },
    addCondition : function(component, event, helper){
        
        var condition = {};
        condition["Condition_Details__c"] = '';
        condition["Authority__c"] = component.get('v.authorisationId');
        condition["Master_Condition__c"] = null;
        
        var existingConditions = component.get('v.licenceConditions');
        console.log(existingConditions);
        existingConditions.push(condition);
        
        component.set('v.licenceConditions', existingConditions);
    },
    filterPlateLocations : function(component, event, helper){
        
        helper.filterPlatePickupLocations(component, event, helper);
    }
})