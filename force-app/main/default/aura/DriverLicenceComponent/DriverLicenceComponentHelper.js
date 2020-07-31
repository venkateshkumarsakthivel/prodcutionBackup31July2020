({
	validateLicenceFormat : function(component, event) {
		var licence = component.get("v.licence");
       
        var licenceExpression = /^(?=[a-zA-Z0-9]*$)(?:.{1,12})$/;
        var isInitComplete = component.get('v.isInitComplete');
        
        if(licence && !licence.match(licenceExpression) && isInitComplete){
            console.log('Invalid licence');
            component.set("v.licence", "");
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
        errorElem.innerText = $A.get("$Label.c.Driver_Licence_Error_Msg");
    },
    
    isLicenceRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var licence = component.get("v.licence");
            if(!licence){
                console.log('licence is not provided');
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