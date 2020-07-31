({
    
    MAX_FILE_SIZE: 750000,
    
    showSpinner : function(component, event){  
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner : function(component, event){
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    },
    
    attach: function(component, event, file, contents) {
        this.showSpinner(component, event);
        var _action = component.get("c.attach");
        _action.setParams({
            parent: component.get("v.ParentRecordId"),
            name: file.name,
            contents: btoa(contents),
            ctype: file.type
        });
        
        _action.setCallback(this, function(_response) {
            this.hideSpinner(component, event);
            return _response.getReturnValue();
        });
        
        $A.enqueueAction(_action);
    }
})