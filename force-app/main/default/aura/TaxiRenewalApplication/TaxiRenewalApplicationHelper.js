({
	loadSectionData : function(component, event) {
		var action = component.get("c.retrieveApplicationDetails");
        var caseId = component.get("v.caseId");
        console.log('Retrieving application details for ' + caseId);
        action.setParams({"caseId": caseId});
        action.setCallback(this,function(response) {            
            var state = response.getState();
            console.log('Action State ' + state);
            if(state === "SUCCESS") {                
                var application = response.getReturnValue();                
                console.log(application);
                if(application.Status__c == 'Lodged'){
                    console.log('Form needs to be rendered in read only mode');
                    component.set("v.readOnly", true);
                }
                if(application.Authorisation__r != undefined && application.Authorisation__r != null){
                    console.log(application.Authorisation__r);
                    component.set("v.renewalAuthorisationName", application.Authorisation__r.Name);
                    component.set("v.renewalAuthorisationStartDate", application.Authorisation__r.Start_Date__c);
                    component.set("v.renewalAuthorisationEndDate", application.Authorisation__r.End_Date__c);
                    component.set("v.licenceFee", application.Authorisation__r.Licence_Fee__c);
                    component.set("v.operationArea", application.Authorisation__r.Operation_Area__c);
                    component.set("v.licenceClass", application.Authorisation__r.Licence_Class__c);
                    component.set("v.operatingLocations", application.Authorisation__r.Operating_Locations__c);
                    component.set("v.licenceType", application.Authorisation__r.Licence_Type__c);
                    component.set("v.plateNumber", application.Authorisation__r.Plate_Number__c);
                } else {
                    console.log('Licence details not available');
                    component.set("v.displayNextSection", false);
                }
                if(application.Orders__r != undefined && application.Orders__r != null){
                    console.log('Payment details available');
                    console.log(application.Orders__r[0]);
                    if(application.Orders__r[0].TotalAmount > 0){
                        var licenceFee = component.get("v.licenceFee");
                    	component.set("v.applicationFee", application.Orders__r[0].TotalAmount - licenceFee);       
                    } else {
                    	component.set("v.applicationFee", application.Orders__r[0].TotalAmount);        
                    }
                } else {
                    console.log('Payment details not available');
                    component.set("v.displayNextSection", false);
                }                
            } else {                
                console.log('Failed to load section data.');
                component.set("v.displayNextSection", false);
            }
        });
        $A.enqueueAction(action);        
	},
    retrieveEntityType: function(component, event){
        console.log('Retrieving entity type for application');
        var action = component.get("c.getEntityType");
        var caseId = component.get("v.caseId");
        action.setParams({"caseId" : caseId});
        action.setCallback(this,function(response) {            
            var state = response.getState();
            console.log('Action State ' + state);
            if(state === "SUCCESS") {                
                var entityType = response.getReturnValue(); 
                console.log('Received Entity Type: ' + entityType);
                component.set("v.entityType", entityType);     
            } else {                
                console.log('Failed to retrieve entity type.');                
            }
        });
        $A.enqueueAction(action);
    }
})