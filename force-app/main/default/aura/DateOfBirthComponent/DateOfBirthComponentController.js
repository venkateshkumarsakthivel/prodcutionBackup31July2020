({	
    validateDOB : function(component, event, helper){
        console.log('DOB component init');
        var isInitComplete = component.get('v.isInitComplete');
        
        if(isInitComplete){
            console.log('reset error message');
            helper.resetErrorMessage(component, event);
        } else {
            console.log('component initialized');
            component.set('v.isInitComplete', true);
        }      
        helper.validateDOBFormat(component, event);       
    },
    validateDOBForSave : function(component, event, helper){
        component.set('v.isValid', true);
        helper.validateDOBFormat(component, event);
        helper.isDOBRequired(component, event);
    },
    hideDatePicker : function(component, event, helper){
        console.log('Hide date picker popup');
        var datepickerElements = document.getElementsByClassName('uiDatePicker--default');
        for(var index = 0; index < datepickerElements.length; index++){
            console.log('remove visible class');
            datepickerElements[index].className = datepickerElements[index].className.replace('visible', '');
        }
    },
    isDOBChanged : function(component, event, helper){
        var isChanged = false;
        var oldDOB = component.get('v.oldDOB');
        var DOB = component.get('v.DOB');
        
        if(oldDOB != DOB){
            component.set('v.isdateChanged', true);
        }
        else {
            component.set('v.isdateChanged', false);
        }
    },
    
})