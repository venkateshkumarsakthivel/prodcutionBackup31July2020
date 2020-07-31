({
    handleClickEvent : function(component, event, helper) {
        console.log('received event:' + event + '-' + component);
        var cardeventhandler= component.get("v.cardeventhandler");
        
        var clickEvent = component.getEvent(cardeventhandler);
        
        console.log('card event:' + clickEvent);
        
        var buttonhref= component.get("v.buttonhref");
        clickEvent.fire();
    },
    handleTaxiAgentRegistrationClick : function(component, event, helper) {
        
    }
    
})