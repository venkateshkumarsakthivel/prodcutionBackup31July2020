({
	validatePostcodeFormat : function(component, event) {
		var postalcode = component.get("v.postCode");
        var postcodeExpression = /^[0-9]{4}$/; 
        var isInitComplete = component.get('v.isInitComplete');
        
        if(postalcode && !postalcode.match(postcodeExpression) && isInitComplete){
            console.log('Invalid postcode');
            component.set("v.postCode", "");
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
        errorElem.innerText = $A.get("$Label.c.Postcode_Error_Msg");
    },
    
    isPostcodeRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var postcode = component.get("v.postCode");
            if(!postcode){
                console.log('postcode is not provided');
                component.set('v.isValid', false);
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                contentElem.className += ' slds-has-error';            
                errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    }
})