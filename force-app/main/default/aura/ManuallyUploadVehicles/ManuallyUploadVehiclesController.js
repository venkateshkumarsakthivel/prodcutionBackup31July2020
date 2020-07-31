({
    doInit : function(component, event, helper){
        
        console.log('Insie doInit');
        setTimeout(function(){ 
            component.find("platenumber").getElement().focus();
        }, 100);
    },
    onKeyUp: function(component, event, helper){
        //checks for "enter" key
        
        if (event.getParam('keyCode')===13) {
            helpler.saveVehicleRecord(component, event, helpler);
        }
    },
    saveVehicleRecord : function(component, event, helper){
        helper.saveVehicleRecord(component, event);
    },
    
    closemodal : function(component, event, helper) {
        helper.closeModalDiv(component, event);
    }
})