({
	checkBSPTSPExistence : function(component, event) {
		
        var checkTSPExistence = component.get("c.hadTSPAuthorisation");
        checkTSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentRecord")
        });
        checkTSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD TSP: '+response.getReturnValue());
                component.set("v.hadTSP", response.getReturnValue());
            }
        });
        checkTSPExistence.setBackground();
        $A.enqueueAction(checkTSPExistence);
        
        
        var checkBSPExistence = component.get("c.hadBSPAuthorisation");
        checkBSPExistence.setParams({ 
            tempAssessment : component.get("v.assessmentRecord")
        });
        checkBSPExistence.setCallback(this,function(response) {
            
            this.hideSpinner(component, event);
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('HAD BSP: '+response.getReturnValue());
                component.set("v.hadBSP", response.getReturnValue());
            }
        });
        checkBSPExistence.setBackground();
        $A.enqueueAction(checkBSPExistence);
        
	},
    showSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },   
    hideSpinner : function(component, event) {
        
        var spinner = component.find("spinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
    }
})