({
    loadDrivers : function(component, event) {
        
        this.showSpinner(component, event);
        var startT = (new Date()).getTime();
        var action = component.get('c.getInitialDVDRecords');
        action.setCallback(this,function(result) {
            
            var serverResponseT = (new Date()).getTime();
            console.log('Server responded in [' + (serverResponseT - startT) + '] millis'  );
            var response = JSON.parse(result.getReturnValue());
            
            var driversMap = {};
            
            for(var i=0;i<response.entities.length;i++) {
                
                response.entities[i].Date_of_Birth__c = this.formatDate(response.entities[i].Date_of_Birth__c);
                response.entities[i].Last_DVD_Check_date__c = this.formatDate(response.entities[i].Last_DVD_Check_date__c);
                if(response.entities[i].Last_Name__c == undefined)
                    response.entities[i].Last_Name__c = '';
                if(response.entities[i].Licence_Number__c == undefined)
                    response.entities[i].Licence_Number__c = '';
                
                driversMap[response.entities[i].Id] = response.entities[i];
            }
            
            var records = response.entities;
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
                    
                    component.set('v.dvdDriversList', records);
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
            
            component.set('v.driverCount', response.entityCount);
            component.set('v.driverRedCount', response.redCount);
            component.set('v.driverGreenCount', response.greenCount);
            component.set('v.driverNoneCount', response.noneCount);
            
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
        });
        
        $A.enqueueAction(action);
    },
    loadVehicles : function(component, event) {
        
        this.showSpinner(component, event);
        var startT = (new Date()).getTime();
        var action = component.get('c.getInitialVehicleRecords');
        action.setCallback(this, function(result) {
            
            var serverResponseT = (new Date()).getTime();
            console.log('Server responded in [' + (serverResponseT - startT) + '] millis'  );
            
            var response = JSON.parse(result.getReturnValue());
            console.log('json parsing time: ' + (((new Date()).getTime()) - serverResponseT));
            var vehiclesMap = {};
            
            for(i=0;i<response.entities.length;i++) {
                
                response.entities[i].Last_DVD_Check_date__c = this.formatDate(response.entities[i].Last_DVD_Check_date__c);
                if(response.entities[i].VIN_Number_or_Chassis_Number__c == undefined)
                    response.entities[i].VIN_Number_or_Chassis_Number__c = '';
                if(response.entities[i].Plate_Number__c == undefined)
                    response.entities[i].Plate_Number__c = '';
                
                vehiclesMap[response.entities[i].Id] = response.entities[i];
            }
            
            var records = response.entities;
            
            console.log('driver sort start : ' + ((new Date()).getTime() - serverResponseT));
            component.set("v.sortVehicleField", "");
            records = this.sortVehicleBy(component, "Plate_Number__c", records);
            console.log('driver sort end : ' + ((new Date()).getTime() - serverResponseT));
            
            console.log('records fetched time: ' + (((new Date()).getTime()) - serverResponseT));
            component.set('v.dvdVehiclesMap', vehiclesMap);
            component.set('v.dvdVehicleMasterList', response.entities);
            
            component.set('v.vehicleCount', response.entityCount);
            component.set('v.vehicleRedCount', response.redCount);
            component.set('v.vehicleGreenCount', response.greenCount);
            component.set('v.vehicleNoneCount', response.noneCount);
            
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
            
        });
        
        $A.enqueueAction(action);
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
            
            console.log(a[field]);
            console.log(b[field]);
            
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
                
                str1 = a['Last_Name__c'].toLowerCase();;
                str2 = b['Last_Name__c'].toLowerCase();;
            }
            
            var t1 = str1 == str2,
                t2 = ((!str1 && str2) || (str1 < str2));
            
            
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
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
                
                str1 = a['Plate_Number__c'].toLowerCase();;
                str2 = b['Plate_Number__c'].toLowerCase();;
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
        
        //component.set("v.dvdVehiclesList", records);
        //component.set("v.dvdListBeforeSearch", records);
    },
    filterRedDrivers : function(component, event) {
        
        var masterList = component.get("v.dvdDriverMasterList");
        
        var redDriversList =[];
        var j = 0;
        for(i=0;i<masterList.length;i++){
            
            if((masterList[i].Licence_Check__c == "Red" ) 
               || (masterList[i].Criminal_Check__c == "Red" ) 
               || (masterList[i].Serious_Driving_Offence__c == "Red" ) 
               || (masterList[i].P2P_Offence__c == "Red" )) {
                
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
            
            if((masterList[i].Licence_Check__c == "White" ) 
               || (masterList[i].Criminal_Check__c == "White" ) 
               || (masterList[i].Serious_Driving_Offence__c == "White" ) 
               || (masterList[i].P2P_Offence__c == "White" )){
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
            
            if(masterList[i].Licence_Check__c == "Green" ) {
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
            
            if(masterList[i].Vehicle_Check__c == "Red" ){
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
            
            if(masterList[i].Vehicle_Check__c == "White" ){
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
            component.set("v.dvdListBeforeSearch", whiteVehiclesList);
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
            
            if(masterList[i].Vehicle_Check__c == "Green" ){
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
    exportData : function(component, event, type, dataToExport){
        
        var records = dataToExport;
        var data = [];
        var headerArray = [];
        var csvContentArray = [];
        var sno = 0;
        
        if(type == 'Drivers')
            var fileTitle = 'Drivers';
        else 
            var fileTitle = 'Vehicles';
        
        //Fill out the Header of CSV
        if(type == 'Drivers'){
            headerArray.push('#');
            headerArray.push('NSW Driver Licence');
            headerArray.push('Licence Check');
            headerArray.push('Criminal Offence');
            headerArray.push('Serious Driving Offence');
            headerArray.push('P2P Offence');
            headerArray.push('Checked Date');
            data.push(headerArray);
            
            for(var i=0;i< records.length;i++){
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                //tempArray.push("\r\n");
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+records[i].Drivers_Licence_Number__c+'"');
                tempArray.push('"'+this.getSignal(records[i].Licence_Check__c)+'"');
                tempArray.push('"'+this.getSignal(records[i].Criminal_Check__c)+'"');
                tempArray.push('"'+this.getSignal(records[i].Serious_Driving_Offence__c)+'"');
                tempArray.push('"'+this.getSignal(records[i].P2P_Offence__c)+'"');
                tempArray.push('"'+records[i].Last_DVD_Check_date__c+'"');
                
                data.push(tempArray);
            }
            for(var j=0;j<data.length;j++){
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            
            var currentdate = new Date();
            var fileName = currentdate.getDate() + "/"+currentdate.getMonth() 
            + "/" + currentdate.getFullYear() + " @ " 
            + currentdate.getHours() + ":" 
            + currentdate.getMinutes() + ":" + currentdate.getSeconds() + " ";
            
            //var fileName = "Report_";
            
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
                link.setAttribute('download',fileName);
                
                //To set the content of the file
                link.href = uri;
                
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
            headerArray.push('Vehicle Check');
            headerArray.push('Checked Date');
            data.push(headerArray);
            //console.log(data);
            
            
            for(var i=0;i< records.length;i++){
                
                //Initialize the temperory array
                var tempArray = [];
                //use parseInt to perform math operation
                sno = parseInt(sno) + parseInt(1);
                tempArray.push('"'+sno+'"');
                tempArray.push('"'+records[i].Plate_Number__c+'"');
                tempArray.push('"'+this.getSignal(records[i].Vehicle_Check__c)+'"');
                tempArray.push('"'+records[i].Last_DVD_Check_date__c+'"');
                
                data.push(tempArray);
                // console.log(data);
                
                
            }
            
            for(var j=0;j<data.length;j++){
                var dataString = data[j].join(",");
                csvContentArray.push(dataString);
            }
            
            var csvContent = csvContentArray.join("\r\n");
            
            var currentdate = new Date();
            var fileName = currentdate.getDate() + "/"+currentdate.getMonth() 
            + "/" + currentdate.getFullYear() + " @ " 
            + currentdate.getHours() + ":" 
            + currentdate.getMinutes() + ":" + currentdate.getSeconds() + " ";
            
            //this will remove the blank-spaces from the title and replace it with an underscore
            fileName += fileTitle.replace(/ /g,":");   
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
                link.setAttribute('download',fileName);
                
                //To set the content of the file
                link.href = uri;
                
                //set the visibility hidden so it will not effect on your web-layout
                link.style = "visibility:hidden";
                
                //this part will append the anchor tag and remove it after automatic click
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                
            }
            
        }
    },
    
    getSignal : function (check){
        console.log("In getSignal");
        if(check == "Red"){
            console.log("In red");
            return 'Fail';
        }
        if(check == "Green"){
            console.log("In Green");
            return 'Pass';
        }
        if(check == "White"){
            console.log("In White");
            return 'Not Found';
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
        
        if(inputDate == null || inputDate == undefined)
            return '';
        
        var d = new Date(inputDate);
        return [this.pad(d.getDate()), this.pad(d.getMonth()+1), d.getFullYear()].join('/');
        //var dateStr = [this.pad(d.getDate()), this.pad(d.getMonth()+1), d.getFullYear()].join('/');
        //return new Date(parseInt(dateStr.substring(6,10)), parseInt(dateStr.substring(3,5))-1, parseInt(dateStr.substring(0,2)));
    },
    pad: function(inputStr) {
        
        return (inputStr < 10) ? '0' + inputStr : inputStr;
    },
    renderDriverTable: function(component, newRecordsToAppend) {
        
        
        $('#driverTableBody').empty();
        
        var tableBodyToAppend = '';
        for(var i=0;i<newRecordsToAppend.length;i++) {
            
            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
            rowBody += '<td role="gridcell" style="width:5%;">'; 
            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
            rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' driverSelectLink"/>';
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:13%;">';
            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_Lname_Output">';
            rowBody += newRecordsToAppend[i].Last_Name__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_Lname_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:13%;">';
            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_DLN_Output">';
            rowBody += newRecordsToAppend[i].Drivers_Licence_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DLN_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:13%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_DOB_Output">';
            rowBody += newRecordsToAppend[i].Date_of_Birth__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_DOB_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Licence Check" data-fleet_id="'+newRecordsToAppend[i].Id+'" onclick="{!c.openFleetDetail}" id="'+newRecordsToAppend[i].Id+'_LC_Output" style="cursor:pointer;">';
            rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Licence_Check__c+'" style="';
            
            if(newRecordsToAppend[i].Licence_Check__c != 'None')
                rowBody += 'display:block;"';
            else
                rowBody += 'display:none;"';
            
            rowBody += '></img>';
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" class="tabCol">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center dvd-check-output" title="Coming Soon">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-clock-o"></i>';
            rowBody += '</div></td>';
            
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
              rowBody += '<td role="gridcell" style="width:13%;">';
              rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
              rowBody += 'In Progress';
              rowBody += '</div></td>';
            }
            else {
                
              rowBody += '<td role="gridcell" style="width:13%;">';
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
                
                rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:6px;" class="slds-truncate questionmark driverEditLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Edit" title="Edit">';
                rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-pencil"></i>';
                rowBody += '</span>';
            }
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;padding-right:5px;" class="slds-truncate questionmark toggleDisplay driverUpdateLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Save" title="Save">';
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-check"></i>';
            rowBody += '</span></td>';
            
            rowBody += '<td role="gridcell" style="padding:0px">';
            
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
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay driverCancelLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
            rowBody += '</span></td></tr>';
            
            tableBodyToAppend += rowBody;
        }
        
        $('#driverTableBody').append(tableBodyToAppend);
        
        $('.driverEditLink').click(function (ev) { component.editDriver(component, ev, this); });
        $('.driverUpdateLink').click(function (ev) { component.updateDriver(component, ev, this); });
        $('.driverDeleteLink').click(function (ev) { component.deleteDriver(component, ev, this); });
        $('.driverCancelLink').click(function (ev) { component.cancelDriver(component, ev, this); });
        $('.driverSelectLink').change(function (ev) { component.selectDriver(component, ev, this); });
    },
    renderVehicleTable: function(component, newRecordsToAppend) {
        
        $('#vehicleTableBody').empty();
        
        var tableBodyToAppend = '';
        for(var i=0;i<newRecordsToAppend.length;i++) {
            
            var rowBody = '<tr class="slds-hint-parent" id="'+newRecordsToAppend[i].Id+'">';
            
            rowBody += '<td scope="col" role="gridcell" style="width:6%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Select Record">';
            
            rowBody += '<input type="checkbox" id="'+newRecordsToAppend[i].Id+'" class="uiInput uiInputCheckbox uiInput--default uiInput--checkbox '+newRecordsToAppend[i].Id+' vehicleSelectLink"/>';              
            rowBody += '</div></td>';
            
            rowBody += '<td scope="col" role="gridcell" style="width:20%;">';
            rowBody += '<div class="slds-truncate slds-text-align--left" id="'+newRecordsToAppend[i].Id+'_PN_Output">';
            rowBody += newRecordsToAppend[i].Plate_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PN_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:18%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_PT_Output">';
            rowBody += newRecordsToAppend[i].Plate_Type__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_PT_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:18%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center" id="'+newRecordsToAppend[i].Id+'_VIN_Output">';
            rowBody += newRecordsToAppend[i].VIN_Number_or_Chassis_Number__c;
            rowBody += '</div>';
            rowBody += '<div class="slds-truncate slds-text-align--left toggleDisplay" id="'+newRecordsToAppend[i].Id+'_VIN_Input">';  
            rowBody += '</div></td>';
            
            rowBody += '<td role="gridcell" style="width:15%;">';
            rowBody += '<div class="slds-truncate slds-align--absolute-center vehicle-dvd-check-output" title="Licence Check" data-fleet_id="'+newRecordsToAppend[i].Id+'" onclick="{!c.openFleetDetail}" id="'+newRecordsToAppend[i].Id+'_VC_Output" style="cursor:pointer;">';
            rowBody += '<img src="/industryportal/resource/'+newRecordsToAppend[i].Vehicle_Check__c+'" style="';
            
            if(newRecordsToAppend[i].Licence_Check__c != 'None')
                rowBody += 'display:block;"';
            else
                rowBody += 'display:none;"';
            
            rowBody += '></img>';
            rowBody += '</div></td>';
            
            if(newRecordsToAppend[i].DVD_Status__c == 'Requested') {
                
              rowBody += '<td role="gridcell" style="width:18%;">';
              rowBody += '<div class="slds-truncate slds-align--absolute-center" title="Checked Date" id="'+newRecordsToAppend[i].Id+'_DVDCD_Output">';
              rowBody += 'In Progress';
              rowBody += '</div></td>';
            }
            else {
                
              rowBody += '<td role="gridcell" style="width:18%;">';
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
            
            rowBody += '<span style="cursor:pointer;padding-bottom:8px;" class="slds-truncate questionmark toggleDisplay vehicleCancelLink" data-RecId="'+newRecordsToAppend[i].Id+'" id="'+newRecordsToAppend[i].Id+'_Cancel" title="Cancel">';  
            rowBody += '<i style="color:#54698d !important;font-size: 1.6em !important;" class="fa fa-times"></i>';
            rowBody += '</span></td></tr>';
            
            tableBodyToAppend += rowBody;  
        }
        
        $('#vehicleTableBody').append(tableBodyToAppend);
        
        $('.vehicleEditLink').click(function (ev) { component.editVehicle(component, ev, this); });
        $('.vehicleUpdateLink').click(function (ev) { component.updateVehicle(component, ev, this); });
        $('.vehicleDeleteLink').click(function (ev) { component.deleteVehicle(component, ev, this); });
        $('.vehicleCancelLink').click(function (ev) { component.cancelVehicle(component, ev, this); });
        $('.vehicleSelectLink').change(function (ev) { component.selectVehicle(component, ev, this); });
    },
    
    isDriverInputValid : function(component,event,licenceNumber,lastName,dob){
        console.log(lastName);
        var hasError = false;
        // var isValidDate = ;
        var licenceNumregEx = /^(?=[a-zA-Z0-9]*$)(?:.{6}|.{8})$/;
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
        var diffInYears = Math.floor((Math.ceil(timeDiff / (1000 * 3600 * 24))/365));
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
    
    isVehicleInputValid : function(component,event,plateNumber,chassisNumber){
        
        var hasError = false;
        var plateNumRegEx = /^[a-zA-Z0-9]{6}/;
        var VINRegEx = /^[a-zA-Z-0-9]{4}/;
        
        //validate plate number
        if(!plateNumber){
            this.showtoast("Error","Invalid Plate Number","error");
            hasError = true;
        }
        else if(!plateNumRegEx.test(plateNumber)){
            this.showtoast("Error","Invalid Plate Number","error");
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
    
    showtoast : function(title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    }
})