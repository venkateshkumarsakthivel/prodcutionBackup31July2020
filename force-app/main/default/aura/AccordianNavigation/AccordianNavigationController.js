({

    doInit : function (component, event, helper){

    },
    
    renderfilt : function(component, event, helper) {
        var renderfilters = event.target.id;
        console.log("renderfilters: " +renderfilters);
        if(renderfilters === "Drivers") {      

            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("DriversListItem"), 'slds-is-active');
            
             var navEvt = $A.get("e.c:ASPDashboardNavigationEvent");
             navEvt.setParams({"renderVehicles" : false,"renderDrivers":true, "renderQueryLogs":false,"whichButton":renderfilters,"spinner":true});
             navEvt.fire();

        }else if(renderfilters === "Vehicles") {

            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("VehiclesListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPDashboardNavigationEvent");
            navEvt.setParams({"renderVehicles" : true,"renderDrivers":false, "renderQueryLogs":false, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "DVDLogs") {
			var refreshEvt = $A.get("e.c:RefreshDVDQueryLogs");
            refreshEvt.fire();
           
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("DVDLogsListItem"), 'slds-is-active');
            
            var navEvt = $A.get("e.c:ASPDashboardNavigationEvent");
            navEvt.setParams({"renderVehicles" : false,"renderDrivers":false, "renderQueryLogs":true, "whichButton":renderfilters,"spinner":true});
            navEvt.fire();
            
        }else if(renderfilters === "QueryHistory") {
            helper.removeHightlight(component, event);
            $A.util.addClass(component.find("QueryHistoryListItem"), 'slds-is-active');
            
        }else if(renderfilters==="Help") {
            var urlEvent = $A.get("e.force:navigateToURL");
            var url = "/industryportal/s/topic/"+ $A.get("$Label.c.Topic_Name") +"/dvd?src=helpMenu";
            window.open(url, '_blank');
        }
        else {
            var navEvt = $A.get("e.c:ASPDashboardNavigationEvent");
            navEvt.setParams({"renderVehicles" : false,"renderDrivers":false,"renderQueryLogs":false,"whichButton":renderfilters,"spinner":true});
            navEvt.fire();
        }
    },
    
    renderfiltersHandler : function(component, event, helper){
       
        var tabName = event.getParam("tabName");
        helper.removeHightlight(component, event);
        console.log('tabName parameter: ' + tabName);
        var tabId = '';
        if(tabName === "DVDLogs") {
            tabId = 'DVDLogsListItem';
        } else if(tabName === "Vehicles"){
            tabId = 'VehiclesListItem';
        } else if(tabName === "Drivers"){
            tabId = 'DriversListItem';
        }
        
        $A.util.addClass(component.find(tabId), 'slds-is-active');
    }

})