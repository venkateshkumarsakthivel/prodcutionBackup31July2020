({

	//check whether user is authorised or not
    isAuthorisedUser : function(component, event, helper) {
        this.showSpinner(component, event);
        var action = component.get("c.isValidUser");
        
        action.setCallback(this,function(response) {
            
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var response = response.getReturnValue();
                if(!response) {
                    var toastEvent = $A.get("e.force:showToast");           	
                    toastEvent.setParams({
                        "title": "Authentication Error!",
                        "message": "You are not authorised to perform this action.",
                        "type": "error",
                        "duration": "500"
                    });
                    toastEvent.fire(); 
                    $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
        			$A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                   
                    
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    return;
                }
            } 
            else {
                console.log('call failed**');
                console.log(response);
            }
        });
        
        $A.enqueueAction(action);
        this.hideSpinner(component, event); 
    },

    //check if parent case status is not closed.
    isValidParentCase: function(component,event){

        var parentCaseStatus= component.get("v.parentCase.Status");
        console.log('parentCaseStatus=='+parentCaseStatus);
         console.log('parentCase='+component.get("v.parentCase.Id"));
        if(parentCaseStatus == 'Closed'){
            component.set("v.isAllValid",false);
            var toastEvent = $A.get("e.force:showToast");               
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Cannot create criminal charge as criminal charge investigation case is closed",
                        "type": "error",
                        "duration": "10000"
                    });
                    toastEvent.fire(); 
                    $A.util.removeClass(component.find("messageBox"), "slds-fade-in-open");
                    $A.util.removeClass(component.find("backdrop"),  "slds-backdrop--open");
                   
                    
                    $A.get("e.force:closeQuickAction").fire();
        }

    },

	validateFieldValues : function(component,event) {
		
		
		var isValid=true;
		var offenceCodeComp = component.find("offenceCode");
        
        if((offenceCodeComp.get("v.value") == "") || (offenceCodeComp.get("v.value") == null) ){
           $A.util.addClass(offenceCodeComp,'slds-has-error');
           isValid=false;    
        }
        else{
	        var codeLength=offenceCodeComp.get("v.value").length;
	        console.log('codeLength==='+codeLength);
	        if(codeLength > 15){
	        	component.set("v.offenceCodeErrorMsg","Law Part Code can be of maximum 15 characters.");

		        document.querySelector("#CriminalOffenceCaseInformation #offenceCodeErrorMsgDiv").style.display = 'block';
		        document.querySelector("#CriminalOffenceCaseInformation #offenceCodeErrorMsgDiv").scrollIntoView();
		         $A.util.addClass(offenceCodeComp,'slds-has-error');
	           isValid=false; 
	        }
        }

        var decisionComp = component.find("decision");
        if( (decisionComp.get("v.value") == "") || (decisionComp.get("v.value") == null)  ){
           $A.util.addClass(decisionComp,'slds-has-error');
           isValid=false;    
        }

        var decisionReasonComp = component.find("decisionReason");
        if( (decisionReasonComp.get("v.value") == "") || (decisionReasonComp.get("v.value") == null) ){
           $A.util.addClass(decisionReasonComp,'slds-has-error');
           isValid=false;    
        }

        var lawPartCodeComp = component.find("lawPartCode");
        if( (lawPartCodeComp.get("v.value") == "" ) || (lawPartCodeComp.get("v.value") == null )  ){
           $A.util.addClass(lawPartCodeComp,'slds-has-error');
           isValid=false;    
        }

        if( (component.get("v.parentCase.Charge_Code_Identifier__c") == "") ||  (component.get("v.parentCase.Charge_Code_Identifier__c") == null)){

           component.set("v.chargeCodeErrorMsg","Charge Code Identifier is missing on parent case.");

	        document.querySelector("#CriminalOffenceCaseInformation #chargeCodeErrorMsgDiv").style.display = 'block';
	        document.querySelector("#CriminalOffenceCaseInformation #chargeCodeErrorMsgDiv").scrollIntoView();
           isValid=false;    
        }

        if( (component.get("v.parentCase.Account.Id") == "") || (component.get("v.parentCase.Account.Id") == null)){

           	component.set("v.accountErrorMsg","Account Name is missing on parent case.");
           	document.querySelector("#CriminalOffenceCaseInformation #accountErrorMsgDiv").style.display = 'block';
	        document.querySelector("#CriminalOffenceCaseInformation #accountErrorMsgDiv").scrollIntoView();
           isValid=false;    
        }
        if((component.get("v.parentCase.Australian_Driver_Licence_Number_Formula__c") == "")|| (component.get("v.parentCase.Australian_Driver_Licence_Number_Formula__c") == null) ){
           component.set("v.licenceErrorMSg","Driver Licence Number is missing on parent case.");
           document.querySelector("#CriminalOffenceCaseInformation #licenceErrorMSgDiv").style.display = 'block';
	       document.querySelector("#CriminalOffenceCaseInformation #licenceErrorMSgDiv").scrollIntoView();
           isValid=false;    
        }

        
        console.log("isValid==="+isValid);

        if(isValid==false){
	        document.querySelector("#CriminalOffenceCaseInformation #generalErrorMsgDiv").style.display = 'block';
	        document.querySelector("#CriminalOffenceCaseInformation #generalErrorMsgDiv").scrollIntoView();
        }

        
        component.set("v.isAllValid",isValid);
    },

    populateCaseInformation: function(component,event) {
    	var accountId=component.get("v.parentCase.Account.Id");
    	var chargeCode=component.get("v.parentCase.Charge_Code_Identifier__c");
    	var auDriverLicence=component.get("v.parentCase.Australian_Driver_Licence_Number__c");
    	
    	if(accountId != null || accountId != "" )
    			component.find('accountId').set("v.value", accountId);
    	
    	if(chargeCode != null || chargeCode != "")
    			component.find('chargeCodeIdentifier').set("v.value", chargeCode);
    	component.find('auDriverLicence').set("v.value", auDriverLicence);
    },

    submitCase:function(component,event) {
    	console.log('inside submit case');
    	
    	var chargeCode=component.get("v.parentCase.Charge_Code_Identifier__c");
    	var subject = "Criminal charge case for charge code "+ chargeCode +" : offence code " + component.find('offenceCode').get("v.value");
		var eventFields = event.getParam("fields");
		//Populate other case details
		eventFields["ParentId"] = component.get("v.parentCase.Id");
		eventFields["AccountId"] = component.get("v.parentCase.Account.Id");
		//eventFields["Australian_Driver_Licence_Number__c"] = component.get("v.parentCase.Australian_Driver_Licence_Number__c");
		//eventFields["Charge_Code_Identifier__c"] = component.get("v.parentCase.Charge_Code_Identifier__c");
		eventFields["OwnerId"] = $A.get('$SObjectType.CurrentUser.Id');
		
		eventFields["Subject"] = subject;
		eventFields["Status"] = "Lodged";
		eventFields["Sub_Status__c"] = "Assessment In Progress";
		eventFields["Type"] = "Criminal Charge Investigation";
		eventFields["Sub_Type__c"] = "Criminal Charge";
		
		var currentDate = new Date();
		eventFields["Date_Submitted__c"] = currentDate;
			component.find('editForm').submit(eventFields);
		
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