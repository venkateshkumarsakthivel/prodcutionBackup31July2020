({
    doInit : function(component, event, helper){
        
        console.log('inside doInit');
        setTimeout(function(){ 
            component.find("licenceNumber").find("licence").getElement().focus();
        }, 100);
    },
    onKeyUp : function(component, event, helper){
        if (event.getParam('keyCode')===13) {
            helper.saveDriverRecord(component, event, helper);
        }
    },
    saveDriverRecord : function(component, event, helper){
        console.log('In saveDriverRecord');
        helper.saveDrivrRecord(component, event);
    },	
    closemodal : function(component, event, helper) {
        helper.closeModalDiv(component);
    },
    hideDatePicker:function(component, event, helper){
        console.log('Hide date picker popup');
        var datepickerElements = document.getElementsByClassName('uiDatePicker--default');
        for(var index = 0; index < datepickerElements.length; index++){
            console.log('remove visible class');
            datepickerElements[index].className = datepickerElements[index].className.replace('visible', '');
        }
    },
    validate : function(component, event, helper){
        console.log('*');
        var inp = component.get('v.licenceNo');
        if(isNaN(inp))
            component.set('v.inputN', inp.substring(0, 9));
    }
})