({
    loadLogs: function(component, event, helper) {
        
        helper.loadDVDQueryLogs(component,event);
    },
    exportDVDQueryGroup: function(component, event, helper) {
        
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.group_id; 
        var runType = selectedItem.dataset.dvd_entity_type;
        console.log("Record Id of selected record is: "+recId);
         helper.getCurrentTime(component,event,recId,runType);
        
        
    },
    handleDVDCountUpdate: function(component, event, helper) {
        
        //console.log('Handle DVD Count Update Called');
        
        var recordId = event.getParam("recordId");
        var redCount = event.getParam("redCount");
        var greenCount = event.getParam("greenCount");
        var whiteCount = event.getParam("whiteCount");
        
        //console.log(recordId+'---'+redCount+'---'+greenCount+'---'+whiteCount);
        
    },
    disabledExportDVDQueryGroup : function(component, event, helper) {
        console.log("Disabled");
    }
    
})