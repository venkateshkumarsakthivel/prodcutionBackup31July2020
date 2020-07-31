({
	validateDateOfBirth : function(component, event){
        console.log('Helper');
		var dob = component.get('v.dob');
        var str = dob.substring(8,10) + '/' + dob.substring(5,7) + '/' + dob.substring(0, 4);
        var isInitComplete = component.get('v.isInitComplete');
        console.log('Init'+isInitComplete);
        var numberExpression = /^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$/; 
        var matchforIntegerandSlash = /^[a-zA-Z!@#$%^&*()_+\-=\[\]{};:\\|,.<>\/?]*$/ ; 

        if(str && str.match(matchforIntegerandSlash)){
           console.log('Invalid Date of Birth');
            component.set("v.dob", "");
            component.set('v.isValid', false);
            this.displayErrorMessage(component, event);
            }
       
	}, 
    
    resetErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className = contentElem.className.replace('slds-has-error', '');
		errorElem.innerText = "";
    },
    
    displayErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        errorElem.innerText = $A.get("$Label.c.ERRMSG_INVALID_DATE");
    },
    
    isDOBRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var dob = component.get("v.dob");
            if(!dob){
                console.log('phone is not provided');
                component.set('v.isValid', false);
            }
        }
    }
})