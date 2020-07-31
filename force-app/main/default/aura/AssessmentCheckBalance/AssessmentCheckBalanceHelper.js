({
    sendGetAssessmentRequest : function(component, event, helper) {
        
        var recordId = component.get('v.recordId');
        console.log('RecordId ' + recordId);
        
        // Concat Authorisation Number TSP and BSP
        var tspNumber = component.get('v.assessmentRecord.Taxpayer_Registration__r.Taxi_Service_Provider_Number__r.Authorisation_Number__c');
        component.set('v.tspNumber', tspNumber);
       
        var bspNumber = component.get('v.assessmentRecord.Taxpayer_Registration__r.Booking_Service_Provider_Number__r.Authorisation_Number__c');
        component.set('v.bspNumber', bspNumber);
        
        // Setting up Levy period 
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        
        var levyPeriodStartDate = new Date(component.get('v.assessmentRecord.Period_Start_Date__c'));
        var levyPeriodEndDate = new Date(component.get('v.assessmentRecord.Period_End_Date__c'));
        
        var levyPeriodStartDateMonth = monthNames[levyPeriodStartDate.getMonth()];
        var levyPeriodEndDateMonth = monthNames[levyPeriodEndDate.getMonth()];
        
        var levyPeriodStartToEnd = levyPeriodStartDateMonth+ " " + levyPeriodStartDate.getFullYear();
        // if start date and end date is not of same month
        if(levyPeriodStartDateMonth != levyPeriodEndDateMonth) {
            levyPeriodStartToEnd += " to " + levyPeriodEndDateMonth + " " + levyPeriodEndDate.getFullYear(); 
        } 
        component.set('v.levyPeriod', levyPeriodStartToEnd);
        
        //Calling Apex controller to send request
        var action = component.get("c.executeOSRGetAssessment");
        action.setParams({
            "assessmentId": recordId,
            "levyPeriodMonth": levyPeriodStartToEnd
        });
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var responseMap = JSON.parse(JSON.stringify(response.getReturnValue()));
                console.log('Response >>' + responseMap);
                if('isAccessible' in responseMap) {
                     this.generateErrorToast(component, event);
                }
                
                if('bspAssessedLiability' in responseMap || 'tspAssessedLiability' in responseMap) {
                    
                    var bspOutstanding = 0;
                    var tspOutstanding = 0;
                    
                    // Check for bsp auth details in Map
                    if('bspAssessedLiability' in responseMap ) {
                        bspOutstanding = responseMap.bspAssessedLiability - responseMap.bspAmountReceived;
                        component.set('v.bspAssessedLiability', responseMap.bspAssessedLiability);
                        component.set('v.bspAmountReceived', responseMap.bspAmountReceived);
                        component.set('v.bspOutstanding', bspOutstanding);
                    }// Check for tsp auth details in Map
                    if('tspAssessedLiability' in responseMap ) {
                        tspOutstanding = responseMap.tspAssessedLiability - responseMap.tspAmountReceived;
                        component.set('v.tspAssessedLiability', responseMap.tspAssessedLiability);
                        component.set('v.tspAmountReceived', responseMap.tspAmountReceived);
                        component.set('v.tspOutstanding', tspOutstanding);
                    }
                    
                    var totalOutstanding = bspOutstanding + tspOutstanding;
                    
                    if(totalOutstanding == 0) {
                        component.set('v.collectionStatus', 'Closed');
                    }
                    component.set('v.totalOutstanding', totalOutstanding);
                    component.set('v.userName', responseMap.UserName);
                    component.set('v.currentTime', responseMap.CurrentDateTime);
                    
                    this.hideSpinner(component, event);
                } else {
                    this.generateErrorToast(component, event);
                }
            } 
            else {
                console.log('Error...');
                console.log(response);
                console.log(response.getReturnValue());
                this.generateErrorToast(component, event);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    generateErrorToast : function(component, event){
        
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "title": "Error",
            "message": "Unable to check balance.",
            "type": "error",
            "duration": "10000"
        });
        toastEvent.fire(); 
        
        $A.get("e.force:closeQuickAction").fire();
        this.hideSpinner(component, event);
    },
    
   authorisationNotExist : function(component, event){
        
        var toastEvent = $A.get("e.force:showToast");           	
        toastEvent.setParams({
            "title": "Error",
            "message": "Record not found. Unable to check balance.",
            "type": "error",
            "duration": "10000"
        });
        toastEvent.fire(); 
        
        $A.get("e.force:closeQuickAction").fire();
        this.hideSpinner(component, event);
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