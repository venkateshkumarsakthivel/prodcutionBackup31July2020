({
    init: function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            {label: 'Authorisation', fieldName: 'Name', type: 'text'},
            {label: 'Type', fieldName: 'Authorisation_Type__c', type: 'text'},
            {label: 'Start Date', fieldName: 'Start_Date__c', type: 'date'},
            {label: 'End Date', fieldName: 'End_Date__c', type: 'date'}
        ]);
        helper.getData(cmp);
    }
})