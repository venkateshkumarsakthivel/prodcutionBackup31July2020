({
    fetchAccountDetails : function(component, event) {
        
        var action = component.get("c.getAccountDetails");
        
        action.setCallback(this, function(response) {
            
            console.log(response.getState());
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var acc = response.getReturnValue();
                component.set("v.acc", acc);   
            } 
            else {
                console.log('Response Error: '+ state);
            }
        });
        
        $A.enqueueAction(action);
    },
    validateReturnAction : function(component, event) {
        
        this.showSpinner(component, event);
        
        // Get logged in User account authorisations. 
        var getAccountAuthorisationsAction = component.get("c.getAccountAuthorisations");
        getAccountAuthorisationsAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var authorisations = response.getReturnValue();
                
                console.log(response.getReturnValue());
                
                console.log("Auth List: "+authorisations);
                console.log(authorisations);
                
                if(authorisations != null && authorisations.length == 0) {
                    
                    component.set("v.preventLevyReturn", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Levy_Return_No_Active_Authorisations"));
                }
                else {
                    
                    component.set("v.authorisations", authorisations);
                    
                    for(var i=0;i<authorisations.length;i++) {
                        
                        if(authorisations[i].Authorisation_Type__c == 'BSP')
                            component.set("v.bspAuth", authorisations[i]);
                        
                        if(authorisations[i].Authorisation_Type__c == 'TSP')
                            component.set("v.tspAuth", authorisations[i]);
                    }
                    
                    this.validateActiveRegistration(component, event);
                }
            }
        });
        $A.enqueueAction(getAccountAuthorisationsAction);
    },
    validateActiveRegistration : function(component, event) {
        
        this.showSpinner(component, event);
        //validate if account has active registrations
        var activeRegistrationAction = component.get("c.getTaxPayerRegistrationDetails");
        activeRegistrationAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var fetchedRecord = response.getReturnValue();
                console.log(fetchedRecord);
                
                if(fetchedRecord != null) {
                    
                    component.set("v.tax_Payer_Reg", fetchedRecord);
                    
                    //if trip count > 600 then no exemption and rebate check needed, allow return of levy
                    if(fetchedRecord.Annual_Trip_Estimate__c == 'Over 600' 
                       || (fetchedRecord.Applied_For_Rebate__c != undefined && fetchedRecord.Applied_For_Rebate__c == 'No')
                       || (fetchedRecord.Applied_For_Exemption__c != undefined && fetchedRecord.Applied_For_Exemption__c == 'No')) {
                        
                        component.set("v.hasAppliedForRebate", false);
                        this.fetchAssessmentDetails(component, event);
                        return;
                    }
                    
                    //if applied for exemption and request is approved
                    if(fetchedRecord.Applied_For_Exemption__c != undefined && fetchedRecord.Applied_For_Exemption__c == 'Yes' && fetchedRecord.Exemption_Approved__c) {
                        
                        var exemptionApprovalDate = fetchedRecord.Exemption_Approval_Date__c;
                        console.log('exemptionApprovalDate -->'+exemptionApprovalDate);
                        
                        var exemptionAppDate = new Date(exemptionApprovalDate);
                        var dateForApprovedExemption = new Date(exemptionAppDate.getFullYear(), exemptionAppDate.getMonth() + 1, 0);
                        console.log('dateForApprovedExemption '+dateForApprovedExemption);
                        
                        var currentDate = new Date();
                        var returnDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0);
                        console.log('returnDate '+returnDate);
                        
                        if(returnDate.getFullYear() == dateForApprovedExemption.getFullYear()
                            && returnDate.getMonth() == dateForApprovedExemption.getMonth()){
                            
                            this.fetchAssessmentDetails(component, event);
                        }
                        else{
                            
                            component.set("v.preventLevyReturn", true);
                            component.set("v.errorMsg", $A.get("$Label.c.Levy_Return_Approved_Exemption"));
                            return;
                        }
                    }
                    else if(fetchedRecord.Applied_For_Exemption__c != undefined && fetchedRecord.Applied_For_Exemption__c == 'Yes' && fetchedRecord.Exemption_Approved__c == false) {
                        
                        this.fetchAssessmentDetails(component, event);
                    }
                    
                    //if applied for rebate and request is approved
                    if(fetchedRecord.Applied_For_Rebate__c != undefined && fetchedRecord.Applied_For_Rebate__c == 'Yes' && fetchedRecord.Rebate_Approved__c) {
                        
                        component.set("v.hasAppliedForRebate", true);
                        
                        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        
                        console.log(fetchedRecord.Rebate_Approval_Date__c);
                        
                        var rebateApprovalDate = new Date(fetchedRecord.Rebate_Approval_Date__c);
                        var currentDate = new Date();
                        
                        console.log('Rebate Approval Month: '+rebateApprovalDate.getMonth());
                        console.log('Current Month: '+currentDate.getMonth());
                        
                        console.log('Rebate Approval Year: '+rebateApprovalDate.getFullYear());
                        console.log('Current Year: '+currentDate.getFullYear());
                        
                        var dateForApprovedRebate = new Date(rebateApprovalDate.getFullYear(), rebateApprovalDate.getMonth() + 1, 0);
                        console.log('dateForApprovedRebate '+dateForApprovedRebate);
                        
                        var returnDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), 0);
                        console.log('returnDate '+returnDate); 

                        //current date is greater than approval date and return is not in anniversary month
                        if(currentDate.getFullYear() > rebateApprovalDate.getFullYear()
                           && currentDate.getMonth() != rebateApprovalDate.getMonth()) {
                            
                            if(returnDate.getFullYear() == dateForApprovedRebate.getFullYear()
                            && returnDate.getMonth() == dateForApprovedRebate.getMonth()){
                                
                                component.set("v.hasAppliedForRebate", false);
                                this.fetchAssessmentDetails(component, event);
                            }
                            else{
                                var targetReturnDate;
                                
                                if(currentDate.getMonth() < rebateApprovalDate.getMonth())
                                    targetReturnDate = months[rebateApprovalDate.getMonth()]+'/'+currentDate.getFullYear();
                                else 
                                    targetReturnDate = months[rebateApprovalDate.getMonth()]+'/'+(currentDate.getFullYear()+1);
                                
                                var updatedErrorMsg = $A.get("$Label.c.Levy_Return_Approved_Rebate");
                                component.set("v.preventLevyReturn", true);
                                component.set("v.errorMsg", updatedErrorMsg.replace('<<MMM/yyyy>>', targetReturnDate)); 
                            }
                        }
                        else if(currentDate.getFullYear() == rebateApprovalDate.getFullYear()) {
                            
                            if(returnDate.getFullYear() == dateForApprovedRebate.getFullYear()
                            && returnDate.getMonth() == dateForApprovedRebate.getMonth()){
                                
                                component.set("v.hasAppliedForRebate", false);
                                this.fetchAssessmentDetails(component, event); 
                            }
                            else {
                                var targetReturnDate;
                                
                                if(currentDate.getMonth() < rebateApprovalDate.getMonth())
                                    targetReturnDate = months[rebateApprovalDate.getMonth()]+'/'+currentDate.getFullYear();
                                else 
                                    targetReturnDate = months[rebateApprovalDate.getMonth()]+'/'+(currentDate.getFullYear()+1);
                                
                                var updatedErrorMsg = $A.get("$Label.c.Levy_Return_Approved_Rebate");
                                component.set("v.preventLevyReturn", true);
                                component.set("v.errorMsg", updatedErrorMsg.replace('<<MMM/yyyy>>', targetReturnDate)); 
                            }
                        }
                            else {
                                
                                this.fetchAssessmentDetails(component, event);
                            }
                    }
                    else if(fetchedRecord.Applied_For_Rebate__c != undefined && fetchedRecord.Applied_For_Rebate__c == 'Yes' && fetchedRecord.Rebate_Rejected__c) {
                        
                        this.fetchAssessmentDetails(component, event);
                    }
                        else if(fetchedRecord.Applied_For_Rebate__c != undefined && fetchedRecord.Applied_For_Rebate__c == 'Yes' && fetchedRecord.Rebate_Approved__c == false && fetchedRecord.Rebate_Rejected__c == false) {
                            /*
                        console.log('Rebate request is not approved:');
                        component.set("v.assessmentObj", null);
                        component.set("v.preventLevyReturn", true);
                        component.set("v.errorMsg", $A.get("$Label.c.Levy_Return_No_Open_Assessment")); */
                            this.fetchAssessmentDetails(component, event);
                        }
                    
                    console.log('Done');
                }
                else {
                    
                    component.set("v.tax_Payer_Reg", null);
                    component.set("v.preventLevyReturn", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Levy_Return_No_Active_Registration"));
                }
            }
            else {
                
                console.log('Response Error :'+ state);
            }
        });
        $A.enqueueAction(activeRegistrationAction);
    },
    fetchAssessmentDetails : function(component, event) {
        
        this.showSpinner(component, event);
        
        // Get logged in User account authorisations. 
        var getAccountAssessmentAction = component.get("c.getAssessmentDetails");
        getAccountAssessmentAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var fetchedRecord = response.getReturnValue();
                console.log(fetchedRecord);
                
                if(fetchedRecord != null) {
                    
                    component.set("v.assessmentObj", fetchedRecord);
                    component.set("v.preventLevyReturn", false);
                    
                    if(fetchedRecord.BSP_Transaction_Count__c == undefined && fetchedRecord.TSP_Transaction_Count__c == undefined)
                        component.set("v.readOnly", false);
                    
                    this.checkBSPTSPExistence(component, event);
                    
                    var wasRebateApprovedAction = component.get("c.wasRebateApproved");
                    wasRebateApprovedAction.setParams({ 
                        tempAssessment : component.get("v.assessmentObj")
                    });
                    wasRebateApprovedAction.setCallback(this,function(resp) {
                        
                        var state = resp.getState();           
                        if(state === "SUCCESS") {
                            
                            component.set("v.hasApprovedRebateBeforeLevyEndPeriod", resp.getReturnValue());
                        }
                    });
                    $A.enqueueAction(wasRebateApprovedAction);
                }
                else {
                    
                    console.log('Assessment Object Missing Error: '+ fetchedRecord);
                    component.set("v.assessmentObj", null);
                    component.set("v.preventLevyReturn", true);
                    component.set("v.errorMsg", $A.get("$Label.c.Levy_Return_No_Open_Assessment"));
                }
            }
            else {
                
                console.log('Response Error: '+ state);
            }
        });
        $A.enqueueAction(getAccountAssessmentAction);
    },
    submitLevyReturn : function(component, event) {
        
        this.showSpinner(component, event);
        
        // Get logged in User account authorisations. 
        var submitLevyReturnAction = component.get("c.submitLevyReturn");
        submitLevyReturnAction.setParams({ 
            returnAssessment : component.get("v.assessmentObj")
        });
        submitLevyReturnAction.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                var responseValue = response.getReturnValue();
                if(responseValue) {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.Levy_Return_Submitted_Success"),
                        "type": "success",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    component.set("v.readOnly", true);
                }
                else {
                    
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.Levy_Return_Submitted_Error"),
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire();
                    component.set("v.readOnly", false);
                }
                window.scrollTo(0, 0);
            }
        });
        $A.enqueueAction(submitLevyReturnAction);
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
    validateBlankRadioInputs : function(component, event, inputId, attributeName, msg){
        
        var inputValue = component.get('v.'+attributeName);
        if(inputValue == undefined || inputValue == false){
            
            document.getElementById(inputId).innerHTML = msg;
            document.getElementById(inputId).style.display = 'block';
            return true;
        }
        else if(inputValue == true){
            
            document.getElementById(inputId).innerHTML = '';
            document.getElementById(inputId).style.display = 'none';
        }
        return false;
    },
    performBlankInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasRequiredInputsMissing = false;
        
        if(component.get("v.hadBSP")) {
            
            if(this.validateBlankInputs(component, event, "bspCount", "assessmentObj.BSP_Transaction_Count__c"))
                hasRequiredInputsMissing = true;
            else if(component.get("v.assessmentObj.BSP_Transaction_Count__c") < 0
                    || component.get("v.assessmentObj.BSP_Transaction_Count__c") > $A.get("$Label.c.Levy_Return_Count_Limit")) {
                
                component.find("bspCount").set("v.errors", [{message: "Invalid Value"}]);
                hasRequiredInputsMissing = true;
            }
        }
        
        if(component.get("v.hadTSP")) {
            
            if(this.validateBlankInputs(component, event, "tspCount", "assessmentObj.TSP_Transaction_Count__c"))
                hasRequiredInputsMissing = true;
            else if(component.get("v.assessmentObj.TSP_Transaction_Count__c") < 0
                    || component.get("v.assessmentObj.TSP_Transaction_Count__c") > $A.get("$Label.c.Levy_Return_Count_Limit")) {
                
                component.find("tspCount").set("v.errors", [{message: "Invalid Value"}]);
                hasRequiredInputsMissing = true;
            }
        }
        
        if(this.validateBlankRadioInputs(component, event, "declarationAcceptanceError", "assessmentObj.Privacy_Declaration__c", $A.get("$Label.c.Error_Message_Required_Input")))
            hasRequiredInputsMissing = true;
        
        return hasRequiredInputsMissing;
    },
    resetErrorMessages : function(component, event) {
        
        document.getElementById("declarationAcceptanceError").innerHTML = '';
        
        if(component.get("v.hadBSP"))
            component.find("bspCount").set("v.errors", null);
        
        if(component.get("v.hadTSP"))
            component.find("tspCount").set("v.errors", null);
    },
    checkBSPTSPExistence : function(component, event) {
        
        var checkTSPExistence = component.get("c.hadTSPAuthorisation");
        checkTSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentObj")
        });
        checkTSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD TSP: '+response.getReturnValue());
                component.set("v.hadTSP", response.getReturnValue());
            }
        });
        checkTSPExistence.setBackground();
        $A.enqueueAction(checkTSPExistence);
        
        
        var checkBSPExistence = component.get("c.hadBSPAuthorisation");
        checkBSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentObj")
        });
        checkBSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD BSP: '+response.getReturnValue());
                component.set("v.hadBSP", response.getReturnValue());
            }
        });
        checkBSPExistence.setBackground();
        $A.enqueueAction(checkBSPExistence);
        
    },
    validateSpecifiedBspCount : function(component, event) {
        
        console.log('in Validate BSP Count');
        
        component.find("bspCount").set("v.errors", null);
        var bspCount = component.get("v.assessmentObj.BSP_Transaction_Count__c");
        var hadBSP = component.get("v.hadBSP");
        
        if(bspCount == undefined)
            return;
        
        component.set("v.assessmentObj.BSP_Transaction_Count__c", bspCount);
        
        var bspCountExpression = /^[0-9]{0,16}$/;
        
        if(bspCount && (!bspCountExpression.test(bspCount)) ) {
            
            console.log('Invalid BSP Count');
            component.find("bspCount").set("v.errors", [{message: $A.get("$Label.c.Invalid_input_Please_enter_whole_numbers")}]);
            return true;
        }
        else {
            
            console.log('in Validate BSP Count Return');
            return false;
        }
    },
    validateSpecifiedTspCount : function(component, event) {
        
        console.log('in Validate TSP Count');
        
        component.find("tspCount").set("v.errors", null);
        var tspCount = component.get("v.assessmentObj.TSP_Transaction_Count__c");
        var hadTSP = component.get("v.hadTSP");
        
        if(tspCount == undefined)
            return;
        
        component.set("v.assessmentObj.TSP_Transaction_Count__c", tspCount);
        
        var tspCountExpression = /^[0-9]{0,16}$/;
        
        if(tspCount && (!tspCountExpression.test(tspCount))) {
            
            console.log('Invalid TSP Count');
            component.find("tspCount").set("v.errors", [{message: $A.get("$Label.c.Invalid_input_Please_enter_whole_numbers")}]);
            return true;
        }
        else {
            
            console.log('in Validate TSP Count Return');
            return false;
        }
    },  
    performSpecifiedInputCheck : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        var hasSpecifiedInputsMissing = false;
        
        if(component.get("v.hadBSP")) {
            
            if(this.validateSpecifiedBspCount(component, event, "bspCount", "assessmentObj.BSP_Transaction_Count__c"))
                hasSpecifiedInputsMissing = true;
        }
        
        if(component.get("v.hadTSP")) {
            
            if(this.validateSpecifiedTspCount(component, event, "tspCount", "assessmentObj.TSP_Transaction_Count__c"))
                hasSpecifiedInputsMissing = true;
            
        }   
        return hasSpecifiedInputsMissing;
        
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
    }
})