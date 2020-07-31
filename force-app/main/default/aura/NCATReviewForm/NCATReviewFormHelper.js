({
    validateUser : function(component,event)
    {
        var validateUserAction = component.get("c.isValidateUser");
        validateUserAction.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Got Response: "+response.getReturnValue());
                var isUserAuthorized = response.getReturnValue();
                if(isUserAuthorized == true)
                {
                    component.set('v.showNCATReviewForm', true);
                    this.fetchAccountDetails(component, event);
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Record does not meet criteria!",
                        "message": "Current User is not authorised to perform this action.", "duration": "2000",
                        "type"    : "error"
                    });
                    toastEvent.fire();
                    this.hideSpinner(component, event);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get("e.force:refreshView").fire();
                }
            }
            else
            {
                console.log('Response Error :'+ state);
            }
            
        });
        
        $A.enqueueAction(validateUserAction);
    },
    
    fetchAccountDetails : function(component, event) {
        
        var getAccountId = component.get('v.recordId');
        console.log('record id is :'+ getAccountId);
        var getAccountDetailsAction = component.get("c.getAccountDetails");
        getAccountDetailsAction.setParams({"accountId":getAccountId});
        
        getAccountDetailsAction.setCallback(this, function(response) {
            console.log(response.getState());
            var state = response.getState();
            if (state === "SUCCESS") {
                var acc = JSON.parse(response.getReturnValue());
                component.set("v.acc", acc);
                this.hideSpinner(component, event);
                
            } 
            else {
                console.log('Response Error :'+ state);
            }
        });
        
        $A.enqueueAction(getAccountDetailsAction);
        
    },
    
    saveNcatReviewCaseData : function(component, event,helper) {
        
        //console.log('in helper');
        var caseData = component.get('v.ncatReviewCase');
        var selectedAuth = component.get('v.selectedLookUpRecord');
        var userRec = component.get('v.selectedUser');
        var contactRec = component.get('v.selectedContact');
        console.log('**** The user name is' + userRec.Id);
        
        var acc = component.get('v.acc');
        
        // Setting inputdata from NcatReview form to CaseData
        caseData.AccountId = acc.Id;
        caseData.Authorisation__c = selectedAuth.Id;
        caseData.Decision_Made_By__c = userRec.Id;
        caseData.ContactId = contactRec.Id;
        var createNcatReviewCaseAction = component.get('c.createNcatReviewCase');
        var caseString = JSON.stringify(caseData);
        
        // console.log(caseString);
        createNcatReviewCaseAction.setParams({
            "caseString": caseString
        });
        
        createNcatReviewCaseAction.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                console.log('Saved Successfully');
                var caseRec = JSON.parse(response.getReturnValue());
                var createdCaseId = caseRec.Id;
                var createdCaseNumber =caseRec.CaseNumber;
                console.log('Case created'+ createdCaseId);
                if(createdCaseId!=null) {
                    console.log("created case id is"+createdCaseId);
                    //console.log("created case number  is"+ createdCaseNumber);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : "Success",
                        "message": "Case #"+createdCaseNumber +" "+ "created successfully" , "duration": "2000",
                        "type"   : "success"
                    });
                    toastEvent.fire();
                    this.hideSpinner(component, event);
                    $A.get("e.force:closeQuickAction").fire();
                    var sObjectEvent = $A.get("e.force:navigateToSObject"); sObjectEvent.setParams({ "recordId": createdCaseId, "slideDevName": "detail" });
                    sObjectEvent.fire();
                }
                else {
                    console.log('Response Error '+state);
                    console.log('failed');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'pester',
                        "title" : "Error",
                        message: 'Unable to create Case',
                        type : "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                    
                }
            }
            else
            { 
                console.log('Response Error '+state);
                console.log('failed');
            }
            
        });
        $A.enqueueAction(createNcatReviewCaseAction);
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
    validateInputs : function(component, event) {
        
        this.resetErrorMessages(component, event);
        
        //console.log('in validate helpers ');
        var hasError = false;
        var caseData = component.get('v.ncatReviewCase');
        var ncatFileNumber= caseData.NCAT_file_number__c;
        var dateOfInternalReviewDecisionNcat = caseData.Date_of_decision_being_reviewed_at_NCAT__c;
        var selectedAuth = component.get('v.selectedLookUpRecord');
        var selectedAuthId = selectedAuth.Id;
        var contactRec = component.get('v.selectedContact');
        var contactRecId = contactRec.Id;
        
        //console.log('ncatFileNumber'+ncatFileNumber);
        
        if(!ncatFileNumber){
            component.find('NCAT-File-Number').set("v.errors", [{message: $A.get("$Label.c.Error_Message_Required_Input")}]);
            hasError = true;
        }
        if(!dateOfInternalReviewDecisionNcat){
            hasError = true;
            $A.util.addClass(component.find('Date-Of-Review-Decision-NCAT'), 'slds-has-error');
            component.set("v.dateRequiredValidationError", true);
        }
        
        if(!contactRecId){
            hasError = true;
            console.log(hasError);
            $A.util.addClass(component.find('Contact-Name'), 'slds-has-error');
            component.set("v.contactLookupValidationError", true);
        }
        if(!selectedAuthId){
            hasError = true;
            console.log(hasError);
            $A.util.addClass(component.find('Auth-Number'), 'slds-has-error');
            component.set("v.authLookupValidationError", true);
        }
        if(component.get('v.ncatdateValidationError') == true){
            console.log('inside date validation');
            hasError = true;
            console.log(hasError);
        }
        if(component.get('v.internalReviewdateValidationError') == true){
            console.log('inside date validation');
            hasError = true;
            console.log(hasError);
        }
        
        var docCheck = this.performDocumentCheck(component, event);
        console.log('docCheck1');
        console.log(docCheck);
        
        if(docCheck == true)
        {
            console.log('inside performcdocument check validation');
            hasError = true;
            console.log(hasError); 
        }
        
        return hasError;
    },
    resetErrorMessages : function(component, event) {
        
        component.find("NCAT-File-Number").set("v.errors", null);
        $A.util.removeClass(component.find('Date-Of-Review-Decision-NCAT'), 'slds-has-error');
        component.set("v.dateRequiredValidationError", false);
        $A.util.removeClass(component.find('Contact-Name'), 'slds-has-error');
        component.set("v.contactLookupValidationError", false);
        $A.util.removeClass(component.find('Auth-Number'), 'slds-has-error');
        component.set("v.authLookupValidationError", false);
        
    },	
    performDocumentCheck : function (component, event){		//throw error if checkbox is checked but documents are not uploaded
        var returnStatus = false;
        var caseData = component.get('v.ncatReviewCase');
        
        var documentUploadCheck     = caseData.Internal_Review_Supporting_Documents__c;
        var documentUploadStatus 	= component.get("v.documentUploadStatus");
        
        console.log('uploadCheck'+documentUploadCheck);
        console.log('uploadStatus'+documentUploadStatus);
        
        
        //throw error if checkbox is ticked and documents are not uploaded
        if(documentUploadCheck == true){
            if(documentUploadStatus == undefined || documentUploadStatus == false){
                document.getElementById("documentsNotUploadedError").innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
                document.getElementById("documentsNotUploadedError").style.display = 'block';
                returnStatus = true;
            }
            
        }
        
        //throw error if documents are uploaded and checkbox is not ticked
        if(documentUploadStatus == true && (documentUploadCheck == false || documentUploadCheck == undefined)){
            document.getElementById("documentsNotUploadedError").innerHTML = $A.get("$Label.c.Error_Message_Required_Input");
            document.getElementById("documentsNotUploadedError").style.display = 'block';
            returnStatus = true;
        }
        
        return returnStatus;
    },
    
})