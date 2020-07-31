({
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
    
    loadFormDetails : function(component, event){
        
        this.showSpinner(component, event);
 
        // if wrapper object is not null then do not load data again
        if(component.get("v.reviewFormWrpObj")){
            var reviewFormWrpObj = component.get("v.reviewFormWrpObj");
                
            var action = component.get("c.getAuthorisationDetails");
            action.setParams({
                "authorisationID"	:reviewFormWrpObj.authorisationRecordID, 
                "portalContextName"	:reviewFormWrpObj.portalContextName
            });
                
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var returnedValue = response.getReturnValue();
                    if(returnedValue.isSuccess){
                        component.set("v.reviewFormWrpObj", returnedValue);
                    }else{
                        var toastEvent = $A.get("e.force:showToast");           	
                        toastEvent.setParams({
                            "title": "Error",
                            "message": "Error occurred processing request. "+returnedValue.message,
                            "type": "error",
                            "duration":10000,
                            "mode": "dismissible" 
                        });
                        toastEvent.fire();
                    }
                }else if(state === "ERROR"){
                    alert('exception occured while loading data');
                }
                this.hideSpinner(component, event);
            });  
            $A.enqueueAction(action);   
            
            this.hideSpinner(component, event);
            return;
        }
        
        var _action;
        if(component.get("v.isConsole") == true){				//opened from console
            console.log('from console');
            _action = component.get("c.getAuthorisationDetailsForAccount");
            _action.setParams({
                "accountID":component.get("v.accountId")
            });
        }else{														//opened from portal            
           _action = component.get("c.getAuthorisationDetails");
            _action.setParams({
                "authorisationID":component.get("v.record_Id"), 
                "portalContextName":component.get("v.portalContextName")
            }); 
        }
        
		_action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedValue = response.getReturnValue();
                if(returnedValue.isSuccess){
                    component.set("v.reviewFormWrpObj", returnedValue);
                    console.log('*11');
                    console.log(component.get("v.reviewFormWrpObj"));
                }else{
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Error occurred processing request. "+returnedValue.message,
                        "type": "error",
                        "duration":10000,
                        "mode": "dismissible" 
                    });
                    toastEvent.fire();
                }
            }else if(state === "ERROR"){
                alert('exception occured while loading data');
            }
            this.hideSpinner(component, event);
        });  
        $A.enqueueAction(_action);              
    },
    
    renderNextSection : function(component, event, closeForm, reviewSave){
    
        this.showSpinner(component, event);
        
        var _action = component.get("c.saveSectionData"); 
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
        var isConsole = component.get("v.isConsole");
        
        if(isConsole == true){
           var authorisationType = internalDetailsWrp.authorisationNumber.Authorisation_Type__c;     	
           if(authorisationType === "BSP" || authorisationType === "TSP"){
               internalDetailsWrp.csObj.Type = 'Service Provider';
           }else{
               internalDetailsWrp.csObj.Type = 'Taxi';
           }  
    
           internalDetailsWrp.authorisationRecordID = internalDetailsWrp.authorisationNumber.Id; 
           internalDetailsWrp.authorisationNumber 	= internalDetailsWrp.authorisationNumber.Name;
	       internalDetailsWrp.isAuthorisationNumberValid = true;
        }
        
        var copyofDecision = component.get("v.copyOfDecision");
        //internalDetailsWrp.csObj.Internal_Review_Copy_of_Decision__c = internalDetailsWrp.decisionCopy;
        // empty the value entered in description if its new case and copy of decision is selected
        if(internalDetailsWrp.decisionCopy == true){
            internalDetailsWrp.csObj.Decision_Description__c = '';
        }
                        
        _action.setParams({"jsonStr":JSON.stringify(internalDetailsWrp)});
        _action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedValue = response.getReturnValue();
                if(returnedValue.isSuccess && returnedValue.csObj.Id && returnedValue.csObj.Id.startsWith("500")){                   
                    component.set("v.reviewFormWrpObj", returnedValue); 
                    
                    // show toast only when finish later is clicked
                    if(closeForm == true) {
                        var toastEvent = $A.get("e.force:showToast");           	
	                    toastEvent.setParams({
	                        "title": "Success",
	                        "message": "Application saved successfully.",
	                        "type": "success",
	                        "duration":10000,
	                        "mode": "dismissible" 
	                    });
	                    toastEvent.fire(); 
	                    var disableModal = component.getEvent("closeInternalReviewModal");
                        disableModal.fire();
                    }if(reviewSave) {
                    
	                    component.set("v.readOnly", true);
	                    component.set("v.reviewEdit", false);
	                }else{
	                    var _nextSectionEvent = component.getEvent("loadSection");
	                    _nextSectionEvent.setParams({
	                                                 "sectionNameToRender": "Attachment", 
	                                                 "reviewFormWrpObj" : component.get("v.reviewFormWrpObj"), 
	                                                 "modalHeightInPercent":"height:85%",
                                                     "isConsole":component.get("v.isConsole")
	                                                });
	                    _nextSectionEvent.fire();
	                }
                                     
                }else if(returnedValue.message.startsWith("Entered authorisation number")){
                    component.find("Auth-Lic-Num-Input").set("v.errors", [{message:returnedValue.message}]);
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();                                       
                }else{
                    component.find("Auth-Lic-Num-Input").set("v.errors", [{message:returnedValue.message}]);
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();
                }               
                
            }else if(state ==="ERROR"){
                // will be replaced with proper error handling
                alert(response.getReturnValue());
            }
             
            this.hideSpinner(component, event);
        });
        $A.enqueueAction(_action);
    },
    
    performBlankInputCheck : function(component, event) { 
        var internalDetailsWrp = component.get("v.reviewFormWrpObj");
        var isConsole = component.get("v.isConsole");
        	
        this.resetErrorMessages(component, event);
        var hasRequiredInputsMissing = false;
      
        if(isConsole == true){
            if(this.validateBlankInputs(component, event, "Auth-Lic-Num-Lookup", internalDetailsWrp.authorisationNumber)){
                component.set("v.authLookupValidationError", true);
                hasRequiredInputsMissing = true;
            } 
        }else{
            if(this.validateBlankInputs(component, event, "Auth-Lic-Num-Input", internalDetailsWrp.authorisationNumber))
            hasRequiredInputsMissing = true;
        }
        
        if(this.validateBlankInputs(component, event, "Decision-Date", internalDetailsWrp.csObj.Date_of_Original_Decision__c)
           || (this.dateChange(component, event, "Decision-Date", internalDetailsWrp.csObj.Date_of_Original_Decision__c)))
            hasRequiredInputsMissing = true;
            
        if(this.validateBlankInputs(component, event, "Ground-For-Review", internalDetailsWrp.csObj.Ground_For_Review__c))
            hasRequiredInputsMissing = true;
        
         if(internalDetailsWrp.decisionCopy == false && this.validateBlankInputs(component, event, "Desc-of-Decision", internalDetailsWrp.csObj.Decision_Description__c))
            hasRequiredInputsMissing = true;
            
        return hasRequiredInputsMissing;    
    },
    
    resetErrorMessages : function(component, event) {
        var isConsole = component.get("v.isConsole");
        
        if(isConsole == true){
            component.set("v.authLookupValidationError", false);
            component.find("Auth-Lic-Num-Lookup").set("v.errors", null);
        }else{
        	component.find("Auth-Lic-Num-Input").set("v.errors", null);    
        }
        component.find("Decision-Date").set("v.errors", null);
        component.find("Ground-For-Review").set("v.errors", null);
        if(component.get("v.copyOfDecision") == false)
        component.find("Desc-of-Decision").set("v.errors", null);
    },
    
    validateBlankInputs : function(component, event, inputId, inputValue) {
        if(inputValue == undefined || inputValue === "" || inputValue === null) {
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            return true;
        }
        else {
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    },
    dateChange : function(component, event, inputId, inputValue){
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1;
        var yyyy = today.getFullYear();
        var originalDecisionDate = component.get("v.reviewFormWrpObj.csObj.Date_of_Original_Decision__c");
 		if(dd < 10)
            dd = '0' + dd;

        if(mm < 10)
            mm = '0' + mm;
       	
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        
        if((originalDecisionDate != '' || originalDecisionDate != undefined) && originalDecisionDate > todayFormattedDate){
            component.find(""+inputId).set("v.errors", [{message: $A.get("$Label.c.ERRMSG_FUTURE_DATE_ERROR_MESSAGE")}]);
            return true;
        }else{
            component.find(""+inputId).set("v.errors", null);
        }
        return false;
    },
    getAuthorisationId : function(component, event, helper){
        var message = '';
        var action = component.get("c.getAuthorisationDetailsbyId");
        action.setParams({
            "authorisationNumber" : component.get("V.reviewFormWrpObj.authorisationNumber") 
        });
                
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnedValue = response.getReturnValue();
                console.log('latest returned value22');
                console.log(returnedValue);
                if(returnedValue.isSuccess){
                    component.set("v.reviewFormWrpObj.authorisationNumber", returnedValue.authorisationNumber);
                    component.set("v.reviewFormWrpObj.authorisationRecordID", returnedValue.authorisationRecordID);
                    this.loadFormDetails(component, event);
                }else{
                    document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").style.display = 'block';
            		document.querySelector("#InternalreviewAppDetails #generalErrorMsgDiv").scrollIntoView();            
                    if(component.get("v.portalContextName") == 'ASP'){
                        message = 'Please enter the valid Authorisation number';
                    }else{
                        message = 'Please enter the valid Taxi License number';
                    }
                    component.find("Auth-Lic-Num-Input").set("v.errors", [{message: message}]);
                    return;
                }
            }else if(state === "ERROR"){
                alert('exception occured while loading data');
            }
            this.hideSpinner(component, event);
        });  
        $A.enqueueAction(action); 
    }
})