({
    validateAssessmentCreation : function(component, event) {
        
        var recId = component.get("v.recordId");
        console.log('Got Account Id: '+recId);
        
        this.showSpinner(component, event);
        
        var hasLevyAssessmentAccess = component.get("c.hasLevyAssessmentAccess");
        
        hasLevyAssessmentAccess.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                if(response.getReturnValue() == false) {
                    
                    this.hideSpinner(component, event);
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_No_Create_Assessment_Access"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    
                    var action = component.get("c.getTPRDetails");
                    action.setParams({
                        "accountId": recId
                    });
                    action.setCallback(this, function(response) {
                        
                        this.hideSpinner(component, event);
                        
                        console.log(response.getState());
                        
                        var state = response.getState();
                        if(state === "SUCCESS") {
                            
                            console.log('Got TPR: '+response.getReturnValue());
                            if(response.getReturnValue() != null) {
                                
                                var registrationRecord = response.getReturnValue();
                                component.set("v.registrationRecord", response.getReturnValue());
                                
                                if(registrationRecord["Exemption_Approved__c"] == true) {
                                    var exemptionApprovalDate = new Date(registrationRecord.Exemption_Approval_Date__c);
                                    var currentDate = new Date();
                                    
                                    console.log('Exemption Approval Month: '+exemptionApprovalDate.getMonth());
                                    console.log('Current Month: '+currentDate.getMonth());
                                    
                                    if(currentDate.getMonth() < exemptionApprovalDate.getMonth()){
                                    var toastEvent = $A.get("e.force:showToast");           	
                                    toastEvent.setParams({
                                        "title": "Error",
                                        "message": $A.get("$Label.c.Levy_Assessment_Exempted_From_Levy"),
                                        "type": "error",
                                        "duration": "10000"
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                    }
                                    else{
                                    component.set("v.exemptionApproved", true);
                                    component.set("v.exemptionApprovalDate", registrationRecord["Exemption_Approval_Date__c"]);
                                
                                    }
                                }
                                else if(registrationRecord["Rebate_Approved__c"] == true){
                                    
                                    component.set("v.rebateApproved", true);
                                    component.set("v.rebateApprovalDate", registrationRecord["Rebate_Approval_Date__c"]);
                                }
                            }
                            else {
                                
                                var toastEvent = $A.get("e.force:showToast");           	
                                toastEvent.setParams({
                                    "title": "Error",
                                    "message": $A.get("$Label.c.Levy_New_Assessment_No_TPR"),
                                    "type": "error",
                                    "duration": "10000"
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            }
                        }
                    });
                    $A.enqueueAction(action);
                }
            }
        });
        $A.enqueueAction(hasLevyAssessmentAccess);
        
        
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
    fetchMatchingAssessments : function(component, event, levyStartDate) {
        
        document.querySelector("#matchingAssessmentErrorMsgDiv").style.display = 'none';
        component.set("v.preventReassessmentCreation", false);
        
        var action = component.get("c.retrieveMatchingAssessments");
        action.setParams({
            "levyStartDate": levyStartDate,
            "activeTPR": component.get("v.registrationRecord")
        });
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                
                component.set("v.matchingAssessments", response.getReturnValue());
                
                var fetchedAssessments = response.getReturnValue();
                console.log(fetchedAssessments.length);
                
                if(fetchedAssessments.length > 0) {
                    
                    for(var i=0;i<fetchedAssessments.length;i++) {
                        
                        console.log(fetchedAssessments[i].Status__c);
                        console.log(fetchedAssessments[i]);
                        
                        if(fetchedAssessments[i].Status__c == "Open"
                           || fetchedAssessments[i].Status__c == "Held"
                           || fetchedAssessments[i].Status__c == "Assessed") {
                            
                            component.set("v.preventReassessmentCreation", true);
                        }
                    }
                    
                    if(component.get("v.preventReassessmentCreation") == true) {
                        
                        document.querySelector("#matchingAssessmentErrorMsgDiv").style.display = 'block';
                        document.querySelector("#matchingAssessmentErrorMsgDiv").scrollIntoView();    
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    createAssessmentCase : function(component, event) {
        
        this.showSpinner(component, event);
        
        var action = component.get("c.createCaseRecord");
        action.setParams({
            "levyStartDate": component.get("v.levyStartPeriod"),
            "activeTPR": component.get("v.registrationRecord"),
            "category": component.get("v.assessmentCategory"),
            "reasonCode": component.get("v.assessmentReasonCode"),
            "description": component.get("v.assessmentDescription")
        });
        action.setCallback(this, function(response) {
            
            this.hideSpinner(component, event);
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var caseRec = response.getReturnValue();
                if(caseRec.CaseNumber  != undefined) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "Your request # "+caseRec.CaseNumber +" has been lodged successfully.",
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": caseRec.Id
                    });
                    navEvt.fire();
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": 'Something went wrong, please contact System Administrator for more information.',
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else {
                
                var toastEvent = $A.get("e.force:showToast");           	
                toastEvent.setParams({
                    "title": "Error",
                    "message": 'Something went wrong, please contact System Administrator for more information.',
                    "type": "error",
                    "duration": "10000"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
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
        
        if(this.validateBlankInputs(component, event, "assessmentCategory", "assessmentCategory"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "assessmentReasonCode", "assessmentReasonCode"))
            hasRequiredInputsMissing = true;
        
        if(this.validateBlankInputs(component, event, "assessmentReasonDescription", "assessmentDescription"))
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("assessmentCategory").set("v.errors", null);
        component.find("assessmentReasonCode").set("v.errors", null);
        component.find("assessmentReasonDescription").set("v.errors", null);
    }
})