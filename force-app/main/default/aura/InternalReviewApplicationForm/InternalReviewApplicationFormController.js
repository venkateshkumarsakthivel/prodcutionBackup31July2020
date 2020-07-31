({
	closeModal : function(component,event,helper) {
	    console.log('testing one two three');
        var body = component.get("v.body");
        component.set('v.body',[]);
    },
    loadSectionHandler : function(component,event,helper) {
        component.set("v.sectionNameToRender", event.getParam("sectionNameToRender"));
        component.set("v.reviewFormWrpObj", event.getParam("reviewFormWrpObj"));
        component.set("v.modalHeightInPercent", event.getParam("modalHeightInPercent"));
        window.scrollTo(0, 0);
    }
})