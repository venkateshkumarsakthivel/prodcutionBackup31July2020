({
	closeModal : function(component,event,helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    loadSectionHandler : function(component,event,helper) {
        component.set("v.sectionNameToRender", event.getParam("sectionNameToRender"));
        component.set("v.reviewFormWrpObj", event.getParam("reviewFormWrpObj"));
        component.set("v.modalHeightInPercent", event.getParam("modalHeightInPercent"));
        if(event.getParam("isConsole"))
        component.set("v.isConsole", event.getParam("isConsole"));
        window.scrollTo(0, 0);
    },
    doInit : function(component,event,helper){			//console side --> send accountId
        var recId = component.get("v.recordId");
        console.log('Got Account Id222: '+recId);
        console.log(component.get("v.reviewFormWrpObj"));
        component.set("v.accountId", recId);
        //component.find("internalReviewApplicantDetails").fetchApplicationDetails();
        helper.validateUser(component,event);
    }
})