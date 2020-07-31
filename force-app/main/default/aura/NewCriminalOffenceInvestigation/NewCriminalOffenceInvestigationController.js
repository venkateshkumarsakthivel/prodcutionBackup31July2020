({
    doInit: function(component, event, helper) {
        
       helper.checkUserHasAccess(component, event, helper);
      
        //get record type id from label
        var recordTypeId = $A.get("$Label.c.Record_Type_Criminal_Offence_Investigation_Id");
        
        // Prepare a new record from template
        component.find("caseRecordCreator").getNewRecord(
            "Case", // sObject type (objectApiName)
            recordTypeId,      // recordTypeId : Criminal_Offence_Investigation_Id
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.newCase");
                var error = component.get("v.caseError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                console.log("Record template initialized: " + rec);
            })
        );
    },
    
    handleSaveCase: function(component, event, helper) {
        
        //perform all required validation
        if(helper.validateCaseForm(component)) {
            
            //set required field such as status, sub status, type , parentAccountId etc
            
            var today = new Date();
            console.log('date>>' + today);
           // var date = today.getDate()+'/'+today.getMonth()+'/'+today.getFullYear()+' '+moment().format('hh:mm a');
            //today = $A.localizationService.formatDate(today, "dd/MM/yyyy hh:mm a");
            console.log('date>>' + today);
            
            var todaysdate =today.toISOString();
            component.set("v.simpleNewCase.Date_Submitted__c", todaysdate);
            component.set("v.simpleNewCase.AccountId", component.get("v.recordId"));
            component.set("v.simpleNewCase.Sub_Type__c", 'Correction');
       	    component.set("v.simpleNewCase.Type", 'Criminal Charge Investigation');       
            component.set("v.simpleNewCase.Sub_Status__c", 'Review Pending');
            component.set("v.simpleNewCase.Status", 'Lodged');
        
        	component.find("caseRecordCreator").saveRecord(function(saveResult) {
                if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                    // after succesfully saving record
                    document.querySelector("#CriminalOffenceInvestigationInformation #generalErrorMsgDiv").style.display = 'none';
        			helper.afterSavingRecord(component, event, helper,saveResult.recordId);
 				} else if (saveResult.state === "INCOMPLETE") {
                    // handle the incomplete state
                    console.log("User is offline, device doesn't support drafts.");
                } else if (saveResult.state === "ERROR") {
                    // handle the error state
                    console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
                } else {
                    console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                }
            });
            
        } else {
            console.log('validation error occured');
            document.querySelector("#CriminalOffenceInvestigationInformation #generalErrorMsgDiv").style.display = 'block';
            document.querySelector("#CriminalOffenceInvestigationInformation #generalErrorMsgDiv").scrollIntoView();
        }
    },
    
    dateUpdate : function(component, event, helper) {
        
        var today = new Date();        
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if(dd < 10){
            dd = '0' + dd;
        } 
        // if month is less then 10, then append 0 before date    
        if(mm < 10){
            mm = '0' + mm;
        }
        
        var todayFormattedDate = yyyy+'-'+mm+'-'+dd;
        if(component.get("v.simpleNewCase.Consent_Date__c") != '' && component.get("v.simpleNewCase.Consent_Date__c") > todayFormattedDate){
            component.set("v.dateValidationError" , true);
        }else {component.set("v.dateValidationError" , false);}
    },
    
    handleRecordUpdated: function(component, event, helper) {
        console.log("Record before loadinggg...");
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
            console.log("Record is CHANGED...");
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
             console.log("Record is deleted.");
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
            console.log("Error while loading the record..");
        }
    }
})