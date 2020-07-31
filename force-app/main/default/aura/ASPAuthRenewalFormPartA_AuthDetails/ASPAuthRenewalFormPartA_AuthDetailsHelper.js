({
    loadSectionData : function(component, event) {
        
        var caseId = component.get("v.caseId");
        console.log('loadSectionData caseId : ' + caseId);
        
        if(caseId == undefined || caseId == "") {
            
            var accountId = component.get("v.accountId");
            console.log('loadSectionData accountId : ' + accountId);
            
            if(accountId != undefined || accountId != "") {
                
                var getRenewalCaseDetailsAction = component.get("c.getRenewalCaseDetails");
                getRenewalCaseDetailsAction.setParams({
                    "accountId": component.get("v.accountId")
                }); 
                
                getRenewalCaseDetailsAction.setCallback(this,function(response) {
                    
                    console.log('getRenewalCaseDetailsAction callback: ');
                    console.log(response);
                    
                    this.hideSpinner(component, event); 
                    
                    var state = response.getState();
                    
                    if(state === "SUCCESS") {
                        
                        var renewalCaseDetails = JSON.parse(JSON.stringify(response.getReturnValue()));
                        console.log('Got renewalCaseDetails : ' + renewalCaseDetails);
                        
                        if(renewalCaseDetails != null) {
                            component.set("v.caseId", renewalCaseDetails.Id);
                            
                            this.loadAuthRenewalDetails(component, event);
                            
                        }  else {
                            
                            console.log('No Renewal Case !');
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                mode: 'pester',
                                "title" : "Error",
                                message: 'Either Renewal case does not exist or this is not an ASP Account.',
                                type : "error"
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire();
                        }
                    }
                    else{
                        console.log('Error !');
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'pester',
                            "title" : "Error",
                            message: 'Either Renewal case does not exist or this is not an ASP Account.',
                            type : "error"
                        });
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }
                });
                
                $A.enqueueAction(getRenewalCaseDetailsAction);
                this.showSpinner(component, event); 
            } 
        } else {
            this.loadAuthRenewalDetails(component, event);
        }
    },
    loadAuthRenewalDetails : function(component, event) {
        
        var caseId = component.get("v.caseId");
        
        var action = component.get("c.getAuthorisationDetails");
        action.setParams({
            "caseId": caseId
        }); 
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var listAuthorisations = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log(listAuthorisations);
                console.log(listAuthorisations.length);
                
                // List will contains maximum 2 authorisations, TSP and(or) BSP
                for(var index in listAuthorisations) {
                    if(listAuthorisations[index].Authorisation_Type__c === 'TSP') {
                        component.set("v.isTSPAuth", true);
                        component.set("v.tspAuth", listAuthorisations[index]);
                        component.set("v.isTSPAuthSelected", true);
                    } else if(listAuthorisations[index].Authorisation_Type__c === 'BSP') {
                        component.set("v.isBSPAuth", true);
                        component.set("v.bspAuth", listAuthorisations[index]);
                        component.set("v.isBSPAuthSelected", true);
                    }
                }
            }
            else{
                console.log('Error !');
            }
        });
        
        if(caseId != "")
            $A.enqueueAction(action);
        this.showSpinner(component, event); 
        
        var getASPAuthRenewalCaseDataAction = component.get("c.getASPAuthRenewalCaseData");
        getASPAuthRenewalCaseDataAction.setParams({
            "caseId": caseId
        });
        
        getASPAuthRenewalCaseDataAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var caseData = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log(caseData);
                
                var isTSPAuthSelected = caseData["Is_TSP_Auth_Renewal_Request__c"];
                var isBSPAuthSelected = caseData["Is_BSP_Auth_Renewal_Request__c"];
                if(!(isTSPAuthSelected == false && isBSPAuthSelected == false)) {
                    component.set("v.isTSPAuthSelected", isTSPAuthSelected);
                    component.set("v.isBSPAuthSelected", isBSPAuthSelected);
                }
                
                var status = caseData["Status"];
                if(status == 'Lodged') {
                    component.set("v.readOnly", true);
                    component.set("v.withdrawnCase", true);
                }
            }
            else{
                console.log('Error !');
            }
        });
        
        if(caseId != "")
            $A.enqueueAction(getASPAuthRenewalCaseDataAction);
        this.showSpinner(component, event); 
    },
    saveSectionData : function(component, event, finishLater, reviewSave) {
        
        var caseId = component.get("v.caseId");
        var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
        var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
        
        var serviceType = '';
        if(isTSPAuthSelected && isBSPAuthSelected) {
            serviceType = 'Taxi and Booking';
        } else if (isTSPAuthSelected && !isBSPAuthSelected) {
            serviceType = 'Taxi';
        } else if (!isTSPAuthSelected && isBSPAuthSelected) {
            serviceType = 'Booking';
        }
        
        var caseData = {};
        caseData["Id"] = caseId;
        caseData["Is_TSP_Auth_Renewal_Request__c"] = isTSPAuthSelected;
        caseData["Is_BSP_Auth_Renewal_Request__c"] = isBSPAuthSelected;
        caseData["Service_Type__c"] = serviceType;
        
        var action = component.get("c.updateASPAuthRenewalCase");
        action.setParams({
            "caseData": JSON.stringify(caseData),
            "updateStatusToLodged": false
        });
        
        action.setCallback(this,function(response){
            
            this.hideSpinner(component, event); 
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                if(finishLater == false && reviewSave == false) {
                    
                    var caseId = component.get("v.caseId");
                    var isTSPAuthSelected = component.get("v.isTSPAuthSelected");
                    var isBSPAuthSelected = component.get("v.isBSPAuthSelected");
                    
                    var nextSectionEvent = component.getEvent("loadSection");
                    nextSectionEvent.setParams({"sectionName": "sectionB", "caseId" : caseId, "isTSPAuthSelected" : isTSPAuthSelected, "isBSPAuthSelected" : isBSPAuthSelected});
                    nextSectionEvent.fire();
                }
                
                if(reviewSave) {
                    
                    component.set("v.readOnly", true);
                    component.set("v.reviewEdit", false);
                }
            }
        });
        
        $A.enqueueAction(action);
        
        this.showSpinner(component, event); 
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