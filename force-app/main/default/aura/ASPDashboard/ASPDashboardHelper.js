({
    getAspDashboardConfigurationValues: function(component, event) {
        var aspDashboardConfigurationValuesAction = component.get('c.getDashboardConfigurationValues');
        aspDashboardConfigurationValuesAction.setCallback(this,function(dvdResult) {
            
            var state = dvdResult.getState();
            var dashboardResponse = dvdResult.getReturnValue();
            
            if(state === "SUCCESS") {
                
                for(var dvdVal in dashboardResponse) {
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.CCI_P2P_Eligibility"))
                        component.set("v.ShowP2pEligibility", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.CCI_Criminal_Charge"))
                        component.set("v.ShowCriminalCharge", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.CCI_Licence_Eligibility"))
                        component.set("v.ShowLicenceEligibility", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.CCI_Serious_Driving_Offence"))
                        component.set("v.ShowSeriousDrivingOffences", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.DVD_Tenure_Check"))
                        component.set("v.hideTenureCheck", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.DVD_AIS_Inspection_Date"))
                        component.set("v.hideInspectionDateCheck", dashboardResponse[dvdVal].Hide_Results__c);
                    
                    if(dashboardResponse[dvdVal].MasterLabel == $A.get("$Label.c.CCI_Vehicle_Check"))
                        component.set("v.ShowVehicleCheck", dashboardResponse[dvdVal].Hide_Results__c);
                }
                
                this.loadDrivers(component, event);
            }
            else {
                console.log('Error while set the DVD Lights values');
            }
            
            
        });
        aspDashboardConfigurationValuesAction.setBackground();
        $A.enqueueAction(aspDashboardConfigurationValuesAction);
    },
    
    loadDrivers : function(component, event) {
        
        this.showSpinner(component, event);
        var startT = (new Date()).getTime();
        var action = component.get('c.getInitialDVDRecords');
        action.setCallback(this,function(result) {
            
            var serverResponseT = (new Date()).getTime();
            console.log('Server responded in [' + (serverResponseT - startT) + '] millis'  );
            //var res = JSON.parse(result.getReturnValue());
            var response = result.getReturnValue();

          	//var response = res.entities ;
            console.log('Response');
             console.log(response);
            var driversMap = {};
            if(response != undefined && response != null) {
                for(var i=0;i<response.length;i++) {
                    
                    //if(response[i].Last_Name__c != undefined)
                       // response[i].Last_Name__c = response[i].Last_Name__c.capitalize();
                    
                    if(response[i].Date_of_Birth__c != undefined)
                        response[i].Date_of_Birth__c = this.formatDate(response[i].Date_of_Birth__c);
                    else
                        response[i].Date_of_Birth__c = '';
                    
                    if(response[i].Last_DVD_Check_date__c != undefined)
                        response[i].Last_DVD_Check_date__c = this.formatDate(response[i].Last_DVD_Check_date__c);
                    else
                        response[i].Last_DVD_Check_date__c = '';
                    //response[i].PTCode_Active_Start_Date__c != undefined ||
                    if(response[i].PTCode_Active_Start_Date__c !=null || response[i].PTCode_Active_Start_Date__c!='' && (response[i].PTCode_Active_Start_Date__c != undefined))
                    {
                        console.log('Entered loop');
                        console.log('loggedbefore ' + response[i].PTCode_Active_Start_Date__c);
                        response[i].PTCode_Active_Start_Date__c = this.formatDate(response[i].PTCode_Active_Start_Date__c);
                        console.log('LoggedDate' + response[i].PTCode_Active_Start_Date__c);
                    }
                    else{
                        console.log('NULLcapture');
                        response[i].PTCode_Active_Start_Date__c = '';
                    }
                    
                    if(response[i].Last_Name__c == undefined)
                        response[i].Last_Name__c = '';
                    if(response[i].Licence_Number__c == undefined)
                        response[i].Licence_Number__c = '';	
					if(response[i].NSW_Tenure_Check__c == undefined)
                        response[i].NSW_Tenure_Check__c = 'Unknown';	
                    
                    driversMap[response[i].Id] = response[i];
                }
                
                var records = response;
                if(!(component.get("v.sortDriverAsc") 
                     && component.get("v.sortDriverField") == "Last_Name__c")){
                    
                    console.log('driver sort start : ' + ((new Date()).getTime() - serverResponseT));
                    records = this.sortDriverBy(component, "Last_Name__c", records);
                    console.log('driver sort end : ' + ((new Date()).getTime() - serverResponseT));
                } 
                else {
                    
                    var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                    
                    //number of records less than on scroll threshold, so load all
                    if(records.length < recordCountToLoadOnScroll) {
                        
                        console.log('sree');
                        component.set('v.dvdDriversList', records);
                        console.log('sree2 '+ records)
                        this.renderDriverTable(component, records);
                        component.set("v.dvdListBeforeSearch", records);
                        component.set('v.dvdFullScrollList', records);
                    }
                    else {
                        
                        component.set('v.dvdFullScrollList', records);
                        var tempRecords = records.slice(0);
                        var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
                        component.set('v.dvdDriversList', recordSubsetToLoad);
                        this.renderDriverTable(component, recordSubsetToLoad);
                        component.set("v.dvdListBeforeSearch", records);
                    }               
                }            
                
                component.set('v.dvdDriversMap', driversMap);
                component.set('v.dvdDriverMasterList', records);
                
                //component.set('v.driverCount', response.length);
                
            }
            
            
            
            //component.set('v.driverRedCount', response.redCount);
            //component.set('v.driverGreenCount', response.greenCount);
            //component.set('v.driverNoneCount', response.noneCount);
            //component.set('v.p2pEligibilityRedCount', response.p2pEligibilityRedCount);
            //component.set('v.p2pEligibilityGreenCount', response.p2pEligibilityGreenCount);
            
            var currentTab = component.find("driverSubmenu");
            
            //Set Active Tab
            for(i=0;i<currentTab.get("v.body").length;i++) {
                var elem = currentTab.get("v.body")[i];
                var elemId = elem.getLocalId();
                
                console.log('in load'+elemId);
                console.log('in load'+elem);
                console.log('in load'+$A.util.hasClass(elem, "slds-active"));
                
                if($A.util.hasClass(elem, "slds-active") && elemId == "redDrivers__itemtab") {
                    this.filterRedDrivers(component, event);
                } else if($A.util.hasClass(elem, "slds-active") && elemId == "whiteDrivers__itemtab") {
                    this.filterWhiteDrivers(component, event);
                } else if($A.util.hasClass(elem, "slds-active") && elemId == "greenDrivers__itemtab") {
                    this.filterGreenDrivers(component, event);
                }
            }
            
            component.set("v.selectedDVDRecords", []); 
            component.find("selectAllDrivers").set("v.value", false);
            
            var rerenderT = (new Date()).getTime();
            console.log('Rerendering Took [' + (rerenderT - serverResponseT) + '] millis'  );
            
            var endT = (new Date()).getTime();
            console.log('Loading Drivers took = [' + (endT - startT) + '] millis' );
            this.hideSpinner(component, event); 
            
            document.getElementById('driverTableScrollContainer').scrollTop = 0;
            component.set("v.driverScrollIndex", 1);
        });
        
        $A.enqueueAction(action);
        
        
      
        
        var greenCountAction = component.get('c.getAggregateGreenCount');
        greenCountAction.setParams({
            "entityType": "Driver"
        });
        greenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.driverGreenCount', response.greenCount);
            }
            else {
                
                console.log('Error in fetching green count for drivers');
            }
        });
        greenCountAction.setBackground();
        $A.enqueueAction(greenCountAction);
        
        var redCountAction = component.get('c.getAggregateRedCount');
        redCountAction.setParams({
            "entityType": "Driver"
        });
        redCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.driverRedCount', response.redCount);
            }
            else {
                
                console.log('Error in fetching red count for drivers');
            }
        });
        redCountAction.setBackground();
        $A.enqueueAction(redCountAction);
        
        var whiteCountAction = component.get('c.getAggregateWhiteCount');
        whiteCountAction.setParams({
            "entityType": "Driver"
        });
        whiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.driverNoneCount', response.noneCount);
            }
            else {
                
                console.log('Error in fetching white count for drivers');
            }
        });
        whiteCountAction.setBackground();
        $A.enqueueAction(whiteCountAction);
        
        var p2pEligibilityPassCountAction = component.get('c.getAggregatePassEligibilityCount');
        p2pEligibilityPassCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.p2pEligibilityGreenCount', response.p2pEligibilityGreenCount);
            }
            else {
                
                console.log('Error in fetching p2p eligibility pass count for drivers');
            }
        });
        p2pEligibilityPassCountAction.setBackground();
        $A.enqueueAction(p2pEligibilityPassCountAction);
        
        
        var getDriverCount = component.get('c.getDriverCount');
        getDriverCount.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.driverCount', response.entityCount);
            }
            else {
                
                console.log('Error in fetching p2p eligibility pass count for drivers');
            }
        });
        getDriverCount.setBackground();
        $A.enqueueAction(getDriverCount);
        
        
        var p2pEligibilityFailCountAction = component.get('c.getAggregateFailEligibilityCount');
        p2pEligibilityFailCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.p2pEligibilityRedCount', response.p2pEligibilityRedCount);
            }
            else {
                
                console.log('Error in fetching p2p eligibility fail count for drivers');
            }
        });
        p2pEligibilityFailCountAction.setBackground();
        $A.enqueueAction(p2pEligibilityFailCountAction);
        
        var sdoGreenCountAction = component.get('c.getAggregateSDOGreenCount');
        sdoGreenCountAction.setParams({
            "entityType": "Driver"
        });
        sdoGreenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.sdoGreenCount', response.sdoGreenCount);
            }
            else {
                
                console.log('Error in fetching green count for sdo');
            }
        });
        sdoGreenCountAction.setBackground();
        $A.enqueueAction(sdoGreenCountAction);
        
        var sdoRedCountAction = component.get('c.getAggregateSDORedCount');
        sdoRedCountAction.setParams({
            "entityType": "Driver"
        });
        sdoRedCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.sdoRedCount', response.sdoRedCount);
            }
            else {
                
                console.log('Error in fetching red count for sdo');
            }
        });
        sdoRedCountAction.setBackground();
        $A.enqueueAction(sdoRedCountAction);
        
        var sdoWhiteCountAction = component.get('c.getAggregateSDOWhiteCount');
        sdoWhiteCountAction.setParams({
            "entityType": "Driver"
        });
        sdoWhiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.sdoNoneCount', response.sdoNoneCount);
            }
            else {
                
                console.log('Error in fetching white count for sdo');
            }
        });
        sdoWhiteCountAction.setBackground();
        $A.enqueueAction(sdoWhiteCountAction);
        
        var sdoErrorCountAction = component.get('c.getAggregateSDOErrorCount');
        sdoErrorCountAction.setParams({
            "entityType": "Driver"
        });
        sdoErrorCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.sdoErrorCount', response.sdoErrorCount);
            }
            else {
                
                console.log('Error in fetching white count for sdo');
            }
        });
        sdoErrorCountAction.setBackground();
        $A.enqueueAction(sdoErrorCountAction);
        
        //***sdo server calls end****
        
        var ccGreenCountAction = component.get('c.getAggregateCCGreenCount');
        ccGreenCountAction.setParams({
            "entityType": "Driver"
        });
        ccGreenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.ccGreenCount', response.ccGreenCount);
            }
            else {
                
                console.log('Error in fetching green count for cc');
            }
        });
        ccGreenCountAction.setBackground();
        $A.enqueueAction(ccGreenCountAction);
        
        var ccRedCountAction = component.get('c.getAggregateCCRedCount');
        ccRedCountAction.setParams({
            "entityType": "Driver"
        });
        ccRedCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.ccRedCount', response.ccRedCount);
            }
            else {
                
                console.log('Error in fetching red count for cc');
            }
        });
        ccRedCountAction.setBackground();
        $A.enqueueAction(ccRedCountAction);
        
        var ccWhiteCountAction = component.get('c.getAggregateCCWhiteCount');
        ccWhiteCountAction.setParams({
            "entityType": "Driver"
        });
        ccWhiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.ccNoneCount', response.ccNoneCount);
            }
            else {
                
                console.log('Error in fetching white count for cc');
            }
        });
        ccWhiteCountAction.setBackground();
        $A.enqueueAction(ccWhiteCountAction);
        
        var ccErrorCountAction = component.get('c.getAggregateCCErrorCount');
        ccErrorCountAction.setParams({
            "entityType": "Driver"
        });
        ccErrorCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.ccErrorCount', response.ccErrorCount);
            }
            else {
                
                console.log('Error in fetching white count for cc');
            }
        });
        ccErrorCountAction.setBackground();
        $A.enqueueAction(ccErrorCountAction);
        
		/*********** Tenure check summary actions: start *******/
		
		var tenureGreenCountAction = component.get('c.getAggregateTenureGreenCount');
        tenureGreenCountAction.setParams({
            "entityType": "Driver"
        });
        tenureGreenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.tenureGreenCount', response.tenureGreenCount);
            }
            else {                
                console.log('Error in fetching green count for tenure check');
            }
        });
        tenureGreenCountAction.setBackground();
        $A.enqueueAction(tenureGreenCountAction);
        
        var tenureRedCountAction = component.get('c.getAggregateTenureRedCount');
        tenureRedCountAction.setParams({
            "entityType": "Driver"
        });
        tenureRedCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.tenureRedCount', response.tenureRedCount);
            }
            else {                
                console.log('Error in fetching red count for tenure check');
            }
        });
        tenureRedCountAction.setBackground();
        $A.enqueueAction(tenureRedCountAction);
        
        var tenureWhiteCountAction = component.get('c.getAggregateTenureWhiteCount');
        tenureWhiteCountAction.setParams({
            "entityType": "Driver"
        });
        tenureWhiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.tenureNoneCount', response.tenureNoneCount);
            }
            else {                
                console.log('Error in fetching white count for tenure check');
            }
        });
        tenureWhiteCountAction.setBackground();
        $A.enqueueAction(tenureWhiteCountAction);
        
        var tenureErrorCountAction = component.get('c.getAggregateTenureErrorCount');
        tenureErrorCountAction.setParams({
            "entityType": "Driver"
        });
        tenureErrorCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.tenureErrorCount', response.tenureErrorCount);
            }
            else {                
                console.log('Error in fetching white count for tenure check');
            }
        });
        tenureErrorCountAction.setBackground();
        $A.enqueueAction(tenureErrorCountAction);
        
		/*********** Tenure check summary actions: end *********/
		
        //call for system errors on licence check
        
        var errorCountAction = component.get('c.getAggregateErrorCount');
        errorCountAction.setParams({
            "entityType": "Driver"
        });
        errorCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.driverErrorCount', response.errorCount);
            }
            else {
                
                console.log('Error in fetching white count for sdo');
            }
        });
        errorCountAction.setBackground();
        $A.enqueueAction(errorCountAction);
   
    },
    loadVehicles : function(component, event) {
        
        this.showSpinner(component, event);
        this.setVehicleTableColumnWidths(component, event);
        this.setTaxiLicenceCheck(component, event);
        var startT = (new Date()).getTime();
        var action = component.get('c.getInitialVehicleRecords');
        action.setCallback(this, function(result) {
            
            var serverResponseT = (new Date()).getTime();
            console.log('Server responded in [' + (serverResponseT - startT) + '] millis'  );
            
            //var response = JSON.parse(result.getReturnValue());
            var response = result.getReturnValue();
            console.log('json parsing time: ' + (((new Date()).getTime()) - serverResponseT));
            var vehiclesMap = {};
            var tlGreenCnt = 0;
            var tlRedCnt = 0;
            var tlWhiteCnt = 0;
            if(response != undefined && response != null){
                for(i=0;i<response.length;i++) {
                    
                    if(response[i].Last_DVD_Check_date__c != undefined)
                        response[i].Last_DVD_Check_date__c = this.formatDate(response[i].Last_DVD_Check_date__c);
                    else
                        response[i].Last_DVD_Check_date__c = '';
						
					if(response[i].Last_AIS_Inspection_Date__c != undefined)
                        response[i].Last_AIS_Inspection_Date__c = this.formatDate(response[i].Last_AIS_Inspection_Date__c);
                    else
                        response[i].Last_AIS_Inspection_Date__c = '';
                    
                    if(response[i].VIN_Number_or_Chassis_Number__c == undefined)
                        response[i].VIN_Number_or_Chassis_Number__c = '';
                    if(response[i].Plate_Number__c == undefined)
                        response[i].Plate_Number__c = '';
                    if(response[i].Vehicle_Check__c == undefined || response[i].Vehicle_Check__c === 'None' || response[i].Taxi_Licence_Status__c === undefined){
                        response[i].Taxi_Licence_Status__c = 'None';
                    }
                    
                    vehiclesMap[response[i].Id] = response[i];

                    //Compute Taxi Licence Green, red and White count
                    if (response[i].Taxi_Licence_Status__c === 'Green')
                        tlGreenCnt++;
                    if (response[i].Taxi_Licence_Status__c === 'Red')
                        tlRedCnt++;
                    if (response[i].Taxi_Licence_Status__c === 'White')
                        tlWhiteCnt++;
                }
                
                console.log('json parsing time: ' + (((new Date()).getTime()) - serverResponseT));
                
                component.set("v.taxiLicenceGreenCount", tlGreenCnt);
                component.set("v.taxiLicenceRedCount", tlRedCnt);
                component.set("v.taxiLicenceWhiteCount", tlWhiteCnt);

                var records = response;
                
                console.log('driver sort start : ' + ((new Date()).getTime() - serverResponseT));
                component.set("v.sortVehicleField", "");
                records = this.sortVehicleBy(component, "Plate_Number__c", records);
                console.log('driver sort end : ' + ((new Date()).getTime() - serverResponseT));
                
                console.log('records fetched time: ' + (((new Date()).getTime()) - serverResponseT));
                
                
                var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
                
                //number of records less than on scroll threshold, so load all
                if(records.length < recordCountToLoadOnScroll) {
                    
                    
                    component.set('v.dvdVehiclesList', records);
                    this.renderVehicleTable(component, records);
                    component.set("v.dvdListBeforeSearch", records);
                    component.set('v.dvdFullScrollList', records);
                }
                else {
                    
                    component.set('v.dvdFullScrollList', records);
                    var tempRecords = records.slice(0);
                    var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
                    component.set('v.dvdVehiclesList', recordSubsetToLoad);
                    this.renderVehicleTable(component, recordSubsetToLoad);
                    component.set("v.dvdListBeforeSearch", records);
                }               
                
                component.set('v.dvdVehiclesMap', vehiclesMap);
                component.set('v.dvdVehicleMasterList', records);
                
                //component.set('v.vehicleCount', response.length);
                
            }
            
            //component.set('v.vehicleRedCount', response.redCount);
            //component.set('v.vehicleGreenCount', response.greenCount);
            //component.set('v.vehicleNoneCount', response.noneCount);
            
            var currentTab = component.find("vehicleSubmenu");
            
            for(i=0;i<currentTab.get("v.body").length;i++) {
                
                var elem = currentTab.get("v.body")[i];
                var elemId = elem.getLocalId();
                
                if($A.util.hasClass(elem, "slds-active") && elemId == "redVehicles__itemtab"){    
                    this.filterRedVehicles(component, event);
                }
                else if($A.util.hasClass(elem, "slds-active") && elemId == "whiteVehicles__itemtab") {        
                    this.filterWhiteVehicles(component, event);
                }
                    else if($A.util.hasClass(elem, "slds-active") && elemId == "greenVehicles__itemtab") {        
                        this.filterGreenVehicles(component, event);
                    }
            }
            
            component.set("v.selectedDVDRecords", []);
            component.find("selectAllVehicles").set("v.value", false);
            
            var rerenderT = (new Date()).getTime();
            console.log('Rerendering Took [' + (rerenderT - serverResponseT) + '] millis'  );
            
            var endT = (new Date()).getTime();
            console.log('Loading Vehicles took = [' + (endT - startT) + '] millis' );
            this.hideSpinner(component, event);
            
            document.getElementById('vehicleTableScrollContainer').scrollTop = 0;
            component.set("v.vehicleScrollIndex", 1);
        });
        
        $A.enqueueAction(action);
        
        var greenCountAction = component.get('c.getAggregateGreenCount');
        greenCountAction.setParams({
            "entityType": "Vehicle"
        });
        greenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.vehicleGreenCount', response.greenCount);
            }
            else {
                
                console.log('Error in fetching green count for drivers');
            }
        });
        greenCountAction.setBackground();
        $A.enqueueAction(greenCountAction);
        
        
        var redCountAction = component.get('c.getAggregateRedCount');
        redCountAction.setParams({
            "entityType": "Vehicle"
        });
        redCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.vehicleRedCount', response.redCount);
            }
            else {
                
                console.log('Error in fetching red count for drivers');
            }
        });
        redCountAction.setBackground();
        $A.enqueueAction(redCountAction);
        
        var whiteCountAction = component.get('c.getAggregateWhiteCount');
        whiteCountAction.setParams({
            "entityType": "Vehicle"
        });
        whiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.vehicleNoneCount', response.noneCount);
            }
            else {
                
                console.log('Error in fetching white count for drivers');
            }
        });
        whiteCountAction.setBackground();
        $A.enqueueAction(whiteCountAction);
        
        // get Vehicle Count
        
        var getVehicleCount = component.get('c.getVehicleCount');
        getVehicleCount.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.vehicleCount', response.entityCount);
            }
            else {
                
                console.log('Error in fetching p2p eligibility pass count for drivers');
            }
        });
        getVehicleCount.setBackground();
        $A.enqueueAction(getVehicleCount);
        
        
        var errorCountAction = component.get('c.getAggregateVehicleErrorCount');
        errorCountAction.setParams({
            "entityType": "Vehicle"
        });
        errorCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {
                
                component.set('v.vehicleErrorCount', response.vehicleErrorCount);
            }
            else {
                
                console.log('Error in fetching white count for drivers');
            }
        });
        errorCountAction.setBackground();
        $A.enqueueAction(errorCountAction);
		
		/*********** AIS Inspection Date summary actions: start *******/
		
		var aisDateGreenCountAction = component.get('c.getAggregateAISDateGreenCount');
        aisDateGreenCountAction.setParams({
            "entityType": "Vehicle"
        });
        aisDateGreenCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.inspectionDateGreenCount', response.inspectionDateGreenCount);
            }
            else {                
                console.log('Error in fetching green count for AIS inspection date');
            }
        });
        aisDateGreenCountAction.setBackground();
        $A.enqueueAction(aisDateGreenCountAction);
        
        var aisDateRedCountAction = component.get('c.getAggregateAISDateRedCount');
        aisDateRedCountAction.setParams({
            "entityType": "Vehicle"
        });
        aisDateRedCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.inspectionDateRedCount', response.inspectionDateRedCount);
            }
            else {                
                console.log('Error in fetching red count for AIS inspection date');
            }
        });
        aisDateRedCountAction.setBackground();
        $A.enqueueAction(aisDateRedCountAction);
        
        var aisDateWhiteCountAction = component.get('c.getAggregateAISDateWhiteCount');
        aisDateWhiteCountAction.setParams({
            "entityType": "Vehicle"
        });
        aisDateWhiteCountAction.setCallback(this,function(result) {
            
            var state = result.getState();
            var response = JSON.parse(result.getReturnValue());
            
            if(state === "SUCCESS") {                
                component.set('v.inspectionDateNoneCount', response.inspectionDateNoneCount);
            }
            else {                
                console.log('Error in fetching white count for AIS inspection date');
            }
        });
        aisDateWhiteCountAction.setBackground();
        $A.enqueueAction(aisDateWhiteCountAction);
        
		/*********** AIS Inspection Date summary actions: end *********/
    },
    activateDriversTab: function(component, event) {
        
        var tab1 = component.find('allDrivers__itemtab');
        var tab2 = component.find('redDrivers__itemtab');
        var tab3 = component.find('whiteDrivers__itemtab');
        var tab4 = component.find('greenDrivers__itemtab');
        
        var activeTab;
        var activeTabHandle;
        
        if(event.target != undefined) {
            
            $A.util.removeClass(tab1, "slds-active");
            $A.util.removeClass(tab2, "slds-active");
            $A.util.removeClass(tab3, "slds-active");
            $A.util.removeClass(tab4, "slds-active");
            
            activeTab = event.target.getAttribute("id");
            console.log('Got activeTab:'+activeTab);
            activeTabHandle = component.find(activeTab+'tab');  
            $A.util.addClass(activeTabHandle, "slds-active");
            
        } else if(!$A.util.hasClass(tab2, "slds-active") 
                  && !$A.util.hasClass(tab3, "slds-active")
                  && !$A.util.hasClass(tab4, "slds-active")){ 
            $A.util.addClass(component.find('allDrivers__itemtab'), "slds-active");            
        }     
        
    },
    activateVehiclesTab: function(component, event) {
        
        var tab1 = component.find('allVehicles__itemtab');
        var tab2 = component.find('redVehicles__itemtab');
        var tab3 = component.find('whiteVehicles__itemtab');
        var tab4 = component.find('greenVehicles__itemtab');
        
        var activeTab;
        var activeTabHandle;
        
        if(event.target != undefined) {
            
            $A.util.removeClass(tab1, "slds-active");
            $A.util.removeClass(tab2, "slds-active");
            $A.util.removeClass(tab3, "slds-active");
            $A.util.removeClass(tab4, "slds-active");
            
            activeTab = event.target.getAttribute("id");
            activeTabHandle = component.find(activeTab+'tab');  
            $A.util.addClass(activeTabHandle, "slds-active");            
        } else if(!$A.util.hasClass(tab2, "slds-active") 
                  && !$A.util.hasClass(tab3, "slds-active")
                  && !$A.util.hasClass(tab4, "slds-active")) { 
            $A.util.addClass(component.find('allVehicles__itemtab'), "slds-active");            
        }
    },
    sortDriverBy: function(component, field, records) {
        var sortAsc = component.get("v.sortDriverAsc"),
            sortField = component.get("v.sortDriverField");
        
        sortAsc = sortField != field || !sortAsc;
        console.log('total number of records: ' + records.length);
        records.sort(function(a,b) {
            
            var str1, str2;
            
            if(a[field] != undefined && field != 'Date_of_Birth__c' && field != 'Last_DVD_Check_date__c')
                str1 = a[field].toLowerCase();
            
            if(b[field] != undefined && field != 'Date_of_Birth__c' && field != 'Last_DVD_Check_date__c')
                str2 = b[field].toLowerCase();
            
            if(a[field] != undefined && a[field] != '' && (field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c'))
                str1 = new Date(parseInt(a[field].substring(6,10)), parseInt(a[field].substring(3,5))-1, parseInt(a[field].substring(0,2)));
            
            if(b[field] != undefined && b[field] != '' && (field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c'))
                str2 = new Date(parseInt(b[field].substring(6,10)), parseInt(b[field].substring(3,5))-1, parseInt(b[field].substring(0,2)));
            
            if((field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c')
               && a[field] == '' && b[field] == '') {
                
                str1 = a['Last_Name__c'].toLowerCase();
                str2 = b['Last_Name__c'].toLowerCase();
            }
            
            var t1 = str1 == str2,
                t2 = ((!str1 && str2) || (str1 < str2));
            
            
            return t1? 0 : (sortAsc?-1:1)*(t2?1:-1);
        });
        
        component.set("v.sortDriverAsc", sortAsc);
        component.set("v.sortDriverField", field);
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(records.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdDriversList', records);
            this.renderDriverTable(component, records);
            component.set("v.dvdListBeforeSearch", records);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', records);
            var tempRecords = records.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdDriversList', recordSubsetToLoad);
            this.renderDriverTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", records);
        }
        
        //component.set("v.dvdDriversList", records);
        //component.set("v.dvdListBeforeSearch", records);
        component.set("v.driverScrollIndex", 1);
        return records;
    },
    sortVehicleBy: function(component, field, records) {
        
        var sortAsc = component.get("v.sortVehicleAsc"),
            sortField = component.get("v.sortVehicleField");
        
        sortAsc = sortField != field || !sortAsc;
        console.log('total number of records: ' + records.length);
        
        records.sort(function(a,b) {          
            
            var str1, str2;
            
            if(a[field] != undefined && field != 'Date_of_Birth__c' && field != 'Last_DVD_Check_date__c')
                str1 = a[field].toLowerCase();
            
            if(b[field] != undefined && field != 'Date_of_Birth__c' && field != 'Last_DVD_Check_date__c')
                str2 = b[field].toLowerCase();
            
            if(a[field] != undefined && a[field] != '' && (field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c'))
                str1 = new Date(parseInt(a[field].substring(6,10)), parseInt(a[field].substring(3,5))-1, parseInt(a[field].substring(0,2)));
            
            if(b[field] != undefined && b[field] != '' && (field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c'))
                str2 = new Date(parseInt(b[field].substring(6,10)), parseInt(b[field].substring(3,5))-1, parseInt(b[field].substring(0,2)));;
            
            if((field == 'Date_of_Birth__c' || field == 'Last_DVD_Check_date__c')
               && a[field] == '' && b[field] == '') {
                
                str1 = a['Plate_Number__c'].toLowerCase();
                str2 = b['Plate_Number__c'].toLowerCase();
            }
            
            var t1 = str1 == str2,
                t2 = ((!str1 && str2) || (str1 < str2));
            
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
            
        });
        
        component.set("v.sortVehicleAsc", sortAsc);
        component.set("v.sortVehicleField", field);
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(records.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdVehiclesList', records);
            this.renderVehicleTable(component, records);
            component.set("v.dvdListBeforeSearch", records);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', records);
            var tempRecords = records.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdVehiclesList', recordSubsetToLoad);
            this.renderVehicleTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", records);
        }
        
        component.set("v.vehicleScrollIndex", 1);
        return records;
    },
    filterRedDrivers : function(component, event) {
        
        var masterList = component.get("v.dvdDriverMasterList");
        
        var redDriversList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if((masterList[i].Licence_Check__c == "Red" && component.get('v.ShowLicenceEligibility') == false) 
               || (masterList[i].Criminal_Check__c == "Red" && component.get('v.ShowCriminalCharge') == false) 
               || (masterList[i].Serious_Driving_Offence__c == "Red" && component.get('v.ShowSeriousDrivingOffences') == false)
				|| (masterList[i].NSW_Tenure_Check__c == "Red" && component.get('v.hideTenureCheck') == false)
               || (masterList[i].P2P_Offence__c == "Red")
               || (masterList[i].P2P_Eligibility__c == "Fail" && component.get('v.ShowP2pEligibility') == false)) {
                
                redDriversList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(redDriversList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdDriversList', redDriversList);
            this.renderDriverTable(component, redDriversList);
            component.set("v.dvdListBeforeSearch", redDriversList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', redDriversList);
            var tempRecords = redDriversList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdDriversList', recordSubsetToLoad);
            this.renderDriverTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", redDriversList);
        }
        
        //component.set("v.dvdDriversList", redDriversList);
        //component.set("v.dvdListBeforeSearch", redDriversList);
        this.activateDriversTab(component, event);    
    },
    filterWhiteDrivers : function(component, event) {
        
        var masterList =  component.get("v.dvdDriverMasterList");
        
        var whiteDriversList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if((masterList[i].Licence_Check__c == "White"  && component.get('v.ShowLicenceEligibility') == false) 
               || (masterList[i].Criminal_Check__c == "White" && component.get('v.ShowCriminalCharge') == false) 
               || (masterList[i].Serious_Driving_Offence__c == "White" && component.get('v.ShowSeriousDrivingOffences') == false)
				|| (masterList[i].NSW_Tenure_Check__c == "White" && component.get('v.hideTenureCheck') == false)
               || (masterList[i].P2P_Offence__c == "White" )
               || (masterList[i].Licence_Check__c == "Unknown" && component.get('v.ShowLicenceEligibility') == false)
               || (masterList[i].Criminal_Check__c == "Unknown" && component.get('v.ShowCriminalCharge') == false)
               || (masterList[i].Serious_Driving_Offence__c == "Unknown" && component.get('v.ShowSeriousDrivingOffences') == false)
			   || (masterList[i].NSW_Tenure_Check__c == "Unknown" && component.get('v.hideTenureCheck') == false)
               || (masterList[i].P2P_Offence__c == "Unknown" )
              ) {
                whiteDriversList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(whiteDriversList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdDriversList', whiteDriversList);
            this.renderDriverTable(component, whiteDriversList);
            component.set("v.dvdListBeforeSearch", whiteDriversList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', whiteDriversList);
            var tempRecords = whiteDriversList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdDriversList', recordSubsetToLoad);
            this.renderDriverTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", whiteDriversList);
        }
        
        //component.set("v.dvdDriversList", whiteDriversList);
        //component.set("v.dvdListBeforeSearch", whiteDriversList);
        console.log('filtering done');
        this.activateDriversTab(component, event);     
    },
    filterGreenDrivers : function(component, event) {
        
        var masterList =  component.get("v.dvdDriverMasterList");
        
        var greenDriversList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if((masterList[i].Licence_Check__c == "Green" || component.get('v.ShowLicenceEligibility') == true) 
               && ((masterList[i].P2P_Eligibility__c == "Pass") || component.get('v.ShowP2pEligibility') == true)
               && ((masterList[i].Serious_Driving_Offence__c == "Green") || component.get('v.ShowSeriousDrivingOffences') == true)
			   && ((masterList[i].NSW_Tenure_Check__c == "Green") || component.get('v.hideTenureCheck') == true)
               && ((masterList[i].Criminal_Check__c == "Green") || component.get('v.ShowCriminalCharge') == true)) {
                greenDriversList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(greenDriversList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdDriversList', greenDriversList);
            this.renderDriverTable(component, greenDriversList);
            component.set("v.dvdListBeforeSearch", greenDriversList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            console.log('Green Count: '+greenDriversList.length);
            component.set('v.dvdFullScrollList', greenDriversList);
            var tempRecords = greenDriversList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            console.log('Green Count: '+greenDriversList.length);
            console.log('Green Count Loaded: '+recordSubsetToLoad.length);
            component.set('v.dvdDriversList', recordSubsetToLoad);
            this.renderDriverTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", greenDriversList);
        }
        
        //component.set("v.dvdDriversList", greenDriversList);
        //component.set("v.dvdListBeforeSearch", greenDriversList);
        console.log('filtering done');
        this.activateDriversTab(component, event);
    },
    filterRedVehicles : function(component, event, helper) {
        
        var masterList =  component.get("v.dvdVehicleMasterList");
        console.log("masterList: "+masterList);
        
        var redVehiclesList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if(masterList[i].Vehicle_Check__c === "Red" || masterList[i].Taxi_Licence_Status__c === "Red"
				 || masterList[i].Last_AIS_Inspection_Date_Check__c === "Red" ){
                redVehiclesList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(redVehiclesList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdVehiclesList', redVehiclesList);
            this.renderVehicleTable(component, redVehiclesList);
            component.set("v.dvdListBeforeSearch", redVehiclesList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', redVehiclesList);
            var tempRecords = redVehiclesList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdVehiclesList', recordSubsetToLoad);
            this.renderVehicleTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", redVehiclesList);
        }
        
        //component.set("v.dvdVehiclesList",redVehiclesList);
        //component.set("v.dvdListBeforeSearch", redVehiclesList);
        this.activateVehiclesTab(component, event);
    },
    filterWhiteVehicles : function(component, event, helper){
        
        var masterList = component.get("v.dvdVehicleMasterList");
        var whiteVehiclesList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if((masterList[i].Vehicle_Check__c == "White" || masterList[i].Last_AIS_Inspection_Date_Check__c == "White"  
					|| masterList[i].Vehicle_Check__c == "Unknown") && masterList[i].Taxi_Licence_Status__c !== "Red"){
                whiteVehiclesList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(whiteVehiclesList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdVehiclesList', whiteVehiclesList);
            this.renderVehicleTable(component, whiteVehiclesList);
            component.set("v.dvdListBeforeSearch", whiteVehiclesList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', whiteVehiclesList);
            var tempRecords = whiteVehiclesList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdVehiclesList', recordSubsetToLoad);
            this.renderVehicleTable(component, recordSubsetToLoad);
            
        }
        
        //component.set("v.dvdVehiclesList", whiteVehiclesList);
        //component.set("v.dvdListBeforeSearch", whiteVehiclesList);
        this.activateVehiclesTab(component, event);
    },
    filterGreenVehicles : function(component, event, helper) {
        
        var masterList =  component.get("v.dvdVehicleMasterList");
        console.log("masterList: "+masterList);
        
        var greenVehiclesList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if(masterList[i].Vehicle_Check__c == "Green" && masterList[i].Last_AIS_Inspection_Date_Check__c == "Green" 
					&& masterList[i].Taxi_Licence_Status__c !== "Red"){
                greenVehiclesList[j] = masterList[i];
                j++;
            }
        }
        
        var recordCountToLoadOnScroll = component.get('v.recordCountToLoadOnScroll');
        
        //number of records less than on scroll threshold, so load all
        if(greenVehiclesList.length < recordCountToLoadOnScroll) {
            
            component.set('v.dvdVehiclesList', greenVehiclesList);
            this.renderVehicleTable(component, greenVehiclesList);
            component.set("v.dvdListBeforeSearch", greenVehiclesList);
            component.set('v.dvdFullScrollList', []);
        }
        else {
            
            component.set('v.dvdFullScrollList', greenVehiclesList);
            var tempRecords = greenVehiclesList.slice();
            var recordSubsetToLoad = tempRecords.splice(0, recordCountToLoadOnScroll);
            component.set('v.dvdVehiclesList', recordSubsetToLoad);
            this.renderVehicleTable(component, recordSubsetToLoad);
            component.set("v.dvdListBeforeSearch", greenVehiclesList);
        }
        
        //component.set("v.dvdVehiclesList",greenVehiclesList);
        //component.set("v.dvdListBeforeSearch", greenVehiclesList);
        this.activateVehiclesTab(component, event);
    },
    getCurrentTime : function(component, event,runType,dataToExport){
        var action = component.get('c.getCurrentTime');
        action.setCallback(this,function(result){
            var state = result.getState();
            if(state === "SUCCESS") {
                var currentTime = result.getReturnValue();
                var fileName;
                if(dateTime != '' || dateTime != undefined){
                    var dateTime = currentTime.split('-');
                    var date = dateTime[0];
                    var time = dateTime[1];
                    
                    if(runType.includes("Vehicle")){
                        fileName = date+ '@'+time+'_Vehicles.csv';
                        this.exportData(component, event, runType,fileName, dataToExport);
                    }
                    else if(runType.includes("Driver")){
                        fileName = date+ '@'+time+'_Drivers.csv';
                        this.exportData(component, event, runType,fileName, dataToExport);
                    }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    
    exportData : function(component, event, type, fileName, dataToExport){
        
        var records = dataToExport;
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        var sno = 0;
        
        if(type == 'Drivers')
            var fileTitle = '';
        else 
            var fileTitle = '';
        
        console.log('***************************************'+records.length);
        //Fill out the Header of CSV
        if(type == 'Drivers') {
            
            headerArray.push('#');
            headerArray.push('NSW Driver Licence');         
            if(component.get('v.ShowLicenceEligibility') == false)
                headerArray.push('NSW Licence');
            
            if(component.get('v.hideTenureCheck') == false)
                headerArray.push('NSW Licence Tenure');
			if(component.get('v.ShowSeriousDrivingOffences') == false)
                headerArray.push('Serious Driving Offences');
            if(component.get('v.ShowP2pEligibility') == false)
                headerArray.push('P2P Eligibility');
            if(component.get('v.ShowCriminalCharge') == false)
                headerArray.push('Criminal Charge');
             headerArray.push('PT Code Applied');
            headerArray.push('Last Checked');
            data.push(headerArray);
            
            
            for(var i=0;i< records.length;i++) {
                
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                //tempArray.push("\r\n");
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('="'+records[i].Drivers_Licence_Number__c+'"');
                
                if(component.get('v.ShowLicenceEligibility') == false){
                    tempArray.push('"'+this.getSignal(records[i].Licence_Check__c, 'Licence_Check')+'"');
                }
				 
                if(component.get('v.hideTenureCheck') == false){
                    tempArray.push('"'+this.getSignal(records[i].NSW_Tenure_Check__c, 'Tenure_Check')+'"');
                }
                
                if(component.get('v.ShowSeriousDrivingOffences') == false){
                    tempArray.push('"'+this.getSignal(records[i].Serious_Driving_Offence__c, 'SDO_Check')+'"');
                }
                
                if(component.get('v.ShowP2pEligibility') == false){
                    if(records[i].P2P_Eligibility__c != undefined)
                        tempArray.push('"'+this.getSignal(records[i].P2P_Eligibility__c, 'P2P_Eligibility')+'"');
                    else
                        tempArray.push('');
                }
                
                if(component.get('v.ShowCriminalCharge') == false){
                    tempArray.push('"'+this.getSignal(records[i].Criminal_Check__c, 'Criminal_Check')+'"');
                }
                tempArray.push('"'+records[i].PTCode_Active_Start_Date__c+'"');
                //tempArray.push('"'+records[i].PTCode_Active_Start_Date__c+'"');
                tempArray.push('"'+records[i].Last_DVD_Check_date__c+'"');
                
                data.push(tempArray);
            }
            for(var j=0;j<data.length;j++) {
                
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            
            
            
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName += fileTitle.replace(/ /g,"_");   
            fileName += ".csv";
            
            //Initialize file format you want csv or xls
            var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            
            if(navigator.msSaveBlob) { 
                // IE 10+
                console.log('----------------if-----------');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                console.log('----------------if-----------'+blob);
                navigator.msSaveBlob(blob, fileName);
            }
            else {
                
                var link = document.createElement("a");
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                var csvUrl = URL.createObjectURL(blob);
                link.setAttribute('download', fileName);
                
                //To set the content of the file
                link.href = csvUrl;
                
                //set the visibility hidden so it will not effect on your web-layout
                link.style = "visibility:hidden";
                
                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
            }
        }
        else{
            
            headerArray.push('#');
            headerArray.push('Plate Number');
            if(component.get('v.ShowVehicleCheck') == false)
                headerArray.push('Vehicle Check');
            if(component.get("v.taxiLicenceCheck"))
                headerArray.push('Taxi Licence Status');
            if(component.get("v.hideInspectionDateCheck") == false)
                headerArray.push('Safety Check');
            headerArray.push('Checked Date');
            
            data.push(headerArray);
            
            for(var i=0;i< records.length;i++){
                
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('="'+records[i].Plate_Number__c+'"');
                
                if(component.get('v.ShowVehicleCheck') == false){
                    tempArray.push('"'+this.getSignal(records[i].Vehicle_Check__c, 'Vehicle_Check')+'"');
                }
				if(component.get("v.taxiLicenceCheck"))
                    tempArray.push('"'+this.getSignal(records[i].Taxi_Licence_Status__c, 'Taxi_Licence_Status')+'"');
                if(component.get("v.hideInspectionDateCheck") == false)
                    tempArray.push('"'+records[i].Last_AIS_Inspection_Date__c+'"');
                
                tempArray.push('"'+records[i].Last_DVD_Check_date__c+'"');
                
                data.push(tempArray);
            }
            
            for(var j=0;j<data.length;j++) {
                
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName += fileTitle.replace(/ /g,"_");   
            fileName += ".csv";
            
            
            //Initialize file format you want csv or xls
            var uri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
            
            if (navigator.msSaveBlob) { // IE 10+
                console.log('----------------if-----------');
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                console.log('----------------if-----------'+blob);
                navigator.msSaveBlob(blob, fileName);
            }
            else{
                var link = document.createElement("a");
                var blob = new Blob([csvContent],{type: "text/csv;charset=utf-8;"});
                var csvUrl = URL.createObjectURL(blob);
                link.setAttribute('download',fileName);
                
                //To set the content of the file
                link.href = csvUrl;
                
                //set the visibility hidden so it will not effect on your web-layout
                link.style = "visibility:hidden";
                
                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
            }
            
        }
    },
    navigatetoexportreport : function (component, event){
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/report/00ON000000110ebMAA/dvdqueryexportallpublic"
        });
        urlEvent.fire();*/
        
        window.open('https://p2puat-pointtopoint.cs6.force.com/industryportal/s/report/00ON000000110ebMAA/dvdqueryexportallpublic','_blank')
	},
    navigatetoexportVehiclereport : function (component, event){
      
        window.open('https://p2puat-pointtopoint.cs6.force.com/industryportal/s/report/00ON00000011CdaMAE','_blank')
	},
    
    getSignal : function (check, checkOn) {
        
        console.log("In getSignal");
        
        if(checkOn == "P2P_Eligibility"){
            if(check == "Fail")
                return 'Fail';
            
            if(check == "Pass")
                return 'Pass';
            
            return '';
        } else {
            if(check == "Red")
                return 'Fail';
            
            if(check == "Green")
                return 'Pass';
            
            if(check == "White")
                return 'Unknown';
            
            if(check == "None")
                return '';
            else 
                return 'System Error';
        }
        
        
    },
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
    toggleVehicleEdit : function(component, event, recId){
        $A.util.toggleClass(document.getElementById(recId+'_PN_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_PN_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_PT_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_PT_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_VIN_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_VIN_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Edit'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Save'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Cancel'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Delete'), 'toggleDisplay');
    },
    toggleDriverEdit : function(component, event, recId){
        $A.util.toggleClass(document.getElementById(recId+'_Lname_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Lname_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_DLN_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_DLN_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_DOB_Output'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_DOB_Input'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Edit'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Save'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Cancel'), 'toggleDisplay');
        $A.util.toggleClass(document.getElementById(recId+'_Delete'), 'toggleDisplay');
    },
    formatDate : function(inputDate) {
        console.log(inputDate);
       // if(inputDate!=undefined)
        return (moment(inputDate).format("DD/MM/YYYY"));
    },
    pad: function(inputStr) {
        
        return (inputStr < 10) ? '0' + inputStr : inputStr;
    },
    renderDriverTable: function(component, newRecordsToAppend) {
        
        
        $('#driverTableBody').empty();
        
        var tableBodyToAppend = '';
        for(var i=0;i<newRecordsToAppend.length;i++) {
            console.log('Driver record:');
            console.log(newRecordsToAppend[i]);
            console.log(newRecordsToAppend[i].PTCode_Active_Start_Date__c);
            var licenceCheckResult = 'Licence Check';
            if(newRecordsToAppend[i].Licence_Check__c == 'Green'){
                licenceCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Licence_Check__c == 'Red'){
                licenceCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Licence_Check__c == 'White'){
                licenceCheckResult = 'Unknown';
            } else {
                licenceCheckResult = 'System Error';
            }
			
			var tenureCheckResult = 'NSW Tenure Check';
            if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'Green'){
                tenureCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'Red'){
                tenureCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].NSW_Tenure_Check__c == 'White'){
                tenureCheckResult = 'Unknown';
            } else {
                tenureCheckResult = 'System Error';
            }
            
            var sdoCheckResult = 'SDO Check';
            if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'Green'){
                sdoCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'Red'){
                sdoCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Serious_Driving_Offence__c == 'White'){
                sdoCheckResult = 'Unknown';
            } else {
                sdoCheckResult = 'System Error';
            }
            
            var ccCheckResult = 'CC Check';
            if(newRecordsToAppend[i].Criminal_Check__c == 'Green'){
                ccCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Criminal_Check__c == 'Red'){
                ccCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Criminal_Check__c == 'White'){
                ccCheckResult = 'Unknown';
            } else {
                ccCheckResult = 'System Error';
            }
            
            var p2pEligibilityResultFlag = 'White';
            var p2pEligibilityHover = 'Unknown';
            if(newRecordsToAppend[i].P2P_Eligibility__c == 'Pass'){
                p2pEligibilityResultFlag = 'Green';
                p2pEligibilityHover = 'No Issue';
            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Fail'){
                p2pEligibilityResultFlag = 'Red';
                p2pEligibilityHover = 'Issue';
            } else if(newRecordsToAppend[i].P2P_Eligibility__c == 'Unknown'){
                p2pEligibilityResultFlag = 'White';
            } else {
                p2pEligibilityResultFlag = 'White';
            }
            
            var licenceNumber = newRecordsToAppend[i].Drivers_Licence_Number__c;
            var licenceLength = licenceNumber.length;
            var last2Char = licenceNumber.substr(licenceLength-2,licenceLength);
            maskedLicence = (Array(licenceLength-2).join('x'||' ') + 'x').slice(-(licenceLength-2))+last2Char;
            
            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
 if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                rowBody += '<td role="gridcell" style="width:4%;">'; 
                rowBody += '<span class="slds-truncate slds-align--absolute-center" title="Select Record">';
                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink" disabled="true"/>';
                rowBody += '</span></td>';
            }
            else{
                rowBody += '<td role="gridcell" style="width:4%;">'; 
                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink"/>';
                rowBody += '</div></td>';
            }
            
            rowBody += '<td role="gridcell" style="width:8%;max-width: 84px;word-wrap: break-word;white-space: pre-wrap;">';
            rowBody += '<div class="slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_Lname_Output">';
            rowBody += newRecordsToAppend[i].Last_Name__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_Lname_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:5%;">';
            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_DLN_Output">';
            rowBody += maskedLicence;
            //rowBody += '<br/>'+ newRecordsToAppend[i].Drivers_Licence_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DLN_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:4%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_DOB_Output">';
            rowBody += newRecordsToAppend[i].Date_of_Birth__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DOB_Input">';  
            rowBody += '</div></td>';           
            
            if(component.get('v.ShowLicenceEligibility') == false){
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + licenceCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_LC_Output">';
                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Licence_Check__c+'" style="';
                
                if(newRecordsToAppend[i].Licence_Check__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';
                
                rowBody += '></img>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }
													// PT code added								
				
			// Pt code end 
			if(component.get('v.hideTenureCheck') == false){
				var imgIcon = 'Unknown';
				if(newRecordsToAppend[i].NSW_Tenure_Check__c != undefined){
					imgIcon = newRecordsToAppend[i].NSW_Tenure_Check__c;
				}
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + tenureCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Tenure_Output">';
                rowBody += '<img src="/industryportal/resource/'+ imgIcon +'" style="';
                
                if(newRecordsToAppend[i].NSW_Tenure_Check__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';
                
                rowBody += '></img>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }
			
            if(component.get('v.ShowSeriousDrivingOffences') == false){
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + sdoCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_SDO_Output">';
                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Serious_Driving_Offence__c+'" style="';
                
                if(newRecordsToAppend[i].Serious_Driving_Offence__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';
                
                rowBody += '></img>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }
            
            if(component.get('v.ShowP2pEligibility') == false){
                var p2pstyle = 'display:none;';
                if(newRecordsToAppend[i].P2P_Eligibility__c != 'None')
                    p2pstyle = 'display:block;';
                
                rowBody += '<td role="gridcell" style="width:12%" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + p2pEligibilityHover + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_P2E_Output">';
                rowBody += '<img src="/industryportal/resource/'+ p2pEligibilityResultFlag +'" style="' + p2pstyle + '"></img>';
                rowBody += '</div></td>';                
            }else{
                rowBody += '<td role="gridcell" style="width:12%" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';  
            }
            
            
            /*
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
            rowBody += '</div></td>';
            */
            if(component.get('v.ShowCriminalCharge') == false){
                rowBody += '<td role="gridcell"  style="width:12%" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="' + ccCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_CC_Output">';
                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Criminal_Check__c+'" style="';
                
                if(newRecordsToAppend[i].Criminal_Check__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';
                
                rowBody += '></img>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" style="width:12%" class="tabCol">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }
			  // PT code added								
                            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                                //console.log('Hello + ' newRecordsToAppend[i].PTCode_Active_Start_Date__c); 
                                rowBody += '<td role="gridcell" style="width:10%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="PT Code" id="'+newRecordsToAppend[i].Id+'_PTCode_Output">';
                                rowBody += 'In Progress';
                                rowBody += '</div></td>';
                            }
                            else {
                                //console.log('Hello2 + ' newRecordsToAppend[i].PTCode_Active_Start_Date__c);  
                                rowBody += '<td role="gridcell" style="width:10%;">';
                                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="PT Code" id="'+newRecordsToAppend[i].Id+'_PTCode_Output">';
                               rowBody += newRecordsToAppend[i].PTCode_Active_Start_Date__c;
                                 //rowBody += 'In Progress';
                                rowBody += '</div></td>'; 
                            }		
                            // Pt code end 
			
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<td role="gridcell" style="width:9%;">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                rowBody += 'In Progress';
                rowBody += '</div></td>';
            }
            else {
                
                rowBody += '<td role="gridcell" style="width:9%;">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                rowBody += newRecordsToAppend[i].Last_DVD_Check_date__c.toLocaleString();
                rowBody += '</div></td>'; 
            }
            rowBody += '<td role="gridcell" style="padding:0px">';
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil fa-disabled"></i>';
                rowBody += '</span>';
            }
            else {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark driverEditLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil"></i>';
                rowBody += '</span>';
            }
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:5px;" class="slds-truncate questionmark toggleDisplay driverUpdateLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Save" title="Save">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-check"></i>';
            rowBody += '</span></td>';
            
            rowBody += '<td role="gridcell" style="padding:0px">';
            /*
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o fa-disabled"></i>';
                rowBody += '<br/></span>';
            }
            else {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark driverDeleteLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o"></i>';
                rowBody += '<br/></span>';
            }
            */
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay driverCancelLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
            rowBody += '</span></td></tr>';
            
            tableBodyToAppend += rowBody;
        }
        
        $('#driverTableBody').append(tableBodyToAppend);
        
        $('.driverEditLink').click(function (ev) { component.editDriver(component, ev, this); });
        $('.driverUpdateLink').click(function (ev) { component.updateDriver(component, ev, this); });
        //$('.driverDeleteLink').click(function (ev) { component.deleteDriver(component, ev, this); });
        $('.driverCancelLink').click(function (ev) { component.cancelDriver(component, ev, this); });
        $('.driverSelectLink').change(function (ev) { component.selectDriver(component, ev, this); });
    },
    renderVehicleTable: function(component, newRecordsToAppend) {
        
        $('#vehicleTableBody').empty();
        
        var colWidth = component.get("v.vehTableColWidth");

        var tableBodyToAppend = '';
        for(var i=0;i<newRecordsToAppend.length;i++) {
            var vehicleCheckResult = 'Licence Check';
            if(newRecordsToAppend[i].Vehicle_Check__c == 'Green'){
                vehicleCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Vehicle_Check__c == 'Red'){
                vehicleCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Vehicle_Check__c == 'White'){
                vehicleCheckResult = 'Unknown';
            } else {
                vehicleCheckResult = 'System Error';
            }
            //Taxi Licence result
            var taxiLicenceCheckResult = 'Taxi Licence Status';
            if(newRecordsToAppend[i].Taxi_Licence_Status__c === 'Green'){
                taxiLicenceCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Taxi_Licence_Status__c === 'Red'){
                taxiLicenceCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Taxi_Licence_Status__c === 'White'){
                taxiLicenceCheckResult = 'Unknown';
            } else {
                taxiLicenceCheckResult = 'None';
            }
			
			var safetyCheckResult = 'Safety Check Status';
            if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'Green'){
                safetyCheckResult = 'No Issue';
            } else if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'Red'){
                safetyCheckResult = 'Issue';
            } else if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c === 'White'){
                safetyCheckResult = 'Unknown';
            } else {
                safetyCheckResult = 'None';
            }

            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
            rowBody += '<td scope="col" role="gridcell" style="width:' + colWidth.vehSelect +'">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
            
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink" disabled="true"/>';              
                rowBody += '</div></td>';   
            }
            else{
                rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink"/>';              
                rowBody += '</div></td>';
            }            
            
            rowBody += '<td scope="col" role="gridcell" style="width:' + colWidth.plateNumber +'">';
            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_PN_Output">';
            rowBody += newRecordsToAppend[i].Plate_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PN_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:' + colWidth.plateType +'">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_PT_Output">';
            rowBody += newRecordsToAppend[i].Plate_Type__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PT_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:' + colWidth.vinChasis +'">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_VIN_Output">';
            rowBody += newRecordsToAppend[i].VIN_Number_or_Chassis_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_VIN_Input">';  
            rowBody += '</div></td>';
            
            if(component.get('v.ShowVehicleCheck') == false){
            	rowBody += '<td role="gridcell" style="width:' + colWidth.vehicleCheck +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="' + vehicleCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_VC_Output">';
                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Vehicle_Check__c+'" style="';
                
                if(newRecordsToAppend[i].Vehicle_Check__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';
                
                rowBody += '></img>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" style="width:' + colWidth.vehicleCheck +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }
            
            //Taxi Licence Status Start
            if(component.get("v.taxiLicenceCheck")){
                rowBody += '<td role="gridcell" style="width:' + colWidth.taxilicCheck +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center taxilic-dvd-check-output" title="' + taxiLicenceCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_TLC_Output">';
                rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Taxi_Licence_Status__c+'" style="';

                if(newRecordsToAppend[i].Taxi_Licence_Status__c != 'None')
                    rowBody += 'display:block;"';
                else
                    rowBody += 'display:none;"';

                rowBody += '></img>';
                rowBody += '</div></td>';
            }
            //////End
			
			var inspectionDateStyle = '';
			if(newRecordsToAppend[i].Last_AIS_Inspection_Date_Check__c == 'Red'){
				inspectionDateStyle = 'style="color:red"';
			}
			
			if(component.get('v.hideInspectionDateCheck') == false){
            	rowBody += '<td role="gridcell" style="width:' + colWidth.safetyCheck +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="' + safetyCheckResult + '" data-fleet_id="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_SafetyCheck_Output">';
                rowBody += '<span ' + inspectionDateStyle + '>' + newRecordsToAppend[i].Last_AIS_Inspection_Date__c + '</span>';
                rowBody += '</div></td>';
            }else{
                rowBody += '<td role="gridcell" style="width:' + colWidth.safetyCheck +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
                rowBody += '</div></td>';
            }

            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<td role="gridcell" style="width:' + colWidth.dvdStatus +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                rowBody += 'In Progress';
                rowBody += '</div></td>';
            }
            else {
                
                rowBody += '<td role="gridcell" style="width:' + colWidth.dvdStatus +'">';
                rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
                rowBody += newRecordsToAppend[i].Last_DVD_Check_date__c;
                rowBody += '</div></td>';  
            }
            rowBody += '<td role="gridcell" style="padding:0px">';
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil fa-disabled"></i>';
                rowBody += '</span>';
            }
            else {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark vehicleEditLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil"></i>';
                rowBody += '</span>';
            }
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:5px;" class="slds-truncate questionmark toggleDisplay vehicleUpdateLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Save" title="Save">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-check"></i>';
            rowBody += '</span></td>';
            
            rowBody += '<td role="gridcell" style="padding:0px">';
            /*
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o fa-disabled"></i>';
                rowBody += '<br/></span>';
            }
            else {
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark vehicleDeleteLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Delete" title="Delete">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-trash-o"></i>';
                rowBody += '<br/></span>';
            }
            */
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay vehicleCancelLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
            rowBody += '</span></td></tr>';
            
            tableBodyToAppend += rowBody;  
        }
        
        $('#vehicleTableBody').append(tableBodyToAppend);
        
        $('.vehicleEditLink').click(function (ev) { component.editVehicle(component, ev, this); });
        $('.vehicleUpdateLink').click(function (ev) { component.updateVehicle(component, ev, this); });
        //$('.vehicleDeleteLink').click(function (ev) { component.deleteVehicle(component, ev, this); });
        $('.vehicleCancelLink').click(function (ev) { component.cancelVehicle(component, ev, this); });
        $('.vehicleSelectLink').change(function (ev) { component.selectVehicle(component, ev, this); });
    },
    isDriverInputValid : function(component,event,licenceNumber,lastName,dob){
        console.log(lastName);
        var hasError = false;
        // var isValidDate = ;
        var licenceNumregEx = /^(?=[a-zA-Z0-9]*$)(?:.{1,12})$/;
        var lastNameRegEx = /[a-zA-Z ]{1,20}$/;
        
        if(!licenceNumber){
            
            this.showtoast("Error","Invalid Licence Number","error");
            hasError = true;
        }
        
        else if(!licenceNumregEx.test(licenceNumber)){
            
            
            this.showtoast("Error","Invalid Licence Number","error");
            hasError = true;
        }
        
        
        //validate last name of driver
        if(!lastName) {
            
            this.showtoast("Error","Invalid Last Name","error");
            hasError = true;
        }
        
        else if(!lastNameRegEx.test(lastName)) {
            this.showtoast("Error","Invalid Last Name","error");
            hasError = true;
        }
        
        //validate dob of driver
        
        if(!dob) {
            //     if(!dob) {
            this.showtoast("Error","Invalid Birth Date","error");
            hasError = true;
        }
        else if(!this.isDOBValid(dob)){
            this.showtoast("Error","Invalid Birth Date","error");
            hasError = true;
        }
        
            else if(!this.isAgeValid(dob)){
                
                this.showtoast("Error","Invalid Birth Date","error");
                hasError = true;
            }
        
        
        if(hasError)
            return 0;
        
        return 1;
    },
    isAgeValid : function(bDate){
        var birth = this.formatDateString(bDate);
        
        var birthdate = new Date(birth);
        var today = new Date();
        
        if(birthdate > today){
            return false;
        }
        
        var timeDiff = Math.abs(today.getTime() - birthdate.getTime());
        var diffInYears = Math.floor((Math.ceil(timeDiff / (1000 * 3600 * 24))/365.242189));
        console.log(diffInYears); 
        if(diffInYears < 18 || diffInYears >=150){
            return false;
        }
        
        return true;
        
    },
    isDOBValid : function (str){
        
        var tempDate = this.formatDateString(str);
        
        var datestr = new Date(tempDate);
        if(datestr == 'NaN' || datestr == 'Invalid Date' ){
            return false;
        }
        return true; 
    },
    formatDateString : function(dob){
        return dob.substring(3,5) + '/' + dob.substring(0,2) + '/' + dob.substring(6, 10);
    },
    isVehicleInputValid : function(component,event,plateNumber,chassisNumber,plateType){
        
        var hasError = false;
        var plateNumRegEx = /^[a-zA-Z0-9]{1,6}/;
        var VINRegEx = /^[a-zA-Z-0-9]{4}/;
        var plateTypeRegEx =/[MO]/;
        
        //validate plate number
        if(!plateNumber){
            this.showtoast("Error","Invalid Plate Number","error");
            hasError = true;
        }
        else if(!plateNumRegEx.test(plateNumber)){
            this.showtoast("Error","Invalid Plate Number","error");
            hasError = true;
        }
        
        //validate plate type.
        console.log('plateType : '+plateType);
        if(!plateType){
            this.showtoast("Error","Invalid Plate Type","error");
            hasError = true;
        }
        else if(!plateTypeRegEx.test(plateType)){
            this.showtoast("Error","Invalid  Plate Type","error");
            hasError = true;
        }
        
        
        //validate chasis number
        if(!chassisNumber) {
            this.showtoast("Error","Invalid VIN or Chassis #","error");
            hasError = true;    
        }
        else if(!VINRegEx.test(chassisNumber)){
            this.showtoast("Error","Invalid VIN or Chassis #","error");
            hasError = true;
        }
        
        if(hasError)
            return 0;
        return 1;
    },
    showtoast : function(title, message, type){
        console.log('In showToast');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },
    checkFleetDeletion : function(component, event) {
        
        var recordsSelectedToDelete = component.get("v.selectedDVDRecords").length;
        var recordsDeleted = component.get("v.deletedRecordsCount");
        
        console.log('Records Selected To Delete: '+recordsSelectedToDelete);
        console.log('Records Deleted: '+recordsDeleted);
        
        if(recordsDeleted < recordsSelectedToDelete) {
            
            this.processFleetDeletion(component, event);
        }
        else {
            
            this.hideSpinner(component, event);
            
            component.set("v.deletedRecordsCount", 0);
            component.set("v.selectedDVDRecords", []);
            
            if(component.get("v.currentGrid") == "Drivers")
                this.loadDrivers(component, event);
            else if(component.get("v.currentGrid") == "Vehicles")
                this.loadVehicles(component, event);
            
            component.find("driverSearch").set("v.value",null);
            component.find("vehicleSearch").set("v.value",null);
            
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Record Deletion",
                "message": "Record(s) deleted successfully.",
                "type": "success",
                "duration":10000
            });
            resultsToast.fire();
        }
    },
    processFleetDeletion : function(component, event) {
        
        var selectedIds = component.get("v.selectedDVDRecords");
        
        var action = component.get("c.dvdRecordListDeletion");
        
        action.setParams({
            "ids": selectedIds
        });
        
        console.log(action);
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if(state === "SUCCESS") {
                
                console.log('In');
                component.set("v.deletedRecordsCount", component.get("v.deletedRecordsCount")+10000);
                this.checkFleetDeletion(component, event);
            }
            else 
                console.log('Failed To Delete Records !!');
        });
        
        $A.enqueueAction(action);
    },
    setTaxiLicenceCheck: function(component, event){
    	var action = component.get("c.isTaxiLicenceCheckRequired");
        action.setCallback(this,function(response) {
            var state = response.getState();
            console.log('response.getReturnValue(): ');
           
            if(state === "SUCCESS") {                
                var result = response.getReturnValue();
                component.set("v.taxiLicenceCheck", result);
                if(result){
                    var vehTableColWidths = {
                        vehSelect:"5%;",
                        plateNumber:"18%;",
                        plateType:"17%;",
                        vinChasis:"18%;",
                        vehicleCheck:"13%;",
                        taxilicCheck:"13%;",
						safetyCheck:"15%;",
                        dvdStatus:"15%;"
                    };
                    component.set("v.vehTableColWidth", vehTableColWidths);
                }
                console.log(result);
            } else{
                console.log('Failed to set Taxi Licence Status flag');                
            }
        });
        $A.enqueueAction(action);
    },
    setVehicleTableColumnWidths: function(component, event){
        //Set default vehicle table column widths
        var vehTableColWidths = {
            vehSelect:"6%;",
            plateNumber:"18%;",
            plateType:"15%;",
            vinChasis:"20%;",
            vehicleCheck:"15%;",
            safetyCheck:"15%;",
            taxilicCheck:"1%;", // placeholder set for default 1
            dvdStatus:"15%;"
        };
        component.set("v.vehTableColWidth", vehTableColWidths);
    }
})