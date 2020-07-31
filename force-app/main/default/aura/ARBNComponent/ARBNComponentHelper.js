({
	validateARBNFormat : function(component, event) {
		var arbn = component.get("v.arbn");
        var arbnExpression = /^[0-9]{0,9}$/;  
        var isInitComplete = component.get('v.isInitComplete');
        
        if(arbn && !arbn.match(arbnExpression) && isInitComplete){
            console.log('Invalid arbn');
            component.set("v.arbn", "");
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
        errorElem.innerText = $A.get("$Label.c.ARBN_Error_Msg");
    },
    
    isArbnRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var arbn = component.get("v.arbn");
            if(!arbn){
                console.log('arbn is not provided');
                component.set('v.isValid', false);
            }
        }
    }
})