({
    navigateToeDiscoverySearchCmp : function(component, event, helper) {
          //$A.get("e.force:closeQuickAction").fire() ;
       // var evt = $A.get("e.force:navigateToComponent");
        console.log(component.get("v.recordId"));
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__AuthorisationHistory"
            },
            "state": {
                  "c__RelatedlistID": component.get("v.recordId")
            }
        };
        
        component.set("v.pageReference", pageReference);
        
        const navService = component.find('navService');
        const pageReferenceNavigate = component.get('v.pageReference');
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageReferenceNavigate).then(handleUrl, handleError);
            
            
      /*  
        evt.setParams({
            componentDef : "c:AuthorisationHistory",
             componentAttributes: {
            RelatedlistID : component.get("v.recordId")
        }
            
        });
        evt.fire();
        */
     $A.enqueueAction(component.get('c.closeModal'));
    },
    closeModal : function(component, event, helper) {
	// Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        }
})