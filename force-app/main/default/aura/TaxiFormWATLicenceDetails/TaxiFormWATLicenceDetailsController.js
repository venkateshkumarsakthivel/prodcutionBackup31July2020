({
    doInit : function(component, event, helper) {
        
        helper.showSpinner(component, event);
        
        if(component.get("v.accountId") != undefined)
            component.set("v.isFromPortal", false);
        
        var plateValueAction = component.get("c.getPlateLocations");
        plateValueAction.setStorable();
        var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
        var platePickupOpts = [];
        var masterPlatePickupList = [];
        platePickupOpts.push({"class": "optionClass", label: "Please Select", value: ""})
        plateValueAction.setCallback(this, function(a) {
            for(var i=0;i< a.getReturnValue().length;i++){
                platePickupOpts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                masterPlatePickupList.push(a.getReturnValue()[i]);
            }
            platePickUpInputsel.set("v.options", platePickupOpts);
            component.set("v.masterPlatePickupLocationList", masterPlatePickupList);
            helper.hideSpinner(component, event);
        });
        $A.enqueueAction(plateValueAction);
        
        var operationAreaValueAction = component.get("c.getOperationAreas");
        operationAreaValueAction.setStorable();
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
        
        helper.loadSectionData(component, event, helper); 
    },
    fetchApplicationDetails : function(component, event, helper) {
        
        console.log('In Fetch Action: '+component.get("v.caseId"));
        
        if(component.get("v.accountId") != undefined)
            component.set("v.isFromPortal", false);
        
        if(component.get("v.accountId") != undefined || component.get("v.caseId") != undefined)
          helper.loadSectionData(component, event, helper); 
    },
    editCurrentSection : function(component, event, helper) {
        
        component.set("v.readOnly", false);
        component.set("v.reviewEdit", true);
    },
    cancelReviewEdit : function(component, event, helper) {
        
        console.log('Cancel Review');
        
        //$("#formPartA .slds-has-error").removeClass("slds-has-error");
        //$("#formPartA .slds-form-element__help").hide();
        document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
        
        component.set("v.readOnly", true);
        component.set("v.reviewEdit", false);
        
        helper.resetErrorMessages(component, event);
        helper.loadSectionData(component, event);
    },
    closeApplication : function(component, event, helper) {
        
        console.log('Close Called');
        if(component.get("v.isFromPortal"))
            window.location = "/taxilicence/s/secure-portal-home?src=homeMenu";
        else    
            component.getEvent("closeApplication").fire();
        
    },
    renderNextSection : function(component, event, helper) {
        
        if(helper.performBlankInputCheck(component, event)) {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#formPartA #generalErrorMsgDiv").scrollIntoView();
            return;
        }
        else {
            
            document.querySelector("#formPartA #generalErrorMsgDiv").style.display = 'none';
            helper.saveSectionData(component, event, false);
        }
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
    toggleSectionContent : function(component, event, helper){
        
        helper.toggleSectionContent(component, event);
    },
    setNoticeAddressType : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        if(selected == "r1"){
            
            component.set("v.noticeType", "Postal");
            component.find("Notice-Email").set("v.isRequired", false); 
        }
        if(selected == "r0"){
            
            component.set("v.noticeType", "Email");	
            component.find("Notice-Email").set("v.isRequired", true); 
            
        }
    },
    filterPlateLocations : function(component, event, helper){
        
        helper.filterPlatePickupLocations(component, event, helper);
    },
    controlExistingPlatesDisplay : function(component, event, helper) {
        
        var selected = event.getSource().getLocalId();
        console.log(selected);
        if(selected == "existingExpiringYes"){
            
            component.set("v.existingExpiringLicence", "Yes");
            
            var platePickUpInputsel = component.find("Plate-Pickup-Location-Input");
            var platePickupOpts = [];
            
            platePickupOpts.push({"class": "optionClass", label: "N/A", value: "Not Applicable"});
            
            platePickUpInputsel.set("v.options", platePickupOpts);
        }
        
        if(selected == "existingExpiringNo"){
         
            component.set("v.existingExpiringPlates", "");
            component.set("v.existingExpiringLicence", "No"); 
            helper.filterPlatePickupLocations(component, event, helper);
        }
    }
})