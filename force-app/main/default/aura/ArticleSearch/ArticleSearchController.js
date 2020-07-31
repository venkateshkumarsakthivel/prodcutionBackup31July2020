({
	doInit : function(component, event, helper) {
		console.log('init article search');
        var url = window.location.href;
        console.log(url);
        var taxiLicenceIndex = url.search('topic');
        console.log(taxiLicenceIndex);
        var modifiedUrl = url.substr(taxiLicenceIndex + 6, 18);
        console.log(modifiedUrl);
        component.set("v.currentTopic", modifiedUrl);
        console.log(component.get("v.currentTopic"));
        //console.log(anchorElem.classNames);
	},

    checkForEnter : function(component, event, helper) {
     if((event.currentTarget != undefined && event.currentTarget.id == "searchArtice") 
            || event.getParam('keyCode') === 13) {
            console.log("enter is pressed" + component.find("searchstring").get("v.value"));
            var urlEvent = $A.get("e.force:navigateToURL");
             var url  =  "/global-search/" +  component.find("searchstring").get("v.value");
             window.href = url;
             urlEvent.setParams({
             "url": url
            });
            urlEvent.fire();
       
       }
    
    },
    dummyInvokeForDebug : function(component,event,helper) {
        console.log('Input changed' + component.find("searchstring").get("v.value"));
        console.log("Key code " + event.getParam('keyCode'));
        
    }

})