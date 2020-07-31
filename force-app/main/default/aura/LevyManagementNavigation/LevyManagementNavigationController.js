({
	 renderfilter : function(component, event, helper) {
        var renderfilters = event.target.id;
        console.log("renderfilters: " +renderfilters);
        
         
         if(renderfilters === "Activities") {      
            
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("ActivitiesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:LevyManagementNavigationEvent");
            navEvt.setParams({"renderActivities" : true,"renderRegistration":false,
                              "renderReturns" : false,"renderAssessments":false,"renderHelp":false,
                              "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "Registration") {
           
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("RegistrationListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:LevyManagementNavigationEvent");
             navEvt.setParams({"renderActivities" : false,"renderRegistration":true,
                              "renderReturns" : false,"renderAssessments":false,"renderHelp":false,
                              "whichButton":renderfilters,"spinner":true});
            console.log("In event fired before");
            navEvt.fire();
            console.log("In event fired");
            
        }else if(renderfilters === "Returns") {
           
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("ReturnsListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:LevyManagementNavigationEvent");
            navEvt.setParams({"renderActivities" : false,"renderRegistration":false,
                              "renderReturns" : true,"renderAssessments":false,"renderHelp":false,
                              "whichButton":renderfilters,"spinner":true});
            
            console.log("In event fired before");
            navEvt.fire();
            console.log("In event fired");
            
        }else if(renderfilters === "Assessments") {
           
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("AssessmentsListItem"), 'slds-is-active');
            var navEvt = $A.get("e.c:LevyManagementNavigationEvent");
            navEvt.setParams({"renderActivities" : false,"renderRegistration":false,
                              "renderReturns" : false,"renderAssessments":true,"renderHelp":false,
                              "whichButton":renderfilters,"spinner":true});
            
            console.log("In event fired before");
            navEvt.fire();
            console.log("In event fired");
            
        }else if(renderfilters === "Help") {
           
            var urlEvent = $A.get("e.force:navigateToURL");
            var url = "/industryportal/s/topic/"+ $A.get("$Label.c.Levy_Help_Topic_Id") +"/passenger-services-levy?src=helpMenu";
            window.open(url, '_blank');         
        }
     }
})