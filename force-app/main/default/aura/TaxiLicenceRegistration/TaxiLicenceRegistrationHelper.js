({
	handleRegister: function (component, event) {
         this.validateForm(component, event);
		 var validationError = component.get('v.validationError');
		 if(validationError == true || validationError == 'true'){
			return;
		 }
		 var firstname = component.find("firstName").get("v.value");
         var lastname = component.find("lastName").get("v.value");
         var email = component.find("emailAddress").get("v.value");
         var mobile = component.find("mobileNumber").get("v.value");
         var selectedOption = component.find("InputSelectSingle").get("v.value");
         if(selectedOption == 'Corporation'){
              
         } else{
             
         }
         var action = component.get("c.handleApplicantRegister");
         action.setParams({firstname:firstname,lastname:lastname,email:email,mobile:mobile,entity:selectedOption,acn:acn,companyName:companyName});
          action.setCallback(this, function(a){
			console.log('In setCallback');
			var rtnValue = a.getReturnValue();
			console.log(rtnValue);
			if (rtnValue == 'Success') {
			 component.set("v.errorMessage",rtnValue);
			 component.set("v.showError",true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Applicant has been registered successfully.",
                    "duration":"10000",
                    "type" : "success"
                });
                toastEvent.fire();
                window.location = '/industryportal/s/login/CheckPasswordResetEmail';
			}
              else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": rtnValue,
                    "duration":10000,
                    "type" : "error"
                });
                toastEvent.fire();                
              }
             
       });
    $A.enqueueAction(action);
    },
	
	validateForm : function(component, event){
		component.set('v.validationError', false);
		this.validateFirstName(component, event);
		this.validateFamilyName(component, event);
		this.validateEmail(component, event);
		this.validateEntityType(component, event);
		this.validateMobile(component, event);
	},
	
	validateFirstName : function(component, event){
		this.clearError(component, event, 'firstName');
		var firstname = component.find("firstName").get("v.value");
		console.log('validating firstname ' + firstname);
		if(!firstname){
			console.log('validation failed for firstname');
			component.set('v.validationError', true);
			this.addError(component, event, 'firstName', 'Please enter the first name.');
		}
	},
	
	validateFamilyName : function(component, event){
		this.clearError(component, event, 'lastName');
		var lastname = component.find("lastName").get("v.value");
		console.log('validating lastname ' + lastname);
		if(!lastname){
			console.log('validation failed for lastname');
			component.set('v.validationError', true);
			this.addError(component, event, 'lastName', 'Please enter the family name.');
		}
	},
	
	validateEmail : function(component, event){
		this.clearError(component, event, 'emailAddress');
		var email = component.find("emailAddress").get("v.value");
		console.log('validating email ' + email);
		if(!email){
			console.log('validation failed for email');
			component.set('v.validationError', true);
			this.addError(component, event, 'emailAddress', 'Please enter the email address.');
		}
	},
	
	validateMobile : function(component, event){
		this.clearError(component, event, 'mobileNumber');
		var mobile = component.find("mobileNumber").get("v.value");
		console.log('validating mobile ' + mobile);
		if(!mobile){
			console.log('validation failed for mobile');
			component.set('v.validationError', true);
			this.addError(component, event, 'mobileNumber', 'Please enter ther mobile number.');
		}
	},
	
	validateEntityType : function(component, event){
		var selectedOption = component.find("InputSelectSingle").get("v.value");
		console.log('validating selectedOption ' + selectedOption);		
	},
	
	clearError :function(component, event, elementId){
		var content = component.find(elementId + 'Content').getElement();
		var error = component.find(elementId + 'Error').getElement();
		content.className = content.className.replace('slds-has-error', '');
		error.innerText = "";
	},
	
	addError : function(component, event, elementId, message){
		var content = component.find(elementId + 'Content').getElement();
		var error = component.find(elementId + 'Error').getElement();
		content.className += ' slds-has-error'; 
		error.innerText = message;
	}
})