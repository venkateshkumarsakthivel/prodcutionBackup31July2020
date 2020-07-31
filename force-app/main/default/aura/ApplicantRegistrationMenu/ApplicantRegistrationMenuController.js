({
    gotoHelp : function(component, event, helper) {
       var urlEvent = $A.get("e.force:navigateToURL");
        var helpLink ="/topic/" + $A.get("$Label.c.Topic_Name") +"/safety-checks?src=helpMenu";
        urlEvent.setParams({
            "url": helpLink
        });
        urlEvent.fire();
    }
})