({
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
    fetchAuthorisations : function(component, event) {
        
        this.showSpinner(component, event);
        
        var accountId = component.get("v.accountId");
        console.log('Got Account Id: '+accountId);
        if(accountId == '') {
            
            var accountAction = component.get('c.getLoggedInUserAccount');        
            accountAction.setCallback(this, function(result) {
                
                var act = JSON.parse(result.getReturnValue());
                component.set('v.accName', act.Name);
                component.set('v.customerNumber', act.Customer_Number__c);
                
                var authAgentMap = component.get('c.getAuthorisationAgentMap');
                authAgentMap.setCallback(this, function(result) {
                    
                    var state = result.getState();
                    
                    if(state === "SUCCESS") {
                        
                        console.log('Auth. Agent Map Fetched Successfully');
                        component.set("v.agentMap", result.getReturnValue());
                    }
                });
                $A.enqueueAction(authAgentMap);
                
                var action = component.get('c.getAuthorisationRecords');
                action.setParams({
                    "requiredAccId": ''
                });
                action.setCallback(this, function(result) {
                    
                    var state = result.getState();
                    
                    if(state === "SUCCESS") {
                        
                        console.log('result of authorisation');
                        
                        var authList = result.getReturnValue();
                        
                        console.log(authList);
                        console.log("lenght----->"+authList.length);
                        component.set('v.entities', authList);
                        component.set("v.authCount",authList.length);
                        
                        var authMap = {};
                        for(var i=0;i<authList.length;i++) {
                            
                            authMap[authList[i].Id] = authList[i];
                        }
                        
                        component.set("v.authorisationMap", authMap);
                        
                        this.hideSpinner(component, event);
                    }
                    else {
                        
                        console.log('Error from server');
                        this.hideSpinner(component, event);
                    }
                });
                
                $A.enqueueAction(action);
            });
            
            $A.enqueueAction(accountAction); 
        }
        else {
            
            var accountAction = component.get('c.getAccountDataForAgents');  
            accountAction.setParams({
                "accId": accountId
            });
            accountAction.setCallback(this, function(result) {
                
                var accResponse = result.getReturnValue();
                
                if(accResponse == $A.get("$Label.c.UNAUTHORISED_ACCESS")) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                else {
                    var act = JSON.parse(accResponse);
                    component.set('v.accName', act.Name);
                    component.set('v.customerNumber', act.Customer_Number__c);
                    
                    var action = component.get('c.getAuthorisationRecords');
                    action.setParams({
                        "requiredAccId": accountId
                    });
                    action.setCallback(this, function(result) {
                        
                        var state = result.getState();
                        
                        if(state === "SUCCESS") {
                            
                            console.log('result of authorisation');
                            
                            var response = result.getReturnValue();
                            console.log(response);
                            
                            if(response == null) {
                                
                                this.hideSpinner(component, event);
                                
                                var toastEvent = $A.get("e.force:showToast");           	
                                toastEvent.setParams({
                                    "title": "Error",
                                    "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                                    "type": "error",
                                    "duration":10000
                                });
                                toastEvent.fire();
                            }
                            else {
                                
                                var authList = response;
                                
                                console.log(authList);
                                component.set('v.entities', authList);
                                
                                var authMap = {};
                                for(var i=0;i<authList.length;i++) {
                                    
                                    authMap[authList[i].Id] = authList[i];
                                }
                                
                                component.set("v.authorisationMap", authMap);
                            } 
                            console.log('result of authorisation');
                            this.hideSpinner(component, event);
                        }
                        else {
                            
                            console.log('Error from server');
                            this.hideSpinner(component, event);
                        }
                    });
                    
                    $A.enqueueAction(action);
                } 
            });
            $A.enqueueAction(accountAction); 
        }
        
        var licenceConfigAction = component.get('c.getTaxiLicenceSettings');        
        licenceConfigAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                var taxiConfigData = JSON.parse(result.getReturnValue());
                var taxiConfigMap = {};
                for(var i=0;i<taxiConfigData.length;i++) {
                    
                    taxiConfigMap[taxiConfigData[i].Licence_Class__c] = taxiConfigData[i];
                }
                component.set("v.taxiLicenceConfigMap", taxiConfigMap);
            }
            else {
                
                console.log('Error from server');
                this.hideSpinner(component, event);
            }
        });
        $A.enqueueAction(licenceConfigAction); 
        
        var licenceCPIAction = component.get('c.getCPIPercentage');        
        licenceCPIAction.setCallback(this, function(result) {
            
            var state = result.getState();
            
            if(state === "SUCCESS") {
                
                var cpi = result.getReturnValue();
                if(cpi != undefined && cpi != null)
                    component.set("v.taxiLicenceCPI", cpi);
            }
            else {
                
                console.log('Error from server');
                this.hideSpinner(component, event);
            }
            
        });
        $A.enqueueAction(licenceCPIAction); 
    },
    
    isTransferable : function(component, event, recordId, status) {
        
        var authMap = component.get("v.authorisationMap");
        var taxiConfigMap = component.get("v.taxiLicenceConfigMap");
        
        if(taxiConfigMap[authMap[recordId]["Licence_Class__c"]] != undefined) {
            
            if(taxiConfigMap[authMap[recordId]["Licence_Class__c"]]["Is_Transferable__c"] == 'Yes') {
                console.log('IsTransferable : ' + 'Yes');    
                return true;
            }
            
        }
        
        console.log('IsTransferable : ' + 'No');   
        return false;
    },
    
    isStatusGranted : function(component,event,status) {
        
        console.log('Status : ' + status);
        
        if(status == 'Granted'){
            return true;
        }
        else {
            return false;
        }
    },
    
    isInternalUser : function(component, event,recordId) {
        
        var userTypeAction = component.get("c.getUserType");
        userTypeAction.setStorable();
        userTypeAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var userType = response.getReturnValue();
                
                console.log('User Type: ' + userType);
                
                if(userType === "Standard") {
                    
                    // Internal User
                    
                    console.log('IsInternalUser : ' + 'Yes');   
                    
                    this.checkExistingTransferApplicationOpen(component, event, recordId);
                    
                } else {
                    
                    console.log('IsInternalUser : ' + 'No');   
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Only taxi licences that have a classification that permits transferring can be selected. Please contact P2P if you need to discuss transferring the selected licence.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                }
                
            }
        });
        
        $A.enqueueAction(userTypeAction);
    },
    checkIsLicenceTransferable : function(component, event, recordId, recordStatus) {
        
        console.log('helper checkIsLicenceTransferable');
        
        if(this.isStatusGranted(component, event, recordStatus)) {
            
            if(this.isTransferable(component, event, recordId, recordStatus)) {
                
                this.checkExistingTransferApplicationOpen(component, event, recordId);
            }
            else {
                
                this.isInternalUser(component, event, recordId);
            }
        }
    },
    checkExistingTransferApplicationOpen : function(component, event, recordId) {
        
        this.showSpinner(component, event);
        
        var action = component.get("c.isExistingTransferApplicationOpen");
        action.setParams({
            "authorisationId": recordId
        });
        action.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            
            var result = response.getReturnValue();
            
            if(result == null) {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": $A.get("$Label.c.UNAUTHORISED_ACCESS"),
                    "type": "error",
                    "duration":10000
                });
                toastEvent.fire();
            }
            else {
                
                var isPreviousTransferApplicationOpen = result;
                
                console.log('IsExistingTransferApplicationOpen : ' + isPreviousTransferApplicationOpen); 
                
                if(isPreviousTransferApplicationOpen) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "A transfer application already exists for this licence. You cannot submit a new application until the existing one is closed. You can review this application under the My Applications tab.",
                        "type": "error",
                        "duration":10000
                    });
                    toastEvent.fire();
                    
                } else {
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/taxi-transfer?id=' + recordId
                    });
                    urlEvent.fire();
                }
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
    fetchEntityType : function(component, event){        
        var entityAction = component.get("c.getEntityType");
        entityAction.setStorable();
        entityAction.setParams({ });
        entityAction.setCallback(this,function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {                
                console.log('Entity Type: ' + response.getReturnValue());
                component.set("v.entityType", response.getReturnValue());                
            }
        });
        
        $A.enqueueAction(entityAction);        
    },
    launchInteralReviewAppForm : function(component, event){
        
        console.log('Launch launchInteralReviewAppForm form');
        var recId;
        var selectedRadioButton = document.getElementsByClassName('radio');
        var recordSelected = false;
        
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                recordSelected = true;
                recId = selectedRadioButton[i].getAttribute("data-RecId");
            }
        }
        
        $A.createComponent(
            "c:InternalReviewApplicationForm",
            {
                "record_Id": recId,
                "portalContextName":"TAXI",
                "sectionNameToRender":"Internal Review Application Detail"
            },
            function(newComponent, status, errorMessage) {
                
                console.log(status);
                //Add the new button to the body array
                if(status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set('v.body',body);
                } else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }  
            }
        );
    },
    deselectRecord : function(){
        var selectedRadioButton = document.getElementsByClassName('radio');
        for (var i=0; i<selectedRadioButton.length; i++) {
            if (selectedRadioButton[i].checked) {
                selectedRadioButton[i].checked = false;
            }
        }
    }    
})