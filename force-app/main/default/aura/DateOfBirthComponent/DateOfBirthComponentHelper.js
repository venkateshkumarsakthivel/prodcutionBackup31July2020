({
    validateDOBFormat : function(component, event) {
        console.log("In Helper DOB");
        var dob = component.get("v.DOB");
        console.log(dob);
        var ageIsValid = this.isAgeValid(dob);
        var dobIsValid = this.isDOBValid(dob);
        var isInitComplete = component.get('v.isInitComplete');
        
        if((dob) && ((!ageIsValid) || (!dobIsValid)) && (isInitComplete)){
            console.log('Invalid dob');
            //component.set("v.DOB", "");
            component.set('v.isValid', false);
            this.displayErrorMessage(component, event);
        }
        else
            this.resetErrorMessage(component, event);
    },
    resetErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        if(identifier != undefined) {
            
            var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
            var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
            
            if(contentElem != undefined)
                contentElem.className = contentElem.className.replace('slds-has-error', '');
            
            if(errorElem != undefined)
                errorElem.innerText = "";
        }
    },
    displayErrorMessage : function(component, event){
        var identifier = component.get('v.uniqueIdentifier');
        var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
        var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
        contentElem.className += ' slds-has-error';            
        //errorElem.innerText = $A.get("$Label.c.Driver_Licence_Error_Msg");
        errorElem.innerText = $A.get("$Label.c.Error_Message_Invalid_DOB");
    },
    isDOBRequired : function(component, event){
        var isRequired = component.get('v.isRequired');
        if(isRequired == true){
            var dob = component.get("v.DOB");
            if(!dob){
                console.log('DOB is not provided');
                component.set('v.isValid', false);
                var identifier = component.get('v.uniqueIdentifier');
                var contentElem = document.getElementsByClassName(identifier + 'Content')[0];
                var errorElem = document.getElementsByClassName(identifier + 'Error')[0]; 
                contentElem.className += ' slds-has-error';            
                errorElem.innerText = $A.get("$Label.c.Error_Message_Required_Input");
            }
        }
    },
    isDOBValid : function (str){
        console.log("In isDOBValid");
        
        
        if((str) && str.length != 10){
            return false;
        }
        
        var datestr = new Date(str);
        if(datestr == 'NaN' || datestr == 'Invalid Date' ){
            return false;
        }
        return true; 
    },
    isAgeValid : function(birth){
        console.log("In isAGEValid");
        var birthdate = new Date(birth);
        var today = new Date();
        
        if(birthdate > today){
            return false;
        }
        
        var timeDiff = Math.abs(today.getTime() - birthdate.getTime());
        var diffInYears = Math.floor((Math.ceil(timeDiff / (1000 * 3600 * 24))/365.242189));
        console.log(diffInYears); 
        if(diffInYears < 18 || diffInYears >=150){
            return false;
        }
        
        return true;
        
    },
   
})