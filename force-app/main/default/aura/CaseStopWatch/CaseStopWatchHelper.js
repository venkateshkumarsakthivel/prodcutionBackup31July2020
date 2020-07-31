({
    initialize : function(component, event) {
        var _case;
        var _action = component.get("c.details");
        _action.setParams({
            id: component.get("v.recordId")
        });
        
        _action.setCallback(this, function(_response) {
            if(component.isValid() && _response.getState() === "SUCCESS")  {
                _case = JSON.parse(_response.getReturnValue());
                component.set("v.case", _case);
            }
        });
        
        $A.enqueueAction(_action);
    },
    
    pause: function(component, event)  {
        console.log("Pausing timer.");
        var _case;
        var _action = component.get("c.CSWpause");
        _action.setParams({
            id: component.get("v.recordId")
        });
        
        _action.setCallback(this, function(_response) {
            if(component.isValid() && _response.getState() === "SUCCESS")  {
                _case = JSON.parse(_response.getReturnValue());
                console.log(_case);
                component.set("v.case", _case);
            }
        });
        
        $A.enqueueAction(_action);
    },
    
    resume: function(component, event)  {
        console.log("Resuming timer.");
        var _case;
        var _action = component.get("c.CSWresume");
        _action.setParams({
            id: component.get("v.recordId")
        });
        
        _action.setCallback(this, function(_response) {
            if(component.isValid() && _response.getState() === "SUCCESS")  {
                _case = JSON.parse(_response.getReturnValue());
                console.log(_case);
                component.set("v.case", _case);
            }
        });
        
        $A.enqueueAction(_action);
    }
})